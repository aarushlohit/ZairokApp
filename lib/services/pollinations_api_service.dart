// ============================================================================
// Pollinations API Service for Zairok
// ============================================================================
// This service handles all AI generation requests using the new Pollinations
// API endpoints. It provides secure API key management, retry logic, and
// proper error handling.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Configuration class for API settings
class PollinationsApiConfig {
  /// Secure storage instance for API key
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Key used in secure storage
  static const String _apiKeyStorageKey = 'sk_Jrahsl0HRdlyboAUWNGhFxXa9m3ZzE5q';

  /// Base URL for the new Pollinations API
  static const String baseUrl = 'https://gen.pollinations.ai';

  /// Text generation endpoint
  static const String textEndpoint = '$baseUrl/v1/chat/completions';

  /// Image generation endpoint (prompt is appended)
  static const String imageEndpoint = '$baseUrl/image';

  /// Default timeout duration
  static const Duration defaultTimeout = Duration(seconds: 60);

  /// Maximum retry attempts
  static const int maxRetries = 3;

  /// Retry delay
  static const Duration retryDelay = Duration(seconds: 2);

  /// Store API key securely
  static Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
  }

  /// Retrieve API key from secure storage
  static Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyStorageKey);
  }

  /// Delete stored API key
  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
  }

  /// Check if API key is configured
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}

/// Response class for text generation
class TextGenerationResponse {
  final bool success;
  final String? content;
  final String? error;
  final String? model;
  final int? promptTokens;
  final int? completionTokens;

  TextGenerationResponse({
    required this.success,
    this.content,
    this.error,
    this.model,
    this.promptTokens,
    this.completionTokens,
  });

  factory TextGenerationResponse.success(
    String content, {
    String? model,
    int? promptTokens,
    int? completionTokens,
  }) {
    return TextGenerationResponse(
      success: true,
      content: content,
      model: model,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
    );
  }

  factory TextGenerationResponse.failure(String error) {
    return TextGenerationResponse(success: false, error: error);
  }
}

/// Response class for image generation
class ImageGenerationResponse {
  final bool success;
  final String? imageUrl;
  final String? error;

  ImageGenerationResponse({required this.success, this.imageUrl, this.error});

  factory ImageGenerationResponse.success(String imageUrl) {
    return ImageGenerationResponse(success: true, imageUrl: imageUrl);
  }

  factory ImageGenerationResponse.failure(String error) {
    return ImageGenerationResponse(success: false, error: error);
  }
}

/// Main API Service class for Pollinations
class PollinationsApiService {
  final http.Client _client;
  String? _cachedApiKey;

  PollinationsApiService({http.Client? client})
    : _client = client ?? http.Client();

  /// Get headers with authorization
  Future<Map<String, String>> _getHeaders({
    bool includeContentType = true,
  }) async {
    // Try to get cached key first, then from secure storage
    _cachedApiKey ??= await PollinationsApiConfig.getApiKey();

    final headers = <String, String>{};

    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_cachedApiKey';
    }

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  /// Clear cached API key (call after key update)
  void clearCachedApiKey() {
    _cachedApiKey = null;
  }

  // ==========================================================================
  // TEXT GENERATION
  // ==========================================================================

