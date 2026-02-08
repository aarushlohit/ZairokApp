# Pollinations API Configuration Guide
# =====================================
# This file documents how to configure the API key for Zairok's AI features.
#
# IMPORTANT: DO NOT commit actual API keys to version control!

# =============================================================================
# OPTION 1: Runtime Configuration (Recommended for Production)
# =============================================================================
#
# Set the API key programmatically using the secure storage:
#
# ```dart
# import 'package:zairok/services/pollinations_api_service.dart';
#
# // Store API key securely
# await PollinationsApiConfig.setApiKey('YOUR_API_KEY');
#
# // Check if key is configured
# bool hasKey = await PollinationsApiConfig.hasApiKey();
#
# // Delete stored key
# await PollinationsApiConfig.deleteApiKey();
# ```

# =============================================================================
# OPTION 2: Environment Variables (For Development)
# =============================================================================
#
# You can use flutter's --dart-define flag:
#
# flutter run --dart-define=POLLINATIONS_API_KEY=your_key_here
#
# Then access it in code:
#
# ```dart
# const apiKey = String.fromEnvironment('POLLINATIONS_API_KEY');
# if (apiKey.isNotEmpty) {
#   await PollinationsApiConfig.setApiKey(apiKey);
# }
# ```

# =============================================================================
# OPTION 3: .env File (For Development with flutter_dotenv)
# =============================================================================
#
# 1. Add flutter_dotenv to pubspec.yaml
# 2. Create .env file in project root:
#
#    POLLINATIONS_API_KEY=your_key_here
#
# 3. Add .env to .gitignore
# 4. Load in main.dart:
#
# ```dart
# import 'package:flutter_dotenv/flutter_dotenv.dart';
#
# await dotenv.load();
# final apiKey = dotenv.env['POLLINATIONS_API_KEY'];
# if (apiKey != null && apiKey.isNotEmpty) {
#   await PollinationsApiConfig.setApiKey(apiKey);
# }
# ```

# =============================================================================
# API ENDPOINTS REFERENCE
# =============================================================================
#
# NEW Text Generation Endpoint:
# POST https://gen.pollinations.ai/v1/chat/completions
# 
# Headers:
#   - Authorization: Bearer YOUR_API_KEY
#   - Content-Type: application/json
#
# Body:
# {
#   "model": "openai",
#   "messages": [
#     {"role": "user", "content": "Hello"}
#   ]
# }
#
# ------------------------------------------
#
# NEW Image Generation Endpoint:
# GET https://gen.pollinations.ai/image/{encoded_prompt}?model=flux
#
# Headers:
#   - Authorization: Bearer YOUR_API_KEY
#
# Query Parameters:
#   - model: flux (default), flux-realism, flux-anime, etc.
#   - width: Image width (e.g., 1024)
#   - height: Image height (e.g., 1024)
#   - seed: Random seed for reproducibility
#   - negative_prompt: What to avoid in generation
#   - nologo: true/false - Remove watermark
#
# =============================================================================
# AVAILABLE MODELS
# =============================================================================
#
# Text Models:
#   - openai (default)
#   - qwen-coder
#   - llama
#   - mistral
#   - deepseek-r1
#
# Image Models:
#   - flux (default)
#   - flux-realism
#   - flux-anime
#   - flux-3d
#   - flux-pro
#   - flux-cablyai
#   - turbo
#   - gptimage
#   - stable-diffusion-xl
#   - realistic-vision
#   - dall-e-3
#   - midjourney-v6
#
# =============================================================================
# SECURITY BEST PRACTICES
# =============================================================================
#
# 1. NEVER hardcode API keys in source code
# 2. ALWAYS use secure storage for runtime key storage
# 3. Add API key files (.env, config files) to .gitignore
# 4. Use environment variables for CI/CD pipelines
# 5. Rotate API keys periodically
# 6. Monitor API usage for unauthorized access
# 7. Use different keys for development and production
#
# =============================================================================
# TROUBLESHOOTING
# =============================================================================
#
# Error: 401 Unauthorized
#   - Check if API key is correctly configured
#   - Verify the key is valid and not expired
#
# Error: 429 Rate Limit
#   - Too many requests - wait and retry
#   - Consider implementing request throttling
#
# Error: Timeout
#   - Check internet connection
#   - Increase timeout duration if needed
#
# Empty Response
#   - Try a different model
#   - Check if prompt is valid