  /// Generate text using the new chat completions endpoint
  ///
  /// [messages] - List of message objects with 'role' and 'content'
  /// [model] - Model to use (default: 'openai')
  /// [temperature] - Controls randomness (0.0 to 2.0)
  /// [maxTokens] - Maximum tokens in response
  Future<TextGenerationResponse> generateText({
    required List<Map<String, String>> messages,
    String model = 'openai',
    double? temperature,
    int? maxTokens,
  }) async {
    int attempts = 0;

    while (attempts < PollinationsApiConfig.maxRetries) {
      attempts++;

      try {
        final headers = await _getHeaders();

        final body = <String, dynamic>{'model': model, 'messages': messages};

        if (temperature != null) {
          body['temperature'] = temperature;
        }

        if (maxTokens != null) {
          body['max_tokens'] = maxTokens;
        }

        final response = await _client
            .post(
              Uri.parse(PollinationsApiConfig.textEndpoint),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(PollinationsApiConfig.defaultTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Parse OpenAI-compatible response format
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            final choice = data['choices'][0];
            final content = choice['message']?['content'] ?? '';

            return TextGenerationResponse.success(
              content,
              model: data['model'],
              promptTokens: data['usage']?['prompt_tokens'],
              completionTokens: data['usage']?['completion_tokens'],
            );
          }

          // Fallback: try to get content directly if different format
          if (data['content'] != null) {
            return TextGenerationResponse.success(data['content']);
          }

          return TextGenerationResponse.failure('Invalid response format');
        } else if (response.statusCode == 401) {
          return TextGenerationResponse.failure(
            'Invalid API key. Please check your configuration.',
          );
        } else if (response.statusCode == 429) {
          // Rate limited - retry with delay
          if (attempts < PollinationsApiConfig.maxRetries) {
            await Future.delayed(PollinationsApiConfig.retryDelay * attempts);
            continue;
          }
          return TextGenerationResponse.failure(
            'Rate limit exceeded. Please try again later.',
          );
        } else if (response.statusCode >= 500) {
          // Server error - retry
          if (attempts < PollinationsApiConfig.maxRetries) {
            await Future.delayed(PollinationsApiConfig.retryDelay);
            continue;
          }
          return TextGenerationResponse.failure(
            'Server error (${response.statusCode}). Please try again.',
          );
        } else {
          return TextGenerationResponse.failure(
            'Request failed with status ${response.statusCode}',
          );
        }
      } on TimeoutException {
        if (attempts < PollinationsApiConfig.maxRetries) {
          continue;
        }
        return TextGenerationResponse.failure(
          'Request timed out. Please check your connection.',
        );
      } catch (e) {
        if (attempts < PollinationsApiConfig.maxRetries) {
          await Future.delayed(PollinationsApiConfig.retryDelay);
          continue;
        }
        return TextGenerationResponse.failure('Network error: ${e.toString()}');
      }
    }

    return TextGenerationResponse.failure(
      'Failed after ${PollinationsApiConfig.maxRetries} attempts',
    );
  }

  /// Simple text generation with a single prompt
  Future<TextGenerationResponse> generateSimpleText({
    required String prompt,
    String model = 'openai',
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    messages.add({'role': 'user', 'content': prompt});

    return generateText(messages: messages, model: model);
  }

  /// Generate text with conversation history
  Future<TextGenerationResponse> generateWithHistory({
    required String currentPrompt,
    required List<Map<String, dynamic>> chatHistory,
    String model = 'openai',
    String? systemPrompt,
    int maxHistoryPairs = 6,
  }) async {
    final messages = <Map<String, String>>[];

    // Add system prompt if provided
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    // Add conversation history (limit to maxHistoryPairs)
    int pairsAdded = 0;
    for (
      int i = 0;
      i < chatHistory.length && pairsAdded < maxHistoryPairs;
      i++
    ) {
      final msg = chatHistory[i];
      final role = msg['role']?.toString();
      final text = msg['text']?.toString();

      if (role != null && text != null && text.isNotEmpty) {
        if (role == 'user') {
          messages.add({'role': 'user', 'content': text});
        } else if (role == 'ai') {
          messages.add({'role': 'assistant', 'content': text});
          pairsAdded++;
        }
      }
    }

    // Add current prompt
    messages.add({'role': 'user', 'content': currentPrompt});

    return generateText(messages: messages, model: model);
  }

  // ==========================================================================
  // IMAGE GENERATION
  // ==========================================================================

  /// Generate image URL using the new image endpoint
  ///
  /// [prompt] - Text description of the image to generate
  /// [model] - Model to use (default: 'flux')
  /// [width] - Image width
  /// [height] - Image height
  /// [seed] - Optional seed for reproducible results
  /// [negativePrompt] - What to avoid in the image
  /// [nologo] - Remove watermark
  /// [enhance] - Enable prompt enhancement
  String buildImageUrl({
    required String prompt,
    String model = 'flux',
    int? width,
    int? height,
    String? seed,
    String? negativePrompt,
    bool nologo = true,
    bool enhance = false,
  }) {
    // URL encode the prompt
    final encodedPrompt = Uri.encodeComponent(prompt);

    // Build query parameters
    final queryParams = <String, String>{'model': model};

    if (width != null) {
      queryParams['width'] = width.toString();
    }

    if (height != null) {
      queryParams['height'] = height.toString();
    }

    if (seed != null && seed.isNotEmpty) {
      queryParams['seed'] = seed;
    } else {
      // Generate random seed like the old implementation
      queryParams['seed'] = (Random().nextInt(900000000) + 100000000)
          .toString();
    }

    if (negativePrompt != null && negativePrompt.isNotEmpty) {
      queryParams['negative_prompt'] = negativePrompt;
    }

    if (nologo) {
      queryParams['nologo'] = 'true';
    }

    if (enhance) {
      queryParams['enhance'] = 'true';
    }

    // Build the full URL
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${PollinationsApiConfig.imageEndpoint}/$encodedPrompt?$queryString';
  }

  /// Generate image and get the URL (validates the generation)
  Future<ImageGenerationResponse> generateImage({
    required String prompt,
    String model = 'flux',
    int? width,
    int? height,
    String? seed,
    String? negativePrompt,
    bool nologo = true,
    bool enhance = false,
  }) async {
    int attempts = 0;

    while (attempts < PollinationsApiConfig.maxRetries) {
      attempts++;

      try {
        final imageUrl = buildImageUrl(
          prompt: prompt,
          model: model,
          width: width,
          height: height,
          seed: seed,
          negativePrompt: negativePrompt,
          nologo: nologo,
          enhance: enhance,
        );

        // Validate the URL by making a HEAD request
        final headers = await _getHeaders(includeContentType: false);

        final response = await _client
            .head(Uri.parse(imageUrl), headers: headers)
            .timeout(PollinationsApiConfig.defaultTimeout);

        if (response.statusCode == 200 || response.statusCode == 302) {
          return ImageGenerationResponse.success(imageUrl);
        } else if (response.statusCode == 401) {
          return ImageGenerationResponse.failure(
            'Invalid API key. Please check your configuration.',
          );
        } else if (response.statusCode == 429) {
          if (attempts < PollinationsApiConfig.maxRetries) {
            await Future.delayed(PollinationsApiConfig.retryDelay * attempts);
            continue;
          }
          return ImageGenerationResponse.failure(
            'Rate limit exceeded. Please try again later.',
          );
        } else if (response.statusCode >= 500) {
          if (attempts < PollinationsApiConfig.maxRetries) {
            await Future.delayed(PollinationsApiConfig.retryDelay);
            continue;
          }
          return ImageGenerationResponse.failure(
            'Server error. Please try again.',
          );
        } else {
          // Even if HEAD fails, the URL might still work for GET
          // Return success since the URL is valid
          return ImageGenerationResponse.success(imageUrl);
        }
      } on TimeoutException {
        if (attempts < PollinationsApiConfig.maxRetries) {
          continue;
        }
        return ImageGenerationResponse.failure(
          'Request timed out. Please check your connection.',
        );
      } catch (e) {
        if (attempts < PollinationsApiConfig.maxRetries) {
          await Future.delayed(PollinationsApiConfig.retryDelay);
          continue;
        }
        return ImageGenerationResponse.failure(
          'Network error: ${e.toString()}',
        );
      }
    }

    return ImageGenerationResponse.failure(
      'Failed after ${PollinationsApiConfig.maxRetries} attempts',
    );
  }

  /// Generate image URL without validation (for immediate display)
  ImageGenerationResponse generateImageUrlSync({
    required String prompt,
    String model = 'flux',
    int? width,
    int? height,
    String? seed,
    String? negativePrompt,
    bool nologo = true,
    bool enhance = false,
  }) {
    try {
      final imageUrl = buildImageUrl(
        prompt: prompt,
        model: model,
        width: width,
        height: height,
        seed: seed,
        negativePrompt: negativePrompt,
        nologo: nologo,
        enhance: enhance,
      );

      return ImageGenerationResponse.success(imageUrl);
    } catch (e) {
      return ImageGenerationResponse.failure(
        'Failed to build image URL: ${e.toString()}',
      );
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Singleton instance for easy access
class PollinationsApi {
  static final PollinationsApiService _instance = PollinationsApiService();

  static PollinationsApiService get instance => _instance;

  /// Initialize API with optional key
  static Future<void> initialize({String? apiKey}) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      await PollinationsApiConfig.setApiKey(apiKey);
      _instance.clearCachedApiKey();
    }
  }
}
