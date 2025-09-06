import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:dio/dio.dart';
import 'package:flutter_root_checker/flutter_root_checker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
bool _isTypingEffectInProgress = false;
class DeviceSecurity {
  /// ✅ Root/Jailbreak check for Android and iOS
  static Future<bool> isRooted() async {
    try {
      if (Platform.isAndroid) {
        return FlutterRootChecker.isAndroidRoot;
      } else if (Platform.isIOS) {
        return FlutterRootChecker.isIosJailbreak;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// ✅ Emulator detection
  static Future<bool> isEmulator() async {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      final model = android.model.toLowerCase();
      final brand = android.brand.toLowerCase();
      final product = android.product.toLowerCase();

      return model.contains('sdk') ||
          brand.contains('google') ||
          product.contains('emulator') ||
          model.contains('x86') ||
          brand.contains('genymotion');
    }

    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.isPhysicalDevice == false;
    }

    return false;
  }
}void showCuteSnackBar(
  BuildContext context,
  String message, {
  Color? bg,
  Duration? duration,
  String? actionText,
  VoidCallback? onActionTap,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    backgroundColor: bg ?? Colors.green.shade600,
    duration: duration ?? const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    action: (actionText != null && onActionTap != null)
        ? SnackBarAction(
            label: actionText,
            textColor: Colors.amberAccent,
            onPressed: onActionTap,
          )
        : null,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
final ValueNotifier<bool> isImageMode = ValueNotifier(false);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
final Set<String> recentRandomTools = {};

void toggleGlobalDarkMode() {
  isDarkModeNotifier.value = !isDarkModeNotifier.value;
}
class ImageHistoryItem {
  final String prompt;
  final List<String> imageUrls; // 4 URLs
  final List<String> styleNames; // ["Realistic", "Anime", ...]
  final DateTime timestamp;
  final String modelUsed;
  final String templateSize;
  final String? negativePrompt;
  final String? seed;

  ImageHistoryItem({
    required this.prompt,
    required this.imageUrls,
    required this.styleNames,
    required this.timestamp,
    required this.modelUsed,
    required this.templateSize,
    this.negativePrompt,
    this.seed,
  });

  factory ImageHistoryItem.fromJson(Map<String, dynamic> json) {
    return ImageHistoryItem(
      prompt: json['prompt'],
      imageUrls: List<String>.from(json['imageUrls']),
      styleNames: List<String>.from(json['styleNames']),
      timestamp: DateTime.parse(json['timestamp']),
      modelUsed: json['modelUsed'],
      templateSize: json['templateSize'],
      negativePrompt: json['negativePrompt'],
      seed: json['seed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'imageUrls': imageUrls,
      'styleNames': styleNames,
      'timestamp': timestamp.toIso8601String(),
      'modelUsed': modelUsed,
      'templateSize': templateSize,
      'negativePrompt': negativePrompt,
      'seed': seed,
    };
  }
}
 final ValueNotifier<bool> isIncognito = ValueNotifier(false);
    final List<ImageHistoryItem> imageHistory = [];
    final promptController = TextEditingController();
    final widthController = TextEditingController(text: '720'); 
    final heightController = TextEditingController(text: '1280');
     String currentModel = 'FLUX-3D'; String? generatedImageUrl;
final Random _random = Random();
void _showRandomTool(BuildContext context) {
  final blacklistSet = blacklistedNamesNotifier.value.map((e) => e.trim().toLowerCase()).toSet();

  final availableTools = tools.where((t) {
    final name = t['name']?.toString().trim().toLowerCase() ?? '';
    return name.isNotEmpty &&
        !blacklistSet.contains(name) &&
        !recentRandomTools.contains(name);
  }).toList();

  if (availableTools.isEmpty) {
    recentRandomTools.clear();

    
    return;
  }

  final picked = availableTools[_random.nextInt(availableTools.length)];
  final pickedName = picked['name']?.toString().trim().toLowerCase();
  if (pickedName != null) recentRandomTools.add(pickedName);

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => FinalLandingPage(tool: picked)),
  );
}


class ZairokImageHelpers {
  static const List<String> blockedWords = [
    'nsfw', 'nude', 'nudity', 'sex', 'porn', 'sexy', 'erotic', 'fetish',
    'violence', 'bloody', 'gore', 'murder', 'weapon', 'gun', 'kill',
    'terrorist', 'illegal', 'drug', 'abuse', 'rape', 'explosive', 'bomb',
    'breast','vagina','cock','dick','pussy'
  ];
    static const String NegativePrompt = '''
blurry, low quality, low resolution, out of frame, distorted, extra limbs, missing limbs, deformed, poorly drawn, bad anatomy, bad proportions, mutated, ugly, watermark, signature, text, logo, artifacts, jpeg artifacts, cropped, overexposed, underexposed, duplicate, noise, grainy, unnatural colors, wrong perspective, unbalanced lighting, unrealistic, inconsistent lighting, twisted limbs, cloned faces, extra fingers, fused limbs, broken limbs, poorly rendered hands, blurry eyes, asymmetrical face, nsfw, nudity, sex, porn, gore, violence, blood, weapon, breast, vagina
''';

  /// ✅ Build the final image generation URL
static Uri buildImageGenUri({
  required String prompt,
  required String model,
  required String width,
  required String height,
  String? seed,                     // Optional custom seed from user
  String? customNegativePrompt,    // Optional custom negative prompt
}) {
  // ✅ Generate a proper 9-digit seed if blank or null (like Pollinations AI does)
  final finalSeed = (seed != null && seed.trim().isNotEmpty)
      ? seed.trim()
      : (Random().nextInt(900000000) + 100000000).toString();

  // ✅ Encode the prompt and negative prompt
  final encodedPrompt = Uri.encodeComponent(prompt);
  final encodedNegative = Uri.encodeComponent(
    customNegativePrompt ?? NegativePrompt,
  );

  // ✅ Build and return the final image generation URI
  return Uri.parse(
    "https://image.pollinations.ai/prompt/$encodedPrompt"
    "?width=$width"
    "&height=$height"
    "&model=$model"
    "&negative_prompt=$encodedNegative"
    "&seed=$finalSeed"
    "&nologo=true"
    "&upscale=true"
  );
}
  /// ❌ Check blocked content
  static bool containsBlockedWords(String prompt) {
    final lower = prompt.toLowerCase();
    return blockedWords.any((word) => lower.contains(word));
  }

  /// 📋 Copy prompt
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
   showCuteSnackBar(context, "📋 Prompt copied", bg: Colors.grey.shade800);
  }

static Future<void> saveImageToGallery({
  required BuildContext context,
  required String imageUrl,
}) async {
  // 🔐 Request permissions
  bool granted = false;

  if (await Permission.storage.isGranted) {
    granted = true;
  } else {
    final storage = await Permission.storage.request(); // Android < 13
    final photos = await Permission.photos.request();   // Android 13+ & iOS
    granted = storage.isGranted || photos.isGranted;
  }

  if (!granted) {
  showCuteSnackBar(
  context,
  "❌ Storage or media permission denied",
  bg: Colors.red.shade600,
);
    return;
  }

  // 🕒 Auto-generate file name with timestamp
  final now = DateTime.now();
  final formattedName =
      "ZairokAI_${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}";

  try {
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List bytes = Uint8List.fromList(response.data!);

    final result = await SaverGallery.saveImage(
      bytes,
      quality: 100,
      fileName: formattedName,
      androidRelativePath: "Pictures/ZairokAI",
      skipIfExists: false,
    );

   try {
  if (result.isSuccess) {
   showCuteSnackBar(
  context,
  "✅ Saved as $formattedName.jpg",
  bg: Colors.green.shade600,
);
  } else {
    showCuteSnackBar(
  context,
  "❌ Failed to save image",
  bg: Colors.red.shade600,
);
  }
} catch (e) {
  showCuteSnackBar(
  context,
  "❌ Error saving image: $e",
  bg: Colors.red.shade700,
  duration: const Duration(seconds: 4),
);
}
}
  catch (e) {
   showCuteSnackBar(
  context,
  "❌ Error downloading image: $e",
  bg: Colors.red.shade600,
);
  }
}
// 🔹 Helper for formatting 01, 02, etc.
static String _two(int val) => val.toString().padLeft(2, '0');
}
// ✅ FINAL PREMIUM UI IMPLEMENTATION of ZairokImageGenScreen // Note: Backend unchanged. This includes: // 1. Cute popup for filename input (non-blocking UI) // 2. Model selector // 3. Predefined template menu // 4. Regenerate + Clear AI Output // 5. Optional Negative Prompt // 6. Disabled Generate button logic // 7. SafeArea wrapping





class ZairokImageGenScreen extends StatefulWidget {
  final bool isDark;
  final String avatarPath;
  final String userName;
  final VoidCallback onToggleTheme;

  const ZairokImageGenScreen({
    super.key,
    required this.isDark,
    required this.avatarPath,
    required this.userName,
    required this.onToggleTheme,
  });

  @override
  State<ZairokImageGenScreen> createState() => _ZairokImageGenScreenState();
}

class _ZairokImageGenScreenState extends State<ZairokImageGenScreen> {
  final TextEditingController promptController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController seedController = TextEditingController();
final TextEditingController negativePromptController = TextEditingController();
final List<String> templates = [
  // Aspect ratio templates
 

  // Named templates
  'Square',
  'Portrait',
  'Landscape',
  'Custom',
  'Instagram Post',
  'Instagram Story',
  'Wallpaper Mobile',
  'Wallpaper Desktop',
  'Poster',
  'Blog Banner',
   '1:1',
  '9:16',
  '16:9',
  '4:3',
  '3:4',
];
bool isConfirmingClear = false;
 final Map<String, Map<String, String>> templateSizes = {
  // New aspect ratio templates
  '1:1': {'w': '1024', 'h': '1024'},
  '9:16': {'w': '768', 'h': '1365'},
  '16:9': {'w': '1365', 'h': '768'},
  '4:3': {'w': '1024', 'h': '768'},
  '3:4': {'w': '768', 'h': '1024'},

  // Existing templates
  'Square': {'w': '512', 'h': '512'},
  'Portrait': {'w': '512', 'h': '768'},
  'Landscape': {'w': '768', 'h': '512'},
  'Custom': {'w': '', 'h': ''},
  'Instagram Post': {'w': '1080', 'h': '1080'},
  'Instagram Story': {'w': '1080', 'h': '1920'},
  'Wallpaper Mobile': {'w': '1080', 'h': '2400'},
  'Wallpaper Desktop': {'w': '1920', 'h': '1080'},
  'Poster': {'w': '1000', 'h': '1500'},
  'Blog Banner': {'w': '1200', 'h': '500'},
};
  final List<String> modelList = [
    'flux', 'FLUX-3D', 'FLUX-PRO', 'Flux-realism', 'Flux-anime', 'Flux-cablyai', 'turbo','gptimage','stable-diffusion-xl','realistic-vision','dall-e-3','midjourney-v6'
  ];
  bool isIncognito = false;
List<String> generatedImageUrls = [];
final List<String> styleNames = [
  'Realistic',
  'Anime',
  'Painting',
  'Cyberpunk',
];
  String currentTemplate = 'Square';
  String currentModel = 'flux';
  String generatedImageUrl = '';
  bool isImageLoaded = false;
  bool isGenerating = false;
  DateTime? generationStartTime;
  List<String> imageHistory = [];
  final int maxHistoryCount = 150;

 @override
@override
void initState() {
  super.initState();
  isImageMode.value = false;
}
  @override
  void dispose() {
    promptController.dispose();
    widthController.dispose();
    heightController.dispose();
    seedController.dispose();
    negativePromptController.dispose();
    super.dispose();
  }
void generateImage() async {
  final prompt = promptController.text.trim();
  if (prompt.isEmpty || isGenerating) return;

  setState(() {
    isGenerating = true;
    generatedImageUrls.clear(); // Clear previous results
  });

  final width = currentTemplate == "Custom"
      ? widthController.text.trim()
      : templateSizes[currentTemplate]!['w']!;
  final height = currentTemplate == "Custom"
      ? heightController.text.trim()
      : templateSizes[currentTemplate]!['h']!;

  final String? seedInput = seedController.text.trim().isNotEmpty
      ? seedController.text.trim()
      : null;

  final String? customNegativePrompt = negativePromptController.text.trim().isNotEmpty
      ? negativePromptController.text.trim()
      : null;

  final stylePrompts = {
    'Realistic': '$prompt, highly detailed photorealistic, 8k ultra HD, intricate, professional',
    'Anime': '$prompt, anime style, vibrant colors, cel-shaded, Studio Ghibli inspired, 4k resolution, ultra',
    'Painting': '$prompt, masterpiece oil painting style, brush strokes, artistic, impressionist',
    'Cyberpunk': '$prompt, cyberpunk style, neon lights, futuristic, sci-fi, Blade Runner inspired, 8k, ultra',
  };

  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList('zairok_image_history') ?? [];

  for (final style in styleNames) {
    final styledPrompt = stylePrompts[style]!;

    final uri = ZairokImageHelpers.buildImageGenUri(
      prompt: styledPrompt,
      model: currentModel,
      width: width,
      height: height,
      seed: seedInput,
      customNegativePrompt: customNegativePrompt,
    );

    await Future.delayed(const Duration(seconds: 2)); // Simulate generation

    setState(() {
      generatedImageUrls.add(uri.toString());
      generatedImageUrl = uri.toString(); // Optional: last used
      generationStartTime = DateTime.now();
    });

    // Save to history (skip if incognito)
    if (!isIncognito) {
      final entry = jsonEncode({
        'prompt': prompt,
        'url': uri.toString(),
        'model': currentModel,
        'width': width,
        'height': height,
        'seed': seedInput ?? "random",
        'negative_prompt': customNegativePrompt ?? ZairokImageHelpers.NegativePrompt,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (!history.contains(entry)) {
        history.insert(0, entry);
        if (history.length > 60) {
          history = history.sublist(0, 60);
        }
      }
    }
  }

  if (!isIncognito) {
    await prefs.setStringList('zairok_image_history', history);
  }

  setState(() => isGenerating = false);
}
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final fillColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 6,
        backgroundColor: (isDark ? Colors.black : Colors.white).withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: FittedBox(
  fit: BoxFit.scaleDown,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
  Icons.flash_on_rounded,
  color: isIncognito ? Colors.purple : Colors.orange,
  size: 22,
),
      const SizedBox(width: 6),
      const Text(
        "Zairok AI",
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 18),
      ),
    ],
  ),
),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainUIScreen(
                  isDarkModeNotifier: ValueNotifier(isDark),
                  userName: widget.userName,
                  avatarPath: widget.avatarPath,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
        ),
actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Row(
      children: [
        Text(
          'Zairok LLM',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            // 1. Update value to trigger animation
            isImageMode.value = true;

            // 2. Wait for animation to complete visually (300ms match AnimatedAlign)
            await Future.delayed(const Duration(milliseconds: 300));

            // 3. Navigate after animation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ZairokTextScreen(
                  isDark: widget.isDark,
                  userName: widget.userName,
                  avatarPath: widget.avatarPath,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
          child: ValueListenableBuilder(
            valueListenable: isImageMode,
            builder: (context, isOn, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 58,
                height: 28,
                decoration: BoxDecoration(
                  color: isOn ? Colors.orange : Colors.grey[600],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
],
      ),
      body: SafeArea(
        child: ListView(
  padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), // bottom = ad spaceQ
          children: [
         Padding(
  padding: const EdgeInsets.only(right: 3),
  child: Align(
    alignment: Alignment.topRight,
    child: GestureDetector(
      onTap: () {
        setState(() {
          isIncognito = !isIncognito;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:  Colors.orange.shade300.withAlpha((0.08 * 255).toInt()), // light orange background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncognito ? Icons.visibility_off : Icons.visibility,
              color: isIncognito ? Colors.orange : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              isIncognito ? 'Incognito On' : 'Incognito Off',
              style: TextStyle(
                fontSize: 14,
                color: isIncognito ? Colors.orange : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
SizedBox(height:4),
            const Text("Prompt", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: promptController,
              maxLines: null,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Describe your idea: objects, colors, places...",
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(height: 16),
            _buildTemplateDropdown(textColor),
            const SizedBox(height: 12),
            if (currentTemplate == "Custom") _buildCustomSizeFields(textColor),
            const SizedBox(height: 16),
            _buildModelSelector(textColor),
            const SizedBox(height: 16),
Text("Advanced Options", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
const SizedBox(height: 10),

Row(
  children: [
    // 🔸 Seed Field (Small)
    Expanded(
      flex: 2,
      child: TextField(
        controller: seedController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Seed(optional)",
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
    const SizedBox(width: 12),
    const Spacer(flex: 3),
  ],
),
const SizedBox(height: 16),

TextField(
  controller: negativePromptController,
  maxLines: null,
  style: TextStyle(color: textColor),
  decoration: InputDecoration(
    hintText: "Negative prompt (optional)",
    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
    filled: true,
    fillColor: fillColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  ),
),
        Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    TextButton.icon(
      onPressed: _showHistoryModal,
      icon: const Icon(Icons.history, color: Colors.orange),
      label: const Text("View History"),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          fontSize: 13.5,
        ),
      ),
    ),
  ],
),
const SizedBox(height: 10),
            const SizedBox(height: 40),
            _buildGenerateButton(),
            const SizedBox(height: 10), 

              
            if (generatedImageUrl.isNotEmpty) _buildImagePreview(textColor),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
  child: SizedBox(
    height: 60, // fixed height to prevent overflow
    child: const BottomAdaptiveBannerAd(
      adUnitId: 'ca-app-pub-1372661529203718/5037632231',
    ),
  ),
),
    );    
  }

Widget _buildTemplateDropdown(Color textColor) {
  return Row(
    children: [
      const Text("Template: ", style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 10),
      Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color.fromARGB(255, 77, 69, 69) // Dark soft
              : Colors.orange.shade300.withAlpha((0.08 * 255).toInt()), // Light soft
          borderRadius: BorderRadius.circular(30),
        ),
        child: PopupMenuButton<String>(
          initialValue: currentTemplate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: widget.isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          offset: const Offset(0, 40),
          color: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          elevation: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_view_rounded,
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                currentTemplate,
                style: TextStyle(
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.expand_more,
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  size: 18),
            ],
          ),
          onSelected: (value) => setState(() => currentTemplate = value),
          itemBuilder: (ctx) => templates.map((label) {
            final isSelected = currentTemplate == label;
            return PopupMenuItem(
              value: label,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isSelected
                        ? (widget.isDark ? Colors.orange.shade300 : Colors.orange)
                        : (widget.isDark ? Colors.grey.shade400 : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? (widget.isDark ? Colors.orange.shade300 : Colors.orange)
                          : textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
  Widget _buildCustomSizeFields(Color textColor) {
    return Row(
      children: [
        _buildSizeField("Width", widthController, textColor),
        const SizedBox(width: 12),
        _buildSizeField("Height", heightController, textColor),
      ],
    );
  }

  Widget _buildSizeField(String label, TextEditingController controller, Color textColor) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
 Widget _buildInfoRow(String title, String value, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: TextStyle(
            fontSize: 13.5, // Match your Prompt font size
            fontWeight: FontWeight.w500, // Match your Prompt weight
            color: isDark ? const Color.fromARGB(255, 63, 61, 61) : Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}void _showHistoryModal() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList('zairok_image_history') ?? [];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Title + Clear Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Generation History",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
TextButton.icon(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14,14,14,20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Clear image history?",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                    tooltip: "Cancel",
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                    tooltip: "Confirm",
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('zairok_image_history');
                      setState(() => history = []);
                      Navigator.pop(context);
                      showCuteSnackBar(context, "✅ History cleared", bg: Colors.green);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  },
  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
  label: const Text(
    "Clear",
    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
  ),
),      ],
                ),

                const SizedBox(height: 12),

                // Empty State
                if (history.isEmpty)
                  Column(
                    children: const [
                      Icon(Icons.hourglass_empty_rounded, size: 40, color: Colors.orange),
                      SizedBox(height: 12),
                      Text("You're all caught up!", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text("Nothing in history yet 😊", style: TextStyle(fontSize: 13.5, color: Colors.grey)),
                      SizedBox(height: 20),
                    ],
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final decoded = jsonDecode(history[index]) as Map<String, dynamic>;
                        final prompt = decoded['prompt'] ?? '';
                        final url = decoded['url'] ?? '';
                        final timestamp = DateTime.tryParse(decoded['timestamp'] ?? '');
                        final model = decoded['model'] ?? 'Flux';
                        final negativePrompt = decoded['negativePrompt'] ?? '';
                        final seed = decoded['seed'];
                        final width = decoded['width'];
                        final height = decoded['height'];
                        final template = decoded['templateSize'];

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            final removed = history[index];
                            setState(() => history.removeAt(index));
                            await prefs.setStringList('zairok_image_history', history);

                            showCuteSnackBar(
                              context,
                              "🗑️ Deleted",
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.isDark ? Colors.grey[850] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "Copy prompt",
                                          icon: const Icon(Icons.copy, size: 20, color: Colors.orange),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: prompt));
                                            showCuteSnackBar(context, "📋 Prompt copied!", duration: const Duration(seconds: 1));
                                          },
                                        ),
                                        IconButton(
                                          tooltip: "Download image",
                                          icon: const Icon(Icons.download_rounded, size: 20, color: Colors.orange),
                                          onPressed: () {
                                            ZairokImageHelpers.saveImageToGallery(
                                              context: context,
                                              imageUrl: url,
                                            );
                                  showCuteSnackBar(context, "Image Downloaded Successfullly", duration: const Duration(seconds: 1));

                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow("Prompt", prompt, widget.isDark),
                                      const SizedBox(height: 4),
                                      _buildInfoRow("Model", model, widget.isDark),
                                      if (template != null)
                                        _buildInfoRow("Template", template, widget.isDark)
                                      else if (width != null && height != null)
                                        _buildInfoRow("Size", "$width × $height", widget.isDark),
                                      if (seed != null)
                                        _buildInfoRow("Seed", seed.toString(), widget.isDark),
                                      if (timestamp != null)
                                        _buildInfoRow(
                                          "Time",
                                          "${timestamp.toLocal()}".split('.')[0].replaceAll('T', ' '),
                                          widget.isDark,
                                        ),
                                      if (negativePrompt.trim().isNotEmpty)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoRow("Negative Prompt", negativePrompt, widget.isDark),
                                            ),
                                            IconButton(
                                              tooltip: "Copy negative prompt",
                                              icon: const Icon(Icons.copy, size: 20, color: Colors.purple),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: negativePrompt));
                                                showCuteSnackBar(context, "📋 Negative prompt copied!", duration: const Duration(seconds: 1));
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      });
    },
  );
}Widget _buildModelSelector(Color textColor) {
  return Row(
    children: [
      const Text("Model:       ", style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 10),
      Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color.fromARGB(255, 77, 69, 69) // soft dark
              : Colors.orange.shade300.withAlpha((0.08 * 255).toInt()), // soft light
          borderRadius: BorderRadius.circular(30),
        ),
        child: PopupMenuButton<String>(
          initialValue: currentModel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: widget.isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          offset: const Offset(0, 40),
          color: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          elevation: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune,
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                currentModel,
                style: TextStyle(
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.expand_more,
                  color: widget.isDark ? Colors.orange.shade300 : Colors.orange,
                  size: 18),
            ],
          ),
          onSelected: (value) => setState(() => currentModel = value),
          itemBuilder: (ctx) => modelList.map((label) {
            final isSelected = currentModel == label;
            return PopupMenuItem(
              value: label,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isSelected
                        ? (widget.isDark ? Colors.orange.shade300 : Colors.orange)
                        : (widget.isDark ? Colors.grey.shade400 : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? (widget.isDark ? Colors.orange.shade300 : Colors.orange)
                          : textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}Widget _buildGenerateButton() {
  final isDark = widget.isDark;
  final backgroundColor = isDark ?  Colors.orange : Colors.orange;
  final textColor = isDark ? Colors.black : Colors.white;

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
              ElevatedButton(
                onPressed: isGenerating?null:generateImage,
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.flash_on_rounded, size: 20),
                    SizedBox(width: 7),
                    Text(
                      "Generate",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
        if (isGenerating)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Please wait... image will be generated soon",
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.black54,
                fontSize: 13.5,
              ),
            ),
          ),
      ],
    ),
  );
}Widget _buildImagePreview(Color textColor) {
  if (generatedImageUrls.isEmpty && !isGenerating) return const SizedBox.shrink();

  final screenHeight = MediaQuery.of(context).size.height;
  final imageHeight = screenHeight * 0.35;

  if (isGenerating) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: imageHeight * 2 + 24,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: generatedImageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final url = generatedImageUrls[index];
        final style = styleNames[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.isDark ? Colors.grey[900] : Colors.grey[200],
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  style,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text("Download", style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ZairokImageHelpers.saveImageToGallery(
                    context: context,
                    imageUrl: url,
                  );
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    ),
  );
}
}

class ZairokTextScreen extends StatefulWidget {
  final bool isDark;
  final String avatarPath;
  final String userName;
  final VoidCallback onToggleTheme;

  const ZairokTextScreen({
    super.key,
    required this.isDark,
    required this.avatarPath,
    required this.userName,
    required this.onToggleTheme,
  });

  @override
  State<ZairokTextScreen> createState() => _ZairokTextScreenState();
}

class _ZairokTextScreenState extends State<ZairokTextScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String> avatarNotifier = ValueNotifier('assets/profile1.jpg');
  final ValueNotifier<List<Map<String, dynamic>>> messages = ValueNotifier([]);
  final List<String> modelList = ["openai", "qwen-coder", "llama", "mistral", "deepseek-r1"];
  String currentModel = "mistral";
  bool isIncognito = false;
  String ? currentChatKey;
  bool isGenerating = false;
  final ValueNotifier<String> typingText = ValueNotifier("Zairok is typing.");
  Timer? typingTimer;
  bool isSending = false;
  bool isStoppedByUser=false;
  http.Client?activeClient;

  bool useTextModel = true;
  Offset? _tapPosition;
  late Box chatBox;
  String? lastAIPrompt;    
bool _showScrollToBottom = false;     // Stores the previous AI prompt
bool expectingFollowUp = false;
bool isFABVisible = true;
bool isAnimatingFAB = false;
bool shouldStop =  false;
String partialOutput='';
Offset fabPosition = const Offset(300, 500);
String? renamingChatKey;
final renameController = TextEditingController();
String? currentlyRenamingKey;
bool isDragging = false;
int? editingIndex; // Track which message is being edited
  final TextEditingController _emojiInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
  final threshold = 300.0;
  final shouldShow = _scrollController.offset < _scrollController.position.maxScrollExtent - threshold;

  if (_showScrollToBottom != shouldShow) {
    setState(() => _showScrollToBottom = shouldShow);
  }
});
    chatBox=Hive.box('chatBox');
    _loadLastUsedChat();
    isImageMode.value = false; // Ensure image mode is OFF
    _loadAvatar();
  }

  @override
  void dispose() {
   _emojiInputController.dispose();
   renameController.dispose();
    super.dispose();
  }
final List<String> blockedPrompts = [
  "who created zairok",
  "who is your creator",
  "who made you",
  "who built you",
];
void _updateBotTyping(String text) {
  final currentMessages = List<Map<String, dynamic>>.from(messages.value);
  if (currentMessages.isNotEmpty && currentMessages.last['role'] == 'typing') {
    currentMessages.last['text'] = text;
    messages.value = currentMessages;
  }
}
void _stopGeneration() {
  isStoppedByUser = true;
  activeClient?.close(); // abort HTTP request
  isSending = false;
}
  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("avatarPath") ?? widget.avatarPath;
    avatarNotifier.value = path;
  }

void _startTypingAnimation() {
  int dotCount = 1;
  typingTimer?.cancel(); // cancel if already running
  typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    typingText.value = "Zairok is typing${'.' * dotCount}";
    dotCount = (dotCount % 3) + 1; // cycle 1 → 2 → 3 → 1
  });
}
void _loadLastUsedChat() {
  if (chatBox.isEmpty || isIncognito) {
    createNewChat();
    return;
  }

  // Filter only valid entries with 'lastUsed'
  final validChats = chatBox.keys.where((key) {
    final raw = chatBox.get(key);
    return raw is Map && raw.containsKey('lastUsed');
  }).toList();

  if (validChats.isEmpty) {
    createNewChat();
    return;
  }

  validChats.sort((a, b) {
    final aRaw = chatBox.get(a);
    final bRaw = chatBox.get(b);

    final aData = aRaw is Map ? Map<String, dynamic>.from(aRaw) : {};
    final bData = bRaw is Map ? Map<String, dynamic>.from(bRaw) : {};

    return (bData['lastUsed'] ?? 0).compareTo(aData['lastUsed'] ?? 0);
  });

  final lastUsedKey = validChats.first;
  loadChat(lastUsedKey);
}
String _generateZairokChatTitle() {
  final allChats = chatBox.toMap();
  int count = 1;

  final existingTitles = allChats.values
      .map((e) => (e as Map)['title']?.toString() ?? "")
      .where((title) => title.startsWith("Zairok Chat"))
      .toList();

  while (existingTitles.contains("Zairok Chat $count")) {
    count++;
  }

  return "Zairok Chat $count";
}
//done
void toggleIncognitoMode() {
  setState(() {
    isIncognito = !isIncognito;

    if (isIncognito) {
      currentChatKey = null;
      messages.value = []; // Clear messages for incognito session
    } else {
      // Slight delay to allow UI to settle before reloading chat
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _loadLastUsedChat();
      });
    }
  });
}void createNewChat() {
  final key = DateTime.now().millisecondsSinceEpoch.toString();

  if (!isIncognito) {
    final newChat = {
      "title": _generateZairokChatTitle(),
      "pinned": false,
      "lastUsed": DateTime.now().millisecondsSinceEpoch,
      "messages": <Map<String, dynamic>>[], // Explicit list type
    };

    chatBox.put(key, newChat);

    setState(() {
      currentChatKey = key;
      messages.value = [];
    });
  } else {
    setState(() {
      currentChatKey = null;
      messages.value = [];
    });
  }
}
void loadChat(String key) {
  final raw = chatBox.get(key);

  if (raw is Map) {
    try {
      final chat = Map<String, dynamic>.from(raw);
      final loadedMessages = (chat['messages'] as List?)
              ?.whereType<Map>()
              .map((msg) => Map<String, dynamic>.from(msg))
              .toList() ??
          [];

      setState(() {
        currentChatKey = key;
        messages.value = loadedMessages;
      });
    } catch (e) {
    }
  }
}
Future<void> deleteChat(String key) async {
  await chatBox.delete(key);

  if (key == currentChatKey) {
    currentChatKey = null;
    messages.value = []; // just clear messages
    setState(() {});     // update drawer or title
  } else {
    setState(() {});     // refresh list
  }
}
Widget buildZairokDrawer({
  required bool isDark,
  required Map<dynamic, dynamic> allChats,
  required String? currentChatKey,
  required Function(String key) onChatSelect,
  required Function(String key) onDelete,
  required Function(String key) onPinToggle,
  required Function(String key) onRename,
  required VoidCallback onNewChat,
  required VoidCallback onToggleIncognito,
}) {
  final sortedKeys = allChats.keys.toList()
    ..sort((a, b) {
      final aData = Map<String, dynamic>.from(allChats[a] ?? {});
      final bData = Map<String, dynamic>.from(allChats[b] ?? {});
      final aPinned = aData['pinned'] == true;
      final bPinned = bData['pinned'] == true;

      if (aPinned != bPinned) {
        return bPinned ? 1 : -1;
      }

      return (bData['lastUsed'] ?? 0).compareTo(aData['lastUsed'] ?? 0);
    });

  return Drawer(
    backgroundColor: isDark ? Colors.grey[900] : Colors.white,
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),

         ListTile(
  leading: Icon(
    isIncognito ? Icons.visibility : Icons.visibility_off_outlined,
    color: isIncognito
        ? Colors.purple
        : (isDark ? Colors.orange : Colors.black87),
  ),
  title: const Text(
    "Incognito Mode",
    style: TextStyle(fontWeight: FontWeight.w600),
  ),
  onTap: onToggleIncognito,
),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.orange),
            title: const Text("New Zairok Chat", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: onNewChat,
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final chatData = Map<String, dynamic>.from(allChats[key] ?? {});

                final isCurrent = key == currentChatKey;
                final isPinned = chatData['pinned'] == true;
                final title = chatData['title'] ?? "Chat";

               if (currentlyRenamingKey == key) {
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  child: Container(
    height: 60, // ✅ increase height for roomy UI
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.15), // ✅ full orange fill (vertical look)
      borderRadius: BorderRadius.circular(15), // ✅ slightly rounded (remove if unwanted)
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Icon(Icons.edit_note_rounded, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: renameController,
            autofocus: true,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Rename",
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14), // ✅ taller field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) async {
              final newTitle = value.trim();
              if (newTitle.isNotEmpty) {
                allChats[key]?['title'] = newTitle;
                await chatBox.put(key, allChats[key]);
              }
              setState(() => currentlyRenamingKey = null);
            },
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () async {
            final newTitle = renameController.text.trim();
            if (newTitle.isNotEmpty) {
              allChats[key]?['title'] = newTitle;
              await chatBox.put(key, allChats[key]);
            }
            setState(() => currentlyRenamingKey = null);
          },
          child: const Text("Rename", style: TextStyle(color: Colors.orange)),
        ),
        TextButton(
          onPressed: () {
            setState(() => currentlyRenamingKey = null);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black54),
          ),
        ),
      ],
    ),
  ),
);
} else {
  return ListTile(
    selected: isCurrent,
    selectedTileColor: Colors.orange.withOpacity(0.1),
    leading: Icon(
      isPinned ? Icons.push_pin : Icons.chat_bubble_outline,
      color: isCurrent ? Colors.orange : Colors.grey,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        color: isCurrent ? Colors.orange : (isDark ? Colors.white : Colors.black),
      ),
    ),
    onTap: () => onChatSelect(key),
    trailing: PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'rename':
            // ✅ Defer to avoid drawer auto-close
            await Future.delayed(const Duration(milliseconds: 100));
            renameController.text = allChats[key]?['title'] ?? 'Chat';
            setState(() => currentlyRenamingKey = key);
            break;
          case 'pin':
            onPinToggle(key);
            break;
          case 'delete':
            onDelete(key);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: const [
              Icon(Icons.edit, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Text("Rename"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              Text(isPinned ? "Unpin" : "Pin"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Delete"),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      elevation: 12,
    ),
  );
}
              }
            ),
          ),
        ],
      ),
    ),
  );
}
void togglePinChat(String key) {
  final raw = chatBox.get(key);
  if (raw is! Map) return;

  try {
    final chatData = Map<String, dynamic>.from(raw);
    chatData['pinned'] = !(chatData['pinned'] == true); // toggle logic

    chatBox.put(key, chatData);
    setState(() {}); // Refresh UI
  } catch (e) {
  }
}
void renameChat(BuildContext context, String key) {
  final raw = chatBox.get(key);
  if (raw is! Map) return;

  Map<String, dynamic> chatData;
  try {
    chatData = Map<String, dynamic>.from(raw);
  } catch (_) {
    return; // silently fail if casting fails
  }

  final controller = TextEditingController(text: chatData['title'] ?? "Chat");

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Rename Chat"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Enter new name",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty) {
              chatData['title'] = newName;
              chatBox.put(key, chatData);
              setState(() {});
            }
            Navigator.pop(context);
          },
          child: const Text("Rename", style: TextStyle(color: Colors.orange)),
        ),
      ],
    ),
  );
}void _addPredefinedBotReply(String userPrompt) {
  messages.value.add({"role": "user", "text": userPrompt});
  messages.value.add({
    "role": "ai",
    "text": "🤖 I'm Zairok — your AI companion built to help you discover powerful tools and generate creative content. Crafted by Lohit (a.k.a. AarushLohit), a 17-year-old dev, and powered by open-source models and projects. Let's explore!",
    "seen": true,
    "prompt": userPrompt,
  });
  messages.notifyListeners();
  isSending = false;
  typingText.value = "";
  _scrollToBottom();
}Future<void> _sendPrompt(String prompt, {bool isRegenerate = false}) async {
  final trimmedPrompt = prompt.trim();
  if (trimmedPrompt.isEmpty || isSending) return;
  if (blockedPrompts.any((q) => prompt.contains(q))) {
  setState(() {
    isGenerating = false; // Immediately stop any spinner / stop button
  });
  _addPredefinedBotReply(prompt); // Add the template reply
  return;
}

  

  final newMessages = List<Map<String, dynamic>>.from(messages.value);
  String promptToSend = trimmedPrompt;

  if (editingIndex != null) {
    newMessages[editingIndex!] = {'role': 'user', 'text': trimmedPrompt};
    if (editingIndex! + 1 < newMessages.length) {
      newMessages.removeRange(editingIndex! + 1, newMessages.length);
    }
    editingIndex = null;
  } else if (isRegenerate) {
    if (newMessages.isNotEmpty && newMessages.last['role'] == 'typing') {
      newMessages.removeLast();
    }
    if (newMessages.isNotEmpty && newMessages.last['role'] == 'ai') {
      newMessages.removeLast();
    }
    final typingMsg = newMessages.lastWhere(
      (msg) => msg['role'] == 'typing',
      orElse: () => {},
    );
    promptToSend = typingMsg['prompt'] ?? promptToSend;
  } else {
    newMessages.add({"role": "user", "text": trimmedPrompt});
  }

  newMessages.add({"role": "typing", "prompt": promptToSend});
  _startTypingAnimation();
  messages.value = newMessages;

  isSending = true;
  isGenerating = true;
  shouldStop = false;
  _controller.clear();
  _scrollToBottom();

  // Build context buffer
  final buffer = StringBuffer();
  const maxPairs = 6;
  int pairsUsed = 0;

  for (int i = newMessages.length - 1; i >= 0 && pairsUsed < maxPairs; i--) {
    final msg = newMessages[i];
    if (msg['role'] == 'ai') {
      final userMsg = _findPreviousUserMessage(i, newMessages);
      if (userMsg != null) {
        buffer.write("User: ${userMsg['text']}\nAI: ${msg['text']}\n\n");
        pairsUsed++;
      }
    }
  }

  buffer.write("User: $promptToSend\nAI:");
  final fullPrompt = buffer.toString();
  final uri = Uri.parse(
    "https://text.pollinations.ai/User:${Uri.encodeComponent(fullPrompt)}?model=$currentModel",
  );

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      String fullReply = response.body.trim();
      String shownReply = "";

      for (int i = 0; i < fullReply.length; i++) {
        if (shouldStop) {
          break;
        }
        shownReply += fullReply[i];
        _updateBotTyping(shownReply);
        await Future.delayed(const Duration(milliseconds: 20));
      }

      _addBotReply(shownReply);
    } else {
      _addBotReply("⚠️ Server Busy. Please try again or switch models.");
    }
  } catch (e) {
    _addBotReply("❌ Error: ${e.toString()}");
  } finally {
    // ✅ Ensure flags are updated only after typing finishes or is aborted
    setState(() {
      isGenerating = false;
      isSending = false;
      shouldStop = false;
    });
  }
}
Map<String, dynamic>? _findPreviousUserMessage(int aiIndex, List<Map<String, dynamic>> list) {
  if (aiIndex <= 0 || aiIndex > list.length - 1) return null;

  for (int j = aiIndex - 1; j >= 0; j--) {
    final msg = list[j];
    if (msg['role'] == 'user' && msg['text'] != null) {
      return msg;
    }
  }
  return null;
}OverlayEntry? _emojiOverlayEntry;
void _showEmojiReactOverlay(BuildContext context, int index) {
  _emojiOverlayEntry?.remove();
  _emojiOverlayEntry = null;

  final overlay = Overlay.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? Colors.grey[900]! : Colors.white;

  final screenSize = MediaQuery.of(context).size;
  final double top = screenSize.height / 2 - 50;
  final double left = screenSize.width / 2 - 150;

  bool showInput = false;

  _emojiOverlayEntry = OverlayEntry(
    builder: (context) => StatefulBuilder(
      builder: (context, setInner) {
        return Positioned(
          top: top,
          left: left,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                if (!showInput) ...[
  ...["👍", "❤️", "😂", "😮", "🥹", "🙏"].map(
    (emoji) => GestureDetector(
      onTap: () {
        final current = messages.value[index]['reaction'];
        setState(() {
          messages.value[index]['reaction'] =
              (current == emoji) ? null : emoji;
        });
        _emojiOverlayEntry?.remove();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    ),
  ),
  GestureDetector(
    onTap: () async {
      _emojiOverlayEntry?.remove(); // close popup first
      final emoji = await _showCustomEmojiInput(context);
      if (emoji != null && emoji.trim().isNotEmpty) {
        final current = messages.value[index]['reaction'];
        setState(() {
          messages.value[index]['reaction'] =
              (current == emoji) ? null : emoji;
        });
      }
    },
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.add_circle, color: Colors.orange, size: 26),
    ),
  ),
],
                 
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  overlay.insert(_emojiOverlayEntry!);
}
Future<String?> _showCustomEmojiInput(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Custom Emoji"),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22),
        decoration: const InputDecoration(hintText: "🙂", counterText: ""),
        onSubmitted: (val) => Navigator.pop(context, val.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text("OK", style: TextStyle(color: Colors.orange)),
        )
      ],
    ),
  );
}
void _scrollToBottom() { if (_scrollController.hasClients) { _scrollController.animateTo( _scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, ); } }

void scrollToBottom() { WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollController.hasClients) { _scrollController.animateTo( _scrollController.position.maxScrollExtent + 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, ); } }); }
void _addBotReply(String fullText) async {
  final currentMessages = List<Map<String, dynamic>>.from(messages.value);

  if (currentMessages.isNotEmpty && currentMessages.last['role'] == 'typing') {
    final typingMsg = currentMessages.removeLast();

    final aiMessage = {
      "role": "ai",
      "text": "",
      "seen": true,
      "prompt": typingMsg["prompt"],
    };
    currentMessages.add(aiMessage);
    messages.value = List.from(currentMessages);

    final index = messages.value.length - 1;
    final chars = fullText.characters.toList();

    _isTypingEffectInProgress = true;

    for (int i = 0; i < chars.length; i++) {
      if (!_isTypingEffectInProgress || shouldStop) break;

      await Future.delayed(const Duration(milliseconds: 20));

      final temp = List<Map<String, dynamic>>.from(messages.value);
      if (index < temp.length && temp[index]['role'] == 'ai') {
        temp[index]['text'] += chars[i];
        messages.value = List.from(temp);
      }
    }

    // ✅ Finalize state
    _isTypingEffectInProgress = false;
    shouldStop = false;
    isSending = false;
    isGenerating = false;  // ✅ KEY LINE
    setState(() {});       // ✅ Reflect UI update

    typingTimer?.cancel();
    typingText.value = "";
    _scrollToBottom();

    if (!isIncognito && currentChatKey != null) {
      final currentData = Map<String, dynamic>.from(chatBox.get(currentChatKey) ?? {});
      chatBox.put(currentChatKey, {
        "title": currentData["title"] ?? _generateZairokChatTitle(),
        "pinned": currentData["pinned"] ?? false,
        "lastUsed": DateTime.now().millisecondsSinceEpoch,
        "messages": messages.value,
      });
    }
  } else {
    isSending = false;
    _isTypingEffectInProgress = false;
    isGenerating = false;  // ✅ ensure button resets
    setState(() {});
  }
}Map<String, Map<String, dynamic>> _getSafeChatMap() {
  final rawMap = chatBox.toMap();

  return Map.fromEntries(
    rawMap.entries.map((entry) {
      final key = entry.key.toString(); // Ensure String key
      final value = entry.value;

      if (value is Map) {
        try {
          return MapEntry(key, Map<String, dynamic>.from(value));
        } catch (_) {
          // Catch invalid map casting
          return MapEntry(key, <String, dynamic>{});
        }
      } else {
        // If value is not a Map at all
        return MapEntry(key, <String, dynamic>{});
      }
    }),
  );
}
void _handleLongPress(Map<String, dynamic> msg, int index, bool isUser) async {
  _tapPosition ??= const Offset(100, 100);
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  final items = isUser
      ? [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: Colors.orange),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, size: 18, color: Colors.blueGrey),
                SizedBox(width: 10),
                Text('Copy'),
              ],
            ),
          ),
        ]
      : [
          const PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, size: 18, color: Colors.blueGrey),
                SizedBox(width: 10),
                Text('Copy'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'react',
            child: Row(
              children: [
                Icon(Icons.emoji_emotions_outlined, size: 18, color: Colors.amber),
                SizedBox(width: 10),
                Text('React'),
              ],
            ),
          ),
        ];

  final result = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(_tapPosition!.dx, _tapPosition!.dy, 0, 0),
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.black12,
      ),
    ),
    elevation: 10,
    items: items,
  );

  if (result == 'copy') {
    Clipboard.setData(ClipboardData(text: msg['text']));
  } else if (result == 'delete') {
    setState(() {
      messages.value.removeAt(index);
    });
 } else if (result == 'edit') {
  editingIndex = index; // 🆕 Store the editing message's index
  _controller.text = msg['text'];

  // Optional: focus text field again
  Future.delayed(Duration(milliseconds: 100), () {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).requestFocus(FocusNode());
  });
} else if (result == 'react') {
    _emojiOverlayEntry?.remove();
    await Future.delayed(const Duration(milliseconds: 10));
    _showEmojiReactOverlay(context, index);
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

@override Widget build(BuildContext context) { final isDark = Theme.of(context).brightness == Brightness.dark; final bg = isDark ? Colors.black : Colors.white; final textC = isDark ? Colors.white : Colors.black;
return Scaffold(
  key: _scaffoldKey,
  backgroundColor: bg,
  extendBodyBehindAppBar: true,
  drawerEnableOpenDragGesture: false,
  drawer: buildZairokDrawer(
    isDark: widget.isDark,
    allChats: _getSafeChatMap(),
    currentChatKey: currentChatKey,
    onChatSelect: (key) {
      Navigator.pop(context);
      loadChat(key);
    },
    onNewChat: () {
    
      createNewChat();
    },
    onDelete: (key) {
      
      deleteChat(key);
    },
    onPinToggle: (key) {
     
      togglePinChat(key);
    },
    onRename: (key) {
   // You can keep or remove this based on preference
  final raw = chatBox.get(key);
  if (raw is Map) {
    final title = raw['title'] ?? "Chat";
    renameController.text = title;
    setState(() {
      currentlyRenamingKey = key;
    });
  }
},
    onToggleIncognito: () {
      Navigator.pop(context);
      toggleIncognitoMode();
    },
  ),
 
  appBar: AppBar(
    automaticallyImplyLeading: false,
    elevation: 6,
    centerTitle: true,
    backgroundColor: bg.withOpacity(0.95),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: textC),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainUIScreen(
              isDarkModeNotifier: ValueNotifier(widget.isDark),
              userName: widget.userName,
              avatarPath: widget.avatarPath,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      },
    ),
title: FittedBox(
  fit: BoxFit.scaleDown,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4), // move away from edge
        child: IconButton(
          icon: Icon(Icons.menu, color: Colors.orange, size: 22),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        Icons.flash_on_rounded,
        color: isIncognito ? Colors.purple : Colors.orange,
        size: 22,
      ),
      const SizedBox(width: 6),
      Text(
        "Zairok AI",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    ],
  ),
),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          children: [
            Text(
              'Image Gen',
              style: TextStyle(
                color: textC,
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                isImageMode.value = true;
                await Future.delayed(const Duration(milliseconds: 400));
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZairokImageGenScreen(
                      isDark: widget.isDark,
                      userName: widget.userName,
                      avatarPath: widget.avatarPath,
                      onToggleTheme: widget.onToggleTheme,
                    ),
                  ),
                );
              },
              child: ValueListenableBuilder(
                valueListenable: isImageMode,
                builder: (context, isOn, _) {
                  return Container(
                    width: 58,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isOn ? Colors.orange : Colors.grey[600],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment:
                          isOn ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  body: Stack(
    children : [SafeArea(
      child: Column(
        children: [
          // ✅ FIXED MESSAGES RENDERING
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: messages,
              builder: (context, msgList, _) {
                if (msgList.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.grey[850]
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "Hi! I am Zairok AI. How can I help you today?",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
    
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgList.length,
                  itemBuilder: (context, index) {
                    final msg = msgList[index];
                    final isUser = msg['role'] == 'user';
                    final isTyping = msg['role'] == 'typing';
                    final isAI = msg['role'] == 'ai';
    
                    return GestureDetector(
                      onTapDown: (details) =>
                          _tapPosition = details.globalPosition,
                      onLongPress: () =>
                          _handleLongPress(msg, index, isUser),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            const CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/zairokai.jpg"),
                                radius: 16),
                          if (!isUser) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                 if (isTyping)
  ValueListenableBuilder<String>(
    valueListenable: typingText,
    builder: (context, value, _) => Text(
      value,
      style: const TextStyle(fontStyle: FontStyle.italic),
    ),
  )
                                  else
                                    Text(
                                      msg['text'],
                                      style: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  if (msg['reaction'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(msg['reaction'],
                                          style: const TextStyle(fontSize: 18)),
                                    ),
                                  if (msg['seen'] == true && isAI)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Seen",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 10)),
                                         GestureDetector(
onTap: () {
  final currentMessages = List<Map<String, dynamic>>.from(messages.value);
  final myIndex = currentMessages.indexOf(msg);
  final prompt = msg['prompt'] ?? msg['content'] ?? "";

  // ✅ Remove the AI response following this user message
  if (myIndex + 1 < currentMessages.length &&
      currentMessages[myIndex + 1]['role'] == 'ai') {
    currentMessages.removeAt(myIndex + 1);
  }

  messages.value = currentMessages;

  // ✅ Trigger regenerate with visual feedback
  shouldStop = false;
  isGenerating = true;
  setState(() {}); // ✅ Show red stop button immediately

  _sendPrompt(prompt, isRegenerate: true);
},
  child: Transform.rotate(
    angle: 0.6,
    child: Icon(
      Icons.refresh,
      size: 18,
      color: index == msgList.lastIndexWhere((m) => m['role'] == 'ai')
          ? Colors.orange
          : Colors.grey,
    ),
  ),
),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                          if (isUser)
                            ValueListenableBuilder<String>(
                              valueListenable: avatarNotifier,
                              builder: (_, value, __) => CircleAvatar(
                                  backgroundImage: AssetImage(value),
                                  radius: 16),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
    
          // ✅ Chat Input Row
          Builder(
            builder: (context) {
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              final fillColor =
                  isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
              final hintColor = isDark ? Colors.white54 : Colors.black54;
              final textColor = isDark ? Colors.white : Colors.black;
    
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: textColor),
                        onSubmitted: _sendPrompt,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: fillColor,
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: hintColor),
                          suffixIcon: PopupMenuButton<String>(
                            onSelected: (val) =>
                                setState(() => currentModel = val),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: widget.isDark
                                    ? Colors.white12
                                    : Colors.black12,
                                width: 1.2,
                              ),
                            ),
                            color: widget.isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade50,
                            elevation: 8,
                            icon: const Icon(Icons.tune,
                                color: Colors.orange),
                            itemBuilder: (ctx) => modelList.map((m) {
                              final isSelected = m == currentModel;
                              return PopupMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange
                                        : (widget.isDark
                                            ? Colors.grey.shade300
                                            : textColor),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
IconButton(
  icon: const Icon(Icons.send, color: Colors.orange),
  onPressed: () {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !isGenerating) {
      shouldStop = false;
      isGenerating = true;
      setState(() {});
      _sendPrompt(text);
    }
  },
),     ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  if (_showScrollToBottom)
  Positioned(
    bottom: 150,
    right: 16,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.orange,
        onPressed: _scrollToBottom,
        child: const Icon(Icons.arrow_downward),
      ),
    ),
  )
else
  Positioned(
    bottom: 150,
    right: 16,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 0.0,
      child: IgnorePointer( // prevents invisible button from being clicked
        child: FloatingActionButton(
          mini: false,
          backgroundColor: Colors.orange,
          onPressed: _scrollToBottom,
          child: const Icon(Icons.arrow_downward),
        ),
      ),
    ),
  ),
  ],

  
  
),
);

} }



@pragma('vm:entry-point')
void fireBackupHourlyNotification() async {
  WidgetsFlutterBinding.ensureInitialized();

  final random = Random();
  final idx = random.nextInt(motivationSentences.length);
  final sentence = motivationSentences[idx];

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'hourly_channel',
      title: '💡 Zairok  (Backup)',
      body: sentence,
    ),
  );
}
@pragma('vm:entry-point') // Required for background isolate
void hourlyNotificationCallback() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required in background

  final sentence = motivationSentences[Random().nextInt(motivationSentences.length)];

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      channelKey: 'hourly_channel',
      title: '💡 Zairok Tip',
      body: sentence,
      wakeUpScreen: true,
    ),
  );

  // 💬 Also add to notification popup stack
  NotificationStackManager().push(
    '💡 Zairok Tip',
    sentence,
    isFake: false,
  );
}
Future<void> startHourlyAlarm() async {
  await AndroidAlarmManager.periodic(
    const Duration(hours: 1),
    1001, // unique ID
    hourlyNotificationCallback,
    wakeup: true,
    exact: true,
    rescheduleOnReboot: true,
  );
}
class NotificationStackManager {
  static final NotificationStackManager _instance = NotificationStackManager._internal();
  factory NotificationStackManager() => _instance;
  NotificationStackManager._internal();

  final List<Map<String, String>> _messages = [];
  final Set<String> _recentBodies = {}; // 🧠 Tracks recently shown messages

  List<Map<String, String>> get messages => List.unmodifiable(_messages);

  void push(String title, String body, {bool isFake = false}) {
    // 🚫 Avoid inserting duplicate at top
    if (_messages.isNotEmpty &&
        _messages.first['body'] == body &&
        _messages.first['isFake'] == isFake.toString()) {
      return;
    }

    // 🚫 Avoid reusing recently used sentences
    if (_recentBodies.contains(body)) return;

    _messages.insert(0, {
      'title': title,
      'body': body,
      'isFake': isFake.toString(),
    });

    _recentBodies.add(body);

    // 🧹 Limit recent memory to 50
    if (_recentBodies.length > 50) {
      _recentBodies.remove(_messages.last['body']);
    }

    // 🧹 Limit max stack to 20
    if (_messages.length > 20) {
      final removed = _messages.removeLast();
      _recentBodies.remove(removed['body']);
    }
  }

  void clear() {
    _messages.clear();
    _recentBodies.clear();
  }

  void remove(Map<String, String> msg) {
    _messages.remove(msg);
    _recentBodies.remove(msg['body']);
  }
}
Future<void> maybeAddFakeNotification() async {
  final prefs = await SharedPreferences.getInstance();
  final lastOpened = prefs.getInt('lastOpened') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  final diff = Duration(milliseconds: now - lastOpened);

  if (diff.inMinutes < 60) {
    final random = Random();
    final count = random.nextInt(4) + 1;
    int tries = 0;

    while (NotificationStackManager().messages.length < count && tries < 15) {
      tries++;
      final sentence = motivationSentences[random.nextInt(motivationSentences.length)];

      NotificationStackManager().push(
        '💡 Motivational Tip',
        sentence,
        isFake: true,
      );
    }
  }

  prefs.setInt('lastOpened', now);
}
void showNotificationPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        final notifications = NotificationStackManager().messages;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text("📥 Zairok Notifications", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const Divider(),

              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("You're all caught up!", style: GoogleFonts.poppins(fontSize: 16)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (_, index) {
                      final item = notifications[index];
                      return Dismissible(
                        key: ValueKey('${item['title']}_${item['body']}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          NotificationStackManager().remove(item);
                          setState(() {});
                        },
                        child: ListTile(
                          title: Text(item['title'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(item['body'] ?? '', style: GoogleFonts.poppins()),
                          trailing: item['isFake'] == 'true'
                              ? Icon(Icons.auto_awesome, size: 18, color: Colors.orange)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
Future<void> debugSchedule24MessagesEach10Sec() async {
  final timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().cancelNotificationsByChannelKey('hourly_channel');

  final now = DateTime.now().toLocal();

  for (int i = 0; i < 24; i++) {
    final scheduledTime = now.add(Duration(hours: i + 1)); // ⏰ One per hour

    final title = '💡 Zairok Tip #${i + 1}';
    final body = motivationSentences[i % motivationSentences.length];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4000 + i, // 🔢 Unique ID per hour
        channelKey: 'hourly_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: scheduledTime.year,
        month: scheduledTime.month,
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        millisecond: 0,
        timeZone: timeZone,
        repeats: false,
      ),
    );

    // 📥 Add to in-app stack (popup)
    NotificationStackManager().push(title, body);
  }
}
Future<void> showOneTimeWelcomeNotification() async {
  final prefs = await SharedPreferences.getInstance();
  final shown = prefs.getBool('welcomeNotificationShown') ?? false;

  if (!shown) {
    const title = '🎉 Welcome to Zairok!';
    const body = 'Start exploring free AI tools right away.';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'zairok_channel', // ✅ Correct channel
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );

    // 📥 Add to in-app popup stack
    NotificationStackManager().push(title, body);

    await prefs.setBool('welcomeNotificationShown', true);
  }
}

// 🔔 Initialize local notifications
final List<String> motivationSentences = [
  "Tired of paywalls? Zairok finds free AI tools for you.",
  "Explore a new AI tool today — open Zairok.",
  "Let Zairok save your time. Search smarter.",
  "Don't waste time hunting tools — Zairok's got them all.",
  "Zairok = 100+ AI tools without subscriptions.",
  "Skip signups, start using AI instantly with Zairok.",
  "Zairok updates daily — open the app and discover.",
  "Use Zairok before Googling your next AI need.",
  "Zairok helps you find the right tool in seconds.",
  "Try something new today — check 'Special for You' on Zairok.",
  "Favorites full? Time to clean up in Zairok!",
  "Haven’t tried Zairok AI yet? Tap the chat icon now.",
  "Lost in tools? Filter by genre in Zairok and relax.",
  "Bored? Explore the 'Writing' or 'Gaming' tools in Zairok.",
  "Tap the heart icon to save your favorite tools in Zairok.",
  "Zairok = zero subscriptions, 100% productivity.",
  "Don’t forget to pull down and refresh — new tools await!",
  "Add Zairok to your home screen for instant AI access.",
  "Stuck with a task? Zairok AI can help — try chatting!",
  "Discover hidden AI gems inside Zairok’s categories.",
  "Search smarter, not harder — Zairok’s built for it.",
  "The tool you need is probably on Zairok right now.",
  "Swipe, search, favorite — Zairok keeps it easy.",
  "You browse, Zairok recommends — check ‘Special for You’.",
  "Need code, image, or voice tools? Zairok’s got them sorted.",
  "Click any tool to explore deeply — Zairok shows all info.",
  "Zairok is your AI toolkit. Use it daily.",
  "New tool discovered? Share it from Zairok instantly.",
  "Explore 5 tools a day to master Zairok!",
  "Reminder: Tap the genre icon to filter like a pro.",
];
final ValueNotifier<String> avatarNotifier = ValueNotifier('assets/profile1.jpg');

Future<void> loadAvatarPath() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('avatarPath') ?? 'assets/profile1.jpg';
  avatarNotifier.value = saved;
}
class CuteToolCardShimmerList extends StatelessWidget {
  final int count;
  const CuteToolCardShimmerList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(
      children: List.generate(count, (_) {
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child:  ToolCardShimmer(isDark: isDark),
        );
      }),
    );
  }
}
class AvatarSelectionScreen extends StatefulWidget {
  final String userName;
  final ValueNotifier<bool> isDarkModeNotifier;
  final VoidCallback onToggleTheme;

  const AvatarSelectionScreen({
    super.key,
    required this.userName,
    required this.isDarkModeNotifier,
    required this.onToggleTheme,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String selectedAvatar = 'assets/profile1.jpg';

  final List<String> avatarOptions = [
    'assets/profile1.jpg',
    'assets/profile2.jpg',
    'assets/profile3.jpg',
    'assets/profile4.jpg',
    'assets/profile5.jpg',
    'assets/profile6.jpg',
    'assets/profile7.jpg',
    'assets/profile8.jpg',
    'assets/profile9.jpg',
  ];

  void _goToPersonalizingScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', selectedAvatar);

    if (!mounted) return;
Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (_, animation, __) => PersonalizingScreen(
      userName: widget.userName,
      avatarPath: selectedAvatar,
      isDarkModeNotifier: widget.isDarkModeNotifier,
      onToggleTheme: widget.onToggleTheme,
    ),
    transitionDuration: const Duration(milliseconds: 800),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ));

      return SlideTransition(
        position: slide,
        child: child,
      );
    },
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkModeNotifier.value;
    final textC = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: textC,
            ),
            onPressed: () {
              widget.isDarkModeNotifier.value = !isDark;
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 145),
              Text(
                "Choose Your Avatar",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textC,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 100,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: avatarOptions.map((avatar) {
                        final isSelected = selectedAvatar == avatar;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedAvatar = avatar);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(avatar),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToPersonalizingScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3C00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _goToPersonalizingScreen,
                child: Text(
                  "Skip for now",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class PersonalizingScreen extends StatefulWidget {
  final String userName;
  final String avatarPath;
  final ValueNotifier<bool> isDarkModeNotifier;
  final VoidCallback onToggleTheme;

  const PersonalizingScreen({
    super.key,
    required this.userName,
    required this.avatarPath,
    required this.isDarkModeNotifier,
    required this.onToggleTheme,
  });

  @override
  State<PersonalizingScreen> createState() => _PersonalizingScreenState();
}

class _PersonalizingScreenState extends State<PersonalizingScreen> {
  double _percent = 0.0;
  late Timer _progressTimer;

  bool _showLine1 = false;
  bool _showLine2 = false;
  bool _showLine3 = false;
@override
void initState() {
  super.initState();
  _startProgress();
  _animateLines();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('askedNotif') ?? false;

    // 🔐 Ask notification permission once
    if (!alreadyAsked) {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      await prefs.setBool('askedNotif', true);
    }

    // ✅ Proceed if permission granted
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (allowed) {
      await Future.delayed(const Duration(seconds: 2));
      await showOneTimeWelcomeNotification();

      // 🧹 Cancel old schedules
      await AwesomeNotifications().cancelNotificationsByChannelKey('hourly_channel');
      await AndroidAlarmManager.cancel(1001); // Cancel fallback if any

      // ⏰ Schedule real 24 hourly motivational notifications
      await  debugSchedule24MessagesEach10Sec();

      // 🛡 Schedule backup every hour via AndroidAlarmManager
      await AndroidAlarmManager.periodic(
        const Duration(hours: 1),
        1001, // Unique ID
        fireBackupHourlyNotification,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  });
}
  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _percent += 0.02;
        if (_percent >= 1.0) {
          _percent = 1.0;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 1000), _navigateToMainUI);
        }
      });
    });
  }

  void _animateLines() {
    Future.delayed(const Duration(milliseconds: 500), () => setState(() => _showLine1 = true));
    Future.delayed(const Duration(milliseconds: 1000), () => setState(() => _showLine2 = true));
    Future.delayed(const Duration(milliseconds: 1500), () => setState(() => _showLine3 = true));
  }

  void _navigateToMainUI() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainUIScreen(
          userName: widget.userName,
          avatarPath: widget.avatarPath,
          isDarkModeNotifier: widget.isDarkModeNotifier,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    super.dispose();
  }

  Widget _buildChecklistLine(String text, bool visible, Color color) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkModeNotifier.value;
    final bg = isDark ? Colors.black : Colors.white;
    final textC = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 8.0,
                percent: _percent,
                animation: true,
                animationDuration: 500,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.greenAccent,
                backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                center: Text(
                  "${(_percent * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Just a moment while we personalize your experience",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textC,
                ),
              ),
              const SizedBox(height: 32),
              _buildChecklistLine("Creating your For You screen", _showLine1, textC),
              const SizedBox(height: 16),
              _buildChecklistLine("Adding selected titles to your library", _showLine2, textC),
              const SizedBox(height: 16),
              _buildChecklistLine("Selecting collections you might like", _showLine3, textC),
            ],
          ),
        ),
      ),
    );
  }
}
Future<void> fetchAndApplyBlacklist() async {
  try {
    final list = await fetchBlacklist();
    final cleaned = list.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    blacklistedNamesNotifier.value = List.from(cleaned); // ✅ Notifies listeners
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cachedBlacklist', cleaned);

  } catch (e) {
  }
}
Future<void> loadCachedBlacklist() async {
  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getStringList('cachedBlacklist') ?? [];

  final cleaned = cached
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  // 🔁 Force new list instance to ensure ValueNotifier rebuilds UI
  blacklistedNamesNotifier.value = [...cleaned];

}
final ValueNotifier<List<String>> blacklistedNamesNotifier = ValueNotifier([]);

bool isLoading = true;
Future<List<String>> fetchBlacklist() async {
  try {
    final url = Uri.parse(
      'https://zairok.web.app/b.json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      // Ensure valid strings only
      final List<String> blacklist = jsonList
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final prefs = await SharedPreferences.getInstance();

      if (blacklist.isEmpty) {
        await prefs.remove('cachedBlacklist'); // 🧹 Clear if empty
      } else {
        await prefs.setStringList('cachedBlacklist', blacklist); // 💾 Save fresh list
      }

      return blacklist;
    } else {
      throw Exception('Failed to fetch blacklist: ${response.statusCode}');
    }
  } catch (e) {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cachedBlacklist') ?? [];
  }
}
final showAd = _browseCount % 3 == 0;
 // Filled later from online source

Widget banerContainer({required Widget child, required bool isDark}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(child: child),
  );
}


Widget promoBanner({
  required String text,
  required String assetPath,
  required bool isDark,
  required Color bgColor,
  required TextStyle textStyle,
  required Color borderColor,
  AnimatedTextType textEffect = AnimatedTextType.typewriter, // default
}) {
  AnimatedText getAnimatedText() {
    switch (textEffect) {
      case AnimatedTextType.fade:
        return FadeAnimatedText(
          text,
          textStyle: textStyle,
          duration: const Duration(milliseconds: 2000),
        );
      case AnimatedTextType.scale:
        return ScaleAnimatedText(
          text,
          textStyle: textStyle,
          duration: const Duration(milliseconds: 1600),
        );
      case AnimatedTextType.typewriter:
      default:
        return TypewriterAnimatedText(
          text,
          textStyle: textStyle,
          speed: const Duration(milliseconds: 40),
        );
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor,
        width: 1.2,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: AnimatedTextKit(
            animatedTexts: [getAnimatedText()],
            isRepeatingAnimation: true,
            repeatForever: true,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
          ),
        ),
        const SizedBox(width: 10),
        SvgPicture.asset(assetPath, height: 60),
      ],
    ),
  );
}

int _browseCount = 0;
RewardedInterstitialAd? _rewardedInterstitialAd;
enum AnimatedTextType {
  typewriter,
  fade,
  scale,
}
void loadRewardedInterstitialAd() {
  RewardedInterstitialAd.load(
    adUnitId: 'ca-app-pub-1372661529203718/2945885002', // my id
    request: const AdRequest(),
    rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _rewardedInterstitialAd = ad;
      },
      onAdFailedToLoad: (error) {
        _rewardedInterstitialAd = null;
      },
    ),
  );
}

String get aboutDeveloperText => '''
Lohit (also known as Aarush Lohit – Author | Lyricist | Coder) is a 17-year-old developer who recently completed his 12th grade. But what defines him isn’t a certificate or a title — it's his journey through trauma, self-discovery, and quiet resilience.
g
Since childhood, Lohit faced relentless bullying, social Anxiety, and was often misjudged — even by teachers, and by someone he once admired deeply. A person who chose to misunderstand his kindness, ridicule his silence, and label his emotions rather than understand them. She wasn’t the only one — the world around him had decided who he was, without ever truly knowing him.

But instead of sinking under the weight of judgment, he chose to rise.

Alone — with no team, no fancy tools, and no formal training — Lohit built Zairok, a freemium AI tools discovery app meant to help people like him discover creativity, confidence, and digital freedom.

He turned heartbreak into hard work.  
He turned silence into software.

And while Zairok may not be a billion-dollar app — and he knows it might not seem like a “big thing” to the world — to him, it's monumental.  
Because it’s proof that he is not worthless.

To everyone who misjudged him.  
To every teacher who underestimated him.  
And to her $heartSymbol— thank you.  
Thank you for your judgment.  
Because without your judgment, this version of Lohit would not exist.

Lohit is not here to prove anything to anyone.  
This app wasn’t built for fame.  
It’s a quiet, dignified response.  
Not to show off — but to show up.  
Not to impress — but to express.
Signing off with a simple message:
You can’t define me.
I define myself.
I am not your judgment.
I am not your label.
~Lohit A.K.A (Aarush Lohit)
''';
class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  String selectedAvatar = 'assets/profile1.jpg';

  final List<String> avatarOptions = [
    'assets/profile1.jpg',
    'assets/profile2.jpg',
    'assets/profile3.jpg',
    'assets/profile4.jpg',
    'assets/profile5.jpg',
    'assets/profile6.jpg',
    'assets/profile7.jpg',
    'assets/profile8.jpg',
    'assets/profile9.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
  }

  Future<void> _loadCurrentAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('avatarPath') ?? 'assets/profile1.jpg';
    setState(() => selectedAvatar = saved);
  }

  Future<void> _saveAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', selectedAvatar);
    avatarNotifier.value = selectedAvatar; // ✅ reflect instantly in MainUI
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("Edit Avatar", style: TextStyle(color: textC, fontWeight: FontWeight.bold, fontSize: 22,fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textC),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "Choose Your Avatar",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textC,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 100,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: avatarOptions.map((avatar) {
                        final isSelected = selectedAvatar == avatar;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedAvatar = avatar),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(avatar),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 65),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3C00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DisclaimerPolicyScreen extends StatelessWidget {
  final bool isDarkMode;
  const DisclaimerPolicyScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? Colors.black : Colors.white;
    final textC = isDarkMode ? Colors.white : Colors.black;
    final subC = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: textC,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disclaimer & Policy',
          style: GoogleFonts.poppins(
            color: textC,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
'''
**📜 Disclaimer & Terms of Use**

Created by Lohit, Zairok is a freemium AI discovery platform that helps users explore public AI tools from across the web. All third-party tools and content are the property of their respective owners unless explicitly stated.

By using Zairok, you agree to the following:
1. You use external AI tools voluntarily and at your own discretion.
2. Zairok is not responsible for external content, behavior, or outcomes.
3. You are 13 years or older, or have guardian consent to use the app.

**🎨 Tool Names & Icons**

- Some tools may appear with simplified names or nicknames for clarity.
- Icons are genre-based — not official logos — to respect branding rights.
- Any official brand marks shown are for educational credit only.

If you're a brand owner and would like edits or removal, contact:  
📧 zairokcare@gmail.com

**🚦 Redirection & Ad Policy**

Zairok respects your choices — we never redirect without your action.  
You are taken to a tool only when you tap “Browse for Me”.

To support development, Zairok uses GoogleAdMob.

These ads follow Google Play policy.  
We do not use forced popups or paywalls.

**🤖 Free AI Chat & Image Generator**

Zairok includes a built-in AI chatbot and image generator — both free to use.  
These features are powered by open-source AI models & Projects.  
Zairok does **not** collect your queries or store chat/image data.

**🔐 Privacy Policy**

- Zairok does not collect personal data.
- Your name, favorites, and preferences are stored locally on your device.
- No trackers, no analytics, no external SDKs.

**🧩 Tool Addition & Removal**

Want your AI tool featured?  
We welcome startups, indie devs, and creators & Companies.  
Submit your tool info (name, category, link) to:  
📧 zairokcare@gmail.com

We will add your tools within 24 hours Remotely;
Need your tool removed or added?  
Email us — we’ll handle it respectfully and promptly.

*Sponsorship**

Zairok may include promotions for tools or sponsors — always minimal and user-friendly.

Interested in an ethical promotion?  
📧 zairokcare@gmail.com

**🌟 Summary**

Zairok is built with care — for AI explorers, students, and developers.  
We value your privacy and experience — no paywalls, no forced ads.

Our ads are minimal — but may sometimes feel annoying.  
Please support us — it helps keep Zairok **free of cost**, fuels our **research of new tools**, and powers updates created with **hours of effort, days of testing, and many sleepless nights**.

Your support keeps Zairok alive.  
Thank you for helping Zairok grow — ethically and transparently.

— Team Zairok
''',
          style: GoogleFonts.comicNeue(fontSize: 16, height: 1.6, color: subC,fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}


class BottomAdaptiveBannerAd extends StatefulWidget {
  final String adUnitId;

  const BottomAdaptiveBannerAd({super.key, required this.adUnitId});

  @override
  State<BottomAdaptiveBannerAd> createState() => _BottomAdaptiveBannerAdState();
}

class _BottomAdaptiveBannerAdState extends State<BottomAdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      return;
    }

    setState(() => _adSize = size); // Reserve space immediately

    final banner = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerReady = false;
            _bannerAd = null;
          });
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _adSize?.height.toDouble() ?? 60;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: _isBannerReady && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : const SizedBox(), // Transparent reserved space
    );
  }
}
class AdBannerWidget extends StatefulWidget {
  final String adUnitId;
  final bool useAdaptive;

  const AdBannerWidget({
    super.key,
    required this.adUnitId,
    this.useAdaptive = false, // Default: normal banner
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }
Future<void> _loadBanner() async {
  late final BannerAd ad;

  if (widget.useAdaptive) {
    final width = MediaQuery.of(context).size.width.truncate();

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      return;
    }


    ad = BannerAd(
      size: size,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerAd = ad;
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerReady = false;
            _bannerAd = null;
          });
        },
      ),
    );
  } else {
    
    ad = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerAd = ad;
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerReady = false;
            _bannerAd = null;
          });
        },
      ),
    );
  }

  try {
    await ad.load();
  } catch (e) {
  }
}
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  if (!_isBannerReady || _bannerAd == null) return const SizedBox.shrink();

  return Container(
    width: double.infinity, // full width like carousel
    height: 180, // visually match carousel height
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.transparent, // or subtle background
      borderRadius: BorderRadius.circular(16), // match carousel style if needed
    ),
    child: SizedBox(
      width: _bannerAd!.size.width.toDouble(),   // actual ad size (e.g., 320)
      height: _bannerAd!.size.height.toDouble(), // actual height (e.g., 50)
      child: AdWidget(ad: _bannerAd!),
    ),
  );
}
}
  bool isHeartBroken = false;

class FollowingsAboutScreen extends StatefulWidget {
  final bool isDarkMode;
  const FollowingsAboutScreen({super.key, required this.isDarkMode});

  @override
  State<FollowingsAboutScreen> createState() => _FollowingsAboutScreenState();
}
String heartSymbol = '❤️';
class _FollowingsAboutScreenState extends State<FollowingsAboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  @override
  void initState() {
    super.initState();
    isHeartBroken=false;
    _confettiController= ConfettiController(duration:const Duration(seconds:2));
    _confettiController.play();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
     showCuteSnackBar(
  context,
  "⚠️ Could not open link",
  bg: Colors.orange.shade600,
);
    }
  }

  Widget socialTile(String title, String url, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: const Icon(Icons.link, color: Colors.orange),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _launchURL(url),
    );
  }

@override
Widget build(BuildContext context) {
  final bg = widget.isDarkMode ? Colors.black : Colors.white;
  final textC = widget.isDarkMode ? Colors.white : Colors.black;
  final subC = widget.isDarkMode ? Colors.white70 : Colors.black87;

  return Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: textC,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Followings & About',
        style: GoogleFonts.poppins(
          color: textC,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Follow Me On',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textC,
              ),
            ),
            const SizedBox(height: 12),
            socialTile('GitHub', 'https://github.com/aarushlohit', widget.isDarkMode),
            socialTile('Instagram', 'https://instagram.com/aarushlohit_01', widget.isDarkMode),
            socialTile('Spotify Artist', 'https://open.spotify.com/artist/7K52MHzGtyC8XuOJVI11tl', widget.isDarkMode),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the Developer',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textC,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Profile Photo + Paragraph (Below the Title)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/author.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                GestureDetector(
  onTap: () {
    setState(() {
      heartSymbol = heartSymbol == '❤️' ? '💔' : '❤️';
    });
  },
  child: Text(
    aboutDeveloperText,
    style: GoogleFonts.poppins(
      fontSize: 13.5,
      height: 1.7,
      color: subC,
    ),
    textAlign: TextAlign.justify,
  ),
),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),

        // 🎉 Confetti
        Align(
          alignment: Alignment.topCenter,
  child: ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive, // 🎇 burst in all directions
  emissionFrequency: 0.15, // 💥 more intense burst
  numberOfParticles: 50,   // 🎊 richer visual density
  gravity: 0.4,            // 🌀 more floaty
  shouldLoop: false,
  maxBlastForce: 20,       // 🎯 stronger launch
  minBlastForce: 5,        // 🎯 softer base
colors: const [
  Color(0xFFFFC107), // 🟡 Festive Gold
  Color(0xFF4CAF50), // 🟢 Lush Green
  Color(0xFF2196F3), // 🔵 Bright Blue
  Color(0xFFE91E63), // 🌸 Celebration Pink
  Color(0xFFFF5722), // 🧡 Flame Orange
  Color(0xFFFFEB3B), // 💛 Lemon Yellow
  Color(0xFF9C27B0), // 💜 Bold Purple
  Color(0xFFFFFFFF), // 🤍 White Sparkle
],
),
        ),
      ],
    ),
  );
}
    }
Set<String> favoriteNames = {};
Widget creditCard({
  required String emoji,
  required String name,
  required String desc,
  required bool isDarkMode,
  int index = 0,
}) {
  final cardBg = isDarkMode ? Colors.grey[900] : Colors.white;
  final textC = isDarkMode ? Colors.white : Colors.black;
  final subC = isDarkMode ? Colors.white70 : Colors.black87;
  final shadowC = isDarkMode ? Colors.black45 : Colors.grey.withAlpha((0.2 * 255).toInt());

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: 500 + (index * 100)),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowC,
            blurRadius: 14,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: textC,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 13.2,
                    color: subC,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CreditsScreen extends StatelessWidget {
  final bool isDarkMode;

  const CreditsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? Colors.black : Colors.white;
    final textC = isDarkMode ? Colors.white : Colors.black;
    final subC = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textC),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Titans of Zairok',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textC,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: SvgPicture.asset('assets/creditavatar.svg', height: 30),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          creditCard(
            emoji: '🎨',
            name: 'Freepik',
            desc: 'Icons & illustrations sourced from Freepik\'s free collection.',
            isDarkMode: isDarkMode,
            index: 0,
          ),
          creditCard(
            emoji: '🧠',
            name: 'ChatGPT',
            desc: 'Debugging, logic, and AI flow suggestions powered by ChatGPT.',
            isDarkMode: isDarkMode,
            index: 1,
          ),
          creditCard(
            emoji: '📦',
            name: 'Flaticon',
            desc: 'Open-access icons that visually elevated the UI.',
            isDarkMode: isDarkMode,
            index: 3,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '📝 The above credits are included respectfully for educational purposes.\n'
              'We do not claim ownership or official affiliation. If you are the rights holder, contact zairokcare@gmail.com.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: subC,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
// ---------------- SETTINGS SCREEN ----------------

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String userName;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onSetName; 
  // ✅ to update greeting in MainUI

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.userName,
    required this.onToggleTheme,
    required this.onSetName,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _showVersionInfo = false;
  String _appVersion = '';
  String _buildNumber = '';
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = Colors.orange;
    final divider = Divider(
      thickness: 0.8,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      height: 0,
    );

    Widget buildItem(IconData icon, String title, VoidCallback onTap) {
      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor),
            onTap: onTap,
          ),
          divider,
        ],
      );
    }

    Widget buildExpandableItem() {
      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Row(
              children: [
                Text(
                  'App Info',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v1.0.3',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              _showVersionInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: textColor,
            ),
            onTap: () {
              setState(() {
                _showVersionInfo = !_showVersionInfo;
                _showVersionInfo ? _controller.forward() : _controller.reverse();
              });
            },
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
              child: Text(
                'Zairok\nVersion: v$_appVersion ($_buildNumber)',
                style: GoogleFonts.poppins(fontSize: 14, color: textColor.withAlpha((0.8 * 255).toInt())),
              ),
            ),
          ),
          divider,
        ],
      );
    }

    return Scaffold(
     backgroundColor: bgColor,
appBar: AppBar(
  backgroundColor: bgColor,
  elevation: 0,
  scrolledUnderElevation: 0, // ✅ prevents shadow on scroll
  surfaceTintColor: Colors.transparent, // ✅ removes peach tint
  iconTheme: IconThemeData(color: textColor),
  title: Text(
    'Settings',
    style: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
  ),
  centerTitle: true,
),
      body: ListView(
        children: [
          buildItem(Icons.edit_note_rounded, 'Edit Name', () async {
            final newName = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => EditNameScreen(
                  isDarkMode: isDarkMode,
                  initialName: widget.userName,
                ),
              ),
            );
            if (newName != null && newName.trim().isNotEmpty) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', newName);
              widget.onSetName(newName); // 🔥 live update
            }
          }),
          buildItem(
  Icons.person_outline, // 👤 Avatar icon
  'Edit Avatar',
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditAvatarScreen(),
      ),
    );
  },
),
          buildItem(Icons.favorite_outline, 'Clear Favorites', () {
            _showConfirmDialog(
              context,
              isDarkMode,
              'Clear Favorites?',
              'Are you sure you want to clear all favorites?',
              () {
                favoriteNames.clear();
                Navigator.pop(context);
                showCuteSnackBar(
  context,
  "🗑️ Cleared Favorites",
  bg: Colors.green,
);
              },
            );
          }),
          buildItem(Icons.history_toggle_off, 'Clear Search History', () {
            _showConfirmDialog(
              context,
              isDarkMode,
              'Clear Search History?',
              'Do you really want to delete all search history?',
              () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('searchHistory');
                Navigator.pop(context);
               showCuteSnackBar(
  context,
  "🧹 Cleared Search History",
  bg: Colors.green,
);
              },
            );
          }),
          buildItem(Icons.emoji_events_outlined, 'Credits', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreditsScreen(isDarkMode: isDarkMode),
              ),
            );
          }),
          buildItem(Icons.link_outlined, 'Followings & About', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FollowingsAboutScreen(isDarkMode: isDarkMode),
              ),
            );
          }),
          buildItem(Icons.help_outline, 'FAQ', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FaqScreen(isDarkMode: isDarkMode),
              ),
            );
          }),
          buildItem(Icons.description_outlined, 'Disclaimer / Terms & Policy', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DisclaimerPolicyScreen(isDarkMode: isDarkMode),
              ),
            );
          }),
         buildItem(Icons.mail_outline, 'Contact Us', () async {
  final uri = Uri.parse('mailto:zairokcare@gmail.com');
  final launched = await launchUrl(uri);

  if (!launched) {
   showCuteSnackBar(
  context,
  "⚠️ Could not open email app",
  bg: Colors.red,
);
  }
}),        buildExpandableItem(),
          buildItem(Icons.logout_rounded, 'Exit App', () {
            _showConfirmDialog(
              context,
              isDarkMode,
              'Exit Zairok?',
              'Do you really want to exit the app?',
              () => SystemNavigator.pop(),
            );
          }),
         
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    bool isDarkMode,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    final popupColor = isDarkMode ? Colors.black : Colors.white;
    final btnColor = Colors.orange;
    final txtColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: popupColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: txtColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(color: txtColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: btnColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onConfirm,
              child: Text('Confirm', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}



// ---------------- EDIT NAME SCREEN ----------------
class EditNameScreen extends StatefulWidget {
  final bool isDarkMode;
  final String initialName;

  const EditNameScreen({
    super.key,
    required this.isDarkMode,
    required this.initialName,
  });

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

void saveName() async {
  final newName = _ctrl.text.trim();
  if (newName.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName); // ✅ Save to local storage

    if (!mounted) return;
    Navigator.pop(context, newName); // ✅ Return to previous screen with new name
  }
}
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final enabled = _ctrl.text.trim().isNotEmpty;
    final bg = isDark ? Colors.black : Colors.white;
    final textC = isDark ? Colors.white : Colors.black;
    final subC = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: textC,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Name',
          style: GoogleFonts.poppins(
            color: textC,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              TextField(
                controller: _ctrl,
                style: TextStyle(color: textC),
                decoration: InputDecoration(
                  hintText: 'Enter Your Name',
                  hintStyle: TextStyle(color: subC),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.person, color: subC),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enabled ? saveName : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: enabled ? const Color(0xFFFF3C00) : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your name is stored locally for personalization only.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: subC,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final bool isDarkMode;

  const FavoritesScreen({super.key, required this.isDarkMode});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String selectedGenre = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final textC = isDark ? Colors.white : Colors.black;
    final subC = isDark ? Colors.white70 : Colors.black54;

    return ValueListenableBuilder<List<String>>(
      valueListenable: blacklistedNamesNotifier,
      builder: (context, blacklist, _) {
        final favTools = tools
            .where((t) => favoriteNames.contains(t['name']))
            .where((t) => !blacklist.contains(t['name']))
            .where((t) =>
                selectedGenre == 'All' ||
                t['genre']!.toLowerCase() == selectedGenre.toLowerCase())
            .toList();

        return Scaffold(
         backgroundColor: bg,
appBar: AppBar(
  leading: BackButton(color: textC),
  backgroundColor: bg,
  elevation: 0,
  scrolledUnderElevation: 0, // prevents shadow/tint on scroll
  surfaceTintColor: Colors.transparent, // removes peach tint (Material 3)
  title: Text(
    'Favourites',
    style: GoogleFonts.poppins(
      color: textC,
      fontWeight: FontWeight.bold,
    ),
  ),
),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Always show genre chips (do not auto-hide)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: genres.map((g) => genreChip(g)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: favTools.isEmpty
                      ? Center(
                          child: Text(
                            'No favorites yet!',
                            style: GoogleFonts.poppins(color: subC),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: favTools.length,
                          itemBuilder: (_, i) {
                            final tool = favTools[i];
                            return ToolCard(
                              tool: tool,
                              isFavorite: true,
                              onFavoriteToggle: (name) {
                                setState(() => favoriteNames.remove(name));
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget genreChip(String label) {
    final isSelected = selectedGenre.toLowerCase() == label.toLowerCase();
    final isDark = widget.isDarkMode;

    return GestureDetector(
      onTap: () => setState(() => selectedGenre = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepOrange
              : (isDark ? Colors.grey[850] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
class FaqScreen extends StatelessWidget {
  final bool isDarkMode;

  const FaqScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? Colors.black : Colors.white;

    final List<Map<String, String>> faqs = [
      {
        'question': 'What is Zairok?',
        'answer':
            'Zairok is your AI tool discovery assistant. It helps you explore and use the best freemium AI tools instantly.'
      },
      {
        'question': 'Is Zairok free to use?',
        'answer':
            'Yes! Zairok is completely free and helps you find powerful tools without hassle.'
      },
      {
        'question': 'Can I save my favorite tools?',
        'answer':
            'Absolutely. Tap the heart icon to save any tool to your favorites.'
      },
      {
        'question': 'Will I see ads?',
        'answer':
            'Yes, Zairok shows minimal ads to stay free. You’ll see one when opening the app and occasionally while browsing tools.'
      },
      {
        'question': 'Where is my data stored?',
        'answer':
            'All your preferences are stored securely on your device. We don’t store personal data online.'
      },
      {
        'question': 'Are the AI tools listed in Zairok safe?',
        'answer':
            'We carefully curate tools that are generally safe and publicly accessible. However, always use tools responsibly and avoid entering sensitive data.'
      },
      {
        'question': 'Are free and open-source websites safe to use?',
        'answer':
            'Most free and open-source websites are safe and community-driven, but it’s always smart to check reviews and avoid entering personal or financial information unless the site is trusted.'
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'FAQs',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FAQBounceTile(
            question: faqs[index]['question']!,
            answer: faqs[index]['answer']!,
            isDark: isDarkMode,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------
// 🔁 FAQ Tile with Bounce Animation
// ---------------------------------------------
class FAQBounceTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;

  const FAQBounceTile({
    super.key,
    required this.question,
    required this.answer,
    required this.isDark,
  });

  @override
  State<FAQBounceTile> createState() => _FAQBounceTileState();
}

class _FAQBounceTileState extends State<FAQBounceTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _bounceAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Bouncy effect
    );
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? Colors.grey[900] : Colors.grey[100];
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final answerColor = widget.isDark ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _expanded ? 1.02 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.question,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                            color: textColor,
                          ),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                  // Answer with animation
                  SizeTransition(
                    sizeFactor: _expandAnim,
                    axisAlignment: -1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        widget.answer,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          height: 1.6,
                          color: answerColor,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// Greeting generator function

String getGreeting(String name) {
  final hour = DateTime.now().hour;

  String baseGreeting;
  String emoji;

  if (hour >= 5 && hour < 12) {
    baseGreeting = "Good morning";
    emoji = "☕️";
  } else if (hour >= 12 && hour < 17) {
    baseGreeting = "Good afternoon";
    emoji = "☀️";
  } else if (hour >= 17 && hour < 21) {
    baseGreeting = "Good evening";
    emoji = "🌥️";
  } else {
    baseGreeting = "Good night";
    emoji = "🌜";
  }

  final validName = name.trim().isEmpty ? "there" : name.trim();

  return "$baseGreeting, $validName $emoji";
}
bool _areListsEqualIgnoreCase(List<String> a, List<String> b) {
  final setA = a.map((e) => e.toLowerCase()).toSet();
  final setB = b.map((e) => e.toLowerCase()).toSet();
  return setA.length == setB.length && setA.containsAll(setB);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['ACF8A1E7BE0DD64001710A89B4E175F1']),
  );
  await MobileAds.instance.initialize();

  // 📁 Set Hive directory
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  // 🔐 Persistent AES key using flutter_secure_storage
  



  // 🐝 Open encrypted box
  await Hive.initFlutter();
    await Hive.openBox('toolsBox');

  await Hive.openBox('chatBox');

  // ⏰ Alarm Manager Setup
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.cancel(1001);

  // 🛡️ Root / Emulator Detection
  final isRooted = await DeviceSecurity.isRooted();
  final isEmulator = await DeviceSecurity.isEmulator();

  if (isRooted || isEmulator) {
    // 🚫 Silent kill on insecure device
    exit(0);
  }


  // 🔒 Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
     
  // 🔔 Initialize Awesome Notifications with both channels
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'zairok_channel',
        channelName: 'Zairok Notifications',
        channelDescription: 'Notification channel for Zairok app alerts',
        defaultColor: Color(0xFF2196F3),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'hourly_channel',
        channelName: 'Zairok Hourly Tips',
        channelDescription: '1 motivational message per hour for 24 hours',
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    ],
  ); 
    

  // 💰 Initialize AdMob


  // 📦 Load SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;

  // 🚦 First launch & userName
  final hasLaunched = prefs.getBool('hasLaunched') ?? false;
  final userName = prefs.getString('userName') ?? '';

  // 🧊 Load cached blacklist
  final cached = prefs.getStringList('cachedBlacklist') ?? [];
  blacklistedNamesNotifier.value = List.from(cached);

  // 🌐 Fetch updated blacklist
  fetchBlacklist().then((fetched) {
    final fetchedTrimmed = fetched.map((e) => e.trim()).toList();
    final cachedTrimmed = cached.map((e) => e.trim()).toList();

    if (!_areListsEqualIgnoreCase(cachedTrimmed, fetchedTrimmed)) {
      blacklistedNamesNotifier.value = List.from(fetchedTrimmed);
      prefs.setStringList('cachedBlacklist', fetchedTrimmed);
    } else {
    }
  });


  // 🖼 Load avatar
  await loadAvatarPath();
 await maybeAddFakeNotification();
  // 🚀 Launch app
  runApp(
    ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return MyApp(
          isFirstLaunch: !hasLaunched,
          savedUserName: userName,
          isDarkMode: isDark,
        );
      },
    ),
  );
}
class MyApp extends StatefulWidget {
  final bool isFirstLaunch;
  final String savedUserName;
  final bool isDarkMode;

  const MyApp({
    super.key,
    required this.isFirstLaunch,
    required this.savedUserName,
    required this.isDarkMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<bool> darkModeNotifier;

  @override
  void initState() {
    super.initState();
    darkModeNotifier = ValueNotifier(widget.isDarkMode);
    isDarkModeNotifier.value = widget.isDarkMode;
  }

void toggleTheme() async {
  darkModeNotifier.value = !darkModeNotifier.value;

  // 🔒 Save to shared preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', darkModeNotifier.value);

  // 🔄 Sync global notifier
  isDarkModeNotifier.value = darkModeNotifier.value;
}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Zairok',
          debugShowCheckedModeBanner: false,
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: LoadingScreen(
            isFirstLaunch: widget.isFirstLaunch,
            savedUserName: widget.savedUserName,
            isDarkModeNotifier: darkModeNotifier,
            onToggleTheme: toggleTheme,
          ),
        );
      },
    );
  }
}
// ---------------- GetStartedScreen ----------------
class GetStartedScreen extends StatelessWidget {
  final ValueNotifier<bool> isDarkModeNotifier;
  final ValueChanged<String> onSetName;

  const GetStartedScreen({
    super.key,
    required this.isDarkModeNotifier,
    required this.onSetName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDarkModeNotifier.value;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return FutureBuilder<bool>(
      future: _checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data ?? false) {
          // If onboarding is completed, directly move to the next screen (EnterNameScreen)
          return EnterNameScreen(
            isDarkModeNotifier: isDarkModeNotifier,
            onSetName: onSetName,
          );
        }

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: textColor,
                ),
                onPressed: () {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Text(
                      'Discover AI\nLike Never Befor!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Find freemium AI tools\nInstantly.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor.withAlpha((0.7 * 255).toInt()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SvgPicture.asset(
                      'assets/2.svg',
                      height: 300,
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save that onboarding has completed
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasLaunched', true);

                          Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EnterNameScreen(
      isDarkModeNotifier: isDarkModeNotifier,
      onSetName: onSetName,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right
      const end = Offset.zero;
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 800),
  ),
);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasLaunched') ?? false;
  }
}
// ---------------- EnterNameScreen ----------------
class EnterNameScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkModeNotifier;
  final ValueChanged<String> onSetName;

  const EnterNameScreen({
    super.key,
    required this.isDarkModeNotifier,
    required this.onSetName,
  });

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkModeNotifier.value;
    final bg = isDark ? Colors.black : Colors.white;
    final textC = isDark ? Colors.white : Colors.black;
    final subC = isDark ? Colors.white70 : Colors.black54;
    final isNameEntered = _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: textC,
            ),
            onPressed: () {
              widget.isDarkModeNotifier.value = !isDark;
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                'Zairok.',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textC,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find Freemium AI Tools.',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: subC,
                ),
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _ctrl,
                style: TextStyle(color: textC),
                decoration: InputDecoration(
                  hintText: 'Enter Your Name',
                  hintStyle: TextStyle(color: subC),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.person, color: subC),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
              onPressed: isNameEntered
    ? () async {
        final name = _ctrl.text.trim();
        widget.onSetName(name);

        // ✅ Save locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasLaunched', true);
        await prefs.setString('userName', name);

        // ✅ Close the keyboard first
        FocusScope.of(context).unfocus();

        // ⏳ Wait for layout to settle
        await Future.delayed(const Duration(milliseconds: 250));

        if (!mounted) return;

        // ✅ Slide transition to AvatarSelectionScreen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, animation, __) => AvatarSelectionScreen(
              userName: name,
              isDarkModeNotifier: widget.isDarkModeNotifier,
              onToggleTheme: () {
                widget.isDarkModeNotifier.value =
                    !widget.isDarkModeNotifier.value;
              },
            ),
            transitionsBuilder: (_, animation, __, child) {
              final slide = Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Slide from right
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ));

              return SlideTransition(
                position: slide,
                child: child,
              );
            },
          ),
        );
      }
    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isNameEntered ? const Color(0xFFFF3C00) : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We respect your privacy. Only your name is recorded locally.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: subC,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Main data
final List<Map<String, String>> tools = [
  {
    "name": "Search.sh",
    "genre": "Search & Discovery AI",
    "desc": "Search.sh is a smart search engine built for both humans and bots. It gives better search results using advanced AI. The clean interface makes searching easier and faster. Great for developers and tech-savvy users.",
    "url": "https://search.sh?ref=zairok"
  },
  {
    "name": "Rocket",
    "genre": "Coding AI",
    "desc": "Rocket is a free AI-powered platform that lets you build, run, and deploy web or mobile apps just by describing them in plain English. It’s designed for anyone, even without coding knowledge. With its simple interface, you can quickly bring your ideas to life. A great tool for creators and startups to launch faster.",
    "url": "https://www.rocket.new?ref=zairok"
  },
  {
    "name": "Hashtag AI",
    "genre": "Image Generation AI",
    "desc": "Hashtag AI helps users create the best hashtags using just a photo. You can upload or take an image, and the tool uses AI to generate relevant hashtags. Optionally, you can add a topic for better suggestions. It’s great for social media posts and marketing.",
    "url": "https://ht.pgaleone.eu?ref=zairok"
  },
  {
    "name": "Breed Dog Identifier",
    "genre": "Image Generation AI",
    "desc": "Breed.dog uses AI to recognize dog breeds from photos. Upload an image and the tool will suggest up to three possible matches. It supports over 360 dog breeds from around the world. Helpful for dog lovers, owners, and adopters.",
    "url": "https://breed.dog/?ref=zairok"
  },
  {
    "name": "Doc2Exam",
    "genre": "Study AI",
    "desc": "Doc2Exam lets users turn documents into exam questions and study materials. It’s useful for both teachers and students preparing for tests. Upload your content and get quick quiz or exam formats. A simple tool to save time while studying.",
    "url": "https://doc2exam.com?ref=zairok"
  },
  {
    "name": "AI Code Converter",
    "genre": "Coding AI",
    "desc": "AI Code Converter is a free online tool that uses AI to translate code between programming languages (Python, JavaScript, Java, C++, and more) or generate code from natural-language prompts. It emphasizes easy click‑based usage, privacy (does not retain input/output), and support for dozens of languages.",
    "url": "https://aicodeconvert.com?ref=zairok"
  },
  {
    "name": "VibeHost",
    "genre": "Productivity AI",
    "desc": "VibeHost makes app deployment super easy—just upload your code and get a live link instantly. No setup or coding knowledge needed. It’s ideal for quick testing, demos, or prototypes. Perfect for developers who want fast results.",
    "url": "https://vibehost.run?ref=zairok"
  },
  {
    "name": "RewriteSomething",
    "genre": "Content Creation AI",
    "desc": "RewriteSomething helps Shopify store owners write better product descriptions in seconds. Just paste some text and the tool improves it for sales. You can also regenerate different versions. It’s great for e-commerce content.",
    "url": "https://rewritesomething.com?ref=zairok"
  },
  {
    "name": "Hunch",
    "genre": "Productivity AI",
    "desc": "Hunch is an AI workspace for teams to brainstorm, plan, and finish tasks using top AI models. It connects various tools in one place. Ideal for creative and technical teams managing complex projects. Simple and powerful.",
    "url": "https://app.hunch.tools?ref=zairok"
  },
  {
    "name": "SeekMyDomain",
    "genre": "Creative Ideas AI",
    "desc": "SeekMyDomain helps users find great domain names using AI. Just type your idea or project, and the tool shows available domain names. It’s fast, smart, and beginner-friendly. Perfect for startups and website creators.",
    "url": "https://seekmydomain.com?ref=zairok"
  },
  {
    "name": "Mind Map Wizard",
    "genre": "Creative Ideas AI",
    "desc": "Mind Map Wizard is a free AI tool to make quick and easy mind maps. Enter a topic, and it creates a visual map to organize your ideas. It’s open-source and simple to use. Great for students, thinkers, and planners.",
    "url": "https://mindmapwizard.com?ref=zairok"
  },
  {
    "name": "LLM Chat",
    "genre": "Writing AI",
    "desc": "LLM Chat is an AI assistant that helps with writing, translating, and summarizing text. It’s designed to boost your productivity with simple tools. Great for anyone who needs quick and smart content generation.",
    "url": "https://llmchat.co?ref=zairok"
  },
  {
    "name": "PDF Summarizer",
    "genre": "Writing AI",
    "desc": "PDF Summarizer is a free tool to shorten long PDF documents into easy summaries. Just upload your file and get the key points quickly. It’s great for students, researchers, and busy professionals.",
    "url": "https://pdfsummarizer.net?ref=zairok"
  },
  {
    "name": "Poppop AI",
    "genre": "Audio AI",
    "desc": "Poppop AI turns your text into sound effects using artificial intelligence. It’s free and works well for videos, games, and creative projects. Just type your idea and listen to the result. Very easy to use.",
    "url": "https://poppop.ai?ref=zairok"
  },
  {
    "name": "Agenda Hero",
    "genre": "Productivity AI",
    "desc": "Agenda Hero helps create calendar events from text, images, or PDFs. The “Magic” feature makes it easy to plan meetings or reminders. Ideal for students and professionals who manage lots of schedules.",
    "url": "https://agendahero.com?ref=zairok"
  },
  {
    "name": "Noiz PDF Summarizer",
    "genre": "Writing AI",
    "desc": "Noiz offers a free PDF summarizer with no sign-up. Upload your file, choose summary length, and get results instantly. Perfect for quick reading and study support. Very easy and fast to use.",
    "url": "https://noiz.io/free-ai-tools/ai-pdf-summarizer?ref=zairok"
  },
  {
    "name": "Chatty",
    "genre": "Study AI",
    "desc": "Chatty helps improve your English writing using AI. It gives feedback and suggestions for emails, posts, or messages. Useful for learners or professionals wanting to write better. Friendly and simple to use.",
    "url": "https://chatty.wastu.net?ref=zairok"
  },
  {
    "name": "Sidejot",
    "genre": "Productivity AI",
    "desc": "Sidejot is a simple app to manage your daily goals and tasks. You can write your plans and track them easily. The clean interface helps you stay focused. Great for personal use or small teams.",
    "url": "https://sidejot.com?ref=zairok"
  },
  {
    "name": "Documator",
    "genre": "Writing AI",
    "desc": "Documator is a free online document summarization tool that enables users to extract the key points from long-form text without any sign-up. Designed for speed and simplicity, it is ideal for students, researchers, and busy professionals who need quick summaries of documents or articles.",
    "url": "https://documator.cc/?ref=zairok"
  },
  {
    "name": "AI Content Creation Ideas",
    "genre": "Content Creation AI",
    "desc": "This free AI-powered tool helps users brainstorm and generate content creation ideas across various formats. Whether you’re starting a blog, YouTube channel, or social media project, it offers structured, intelligent suggestions to kickstart your creative process.",
    "url": "https://aifreebox.com/list/ai-content-creation-ideas-generator?ref=zairok"
  },
  {
    "name": "Resume Objective Generator",
    "genre": "Productivity AI",
    "desc": "This free AI resume objective generator assists job seekers by crafting compelling, tailored objectives based on roles and industries. It provides a fast and professional way to improve the impact of your resume without needing expert writing skills.",
    "url": "https://aifreebox.com/list/ai-resume-objective-generator?ref=zairok"
  },
  {
    "name": "Resume Headline Generator",
    "genre": "Productivity AI",
    "desc": "Create a standout resume headline instantly with this free tool. Using AI, it crafts sharp and attention-grabbing headlines tailored to your background and field, making your job application more noticeable to recruiters.",
    "url": "https://aifreebox.com/list/ai-resume-headline-generator?ref=zairok"
  },
  {
    "name": "LinkedIn Experience Description Generator",
    "genre": "Productivity AI",
    "desc": "This free tool helps users create professional, well-structured experience descriptions for their LinkedIn profiles. It enhances your digital brand by transforming basic job info into impactful narratives that highlight your contributions and skills.",
    "url": "https://aifreebox.com/list/ai-linkedin-experience-description-generator?ref=zairok"
  },
  {
    "name": "YouTube Shorts Idea Generator",
    "genre": "Content Creation AI",
    "desc": "The free YouTube Shorts Idea Generator sparks new creative directions by suggesting trendy, algorithm-friendly video ideas. Designed for content creators looking to boost engagement, it’s a quick way to stay ahead in the short-form content game.",
    "url": "https://aifreebox.com/list/ai-youtube-short-idea-generator?ref=zairok"
  },
  {
    "name": "AI Description Generator",
    "genre": "Writing AI",
    "desc": "This free AI Description Generator helps users create product or content descriptions with professional polish. Suitable for online sellers, bloggers, and marketers, it transforms key points into fluent, market-ready descriptions in seconds.",
    "url": "https://aifreebox.com/list/ai-description-generator?ref=zairok"
  },
  {
    "name": "Drawing Prompts Generator",
    "genre": "Creative Ideas AI",
    "desc": "This free tool provides a rich collection of imaginative prompts to inspire your drawing sessions. Ideal for artists facing creative blocks or practicing regularly, it delivers random, fun, and thought-provoking ideas instantly.",
    "url": "https://aifreebox.com/list/ai-drawing-prompts-generator?ref=zairok"
  },
  {
    "name": "YouTube Keyword Generator",
    "genre": "Content Creation AI",
    "desc": "Optimize your video reach with this free AI-powered YouTube Keyword Generator. It suggests high-performing keywords based on your niche and content type, helping creators improve their SEO and discoverability.",
    "url": "https://aifreebox.com/list/ai-youtube-keyword-generator?ref=zairok"
  },
  {
    "name": "AI Study Guide Generator",
    "genre": "Study AI",
    "desc": "This free AI tool lets students generate customized study guides based on any topic or subject. It simplifies complex concepts into structured formats that aid better understanding and preparation.",
    "url": "https://aifreebox.com/list/ai-study-guide-generator?ref=zairok"
  },
  {
    "name": "YouTube Summarizer",
    "genre": "Study AI",
    "desc": "YouTube Summarizer is a free AI-powered service that generates concise summaries of long YouTube videos. It helps users save time by capturing the essence of educational or tutorial content without watching the full video.",
    "url": "https://youtube-summarizer.vercel.app/?ref=zairok"
  },
  {
    "name": "AI Question Generator",
    "genre": "Writing AI",
    "desc": "This free tool assists educators and learners by generating practice questions on any topic. Whether it’s for exams or daily learning, it helps reinforce knowledge through automatically created quizzes.",
    "url": "https://aifreebox.com/list/ai-question-generator?ref=zairok"
  },
  {
    "name": "AI Essay Topic Generator",
    "genre": "Writing AI",
    "desc": "Perfect for students, bloggers, and teachers, this free tool suggests a wide range of essay topics. It covers academic, creative, and niche subjects to inspire meaningful and engaging writing pieces.",
    "url": "https://aifreebox.com/list/ai-essay-topic-generator?ref=zairok"
  },
  {
    "name": "AI Blog Post Generator",
    "genre": "Content Creation AI",
    "desc": "This free blog post generator streamlines the content creation process by drafting structured articles from a single prompt. Ideal for content marketers and bloggers looking to save time and boost output.",
    "url": "https://aifreebox.com/list/ai-blog-post-generator?ref=zairok"
  },
  {
    "name": "AI Notes Generator",
    "genre": "Study AI",
    "desc": "With this free tool, users can turn dense texts into simplified notes. It’s perfect for students, researchers, and professionals who want to capture and remember key insights efficiently.",
    "url": "https://aifreebox.com/list/ai-notes-generator?ref=zairok"
  },
  {
    "name": "AI Answer Generator",
    "genre": "Study AI",
    "desc": "This free AI tool delivers instant answers to user questions across academic and general topics. It’s helpful for learners seeking quick explanations and support with homework or study topics.",
    "url": "https://aifreebox.com/list/ai-answer-generator?ref=zairok"
  },
  {
    "name": "YouTube Hashtag Generator",
    "genre": "Content Creation AI",
    "desc": "Boost your video reach with this free AI hashtag generator for YouTube. It creates niche-relevant hashtags to improve video discoverability and engagement across the platform.",
    "url": "https://aifreebox.com/list/youtube-hashtag-generator?ref=zairok"
  },
  {
    "name": "YouTube Tags Generator",
    "genre": "Content Creation AI",
    "desc": "This free AI tool provides optimized YouTube tags to help your videos rank better. It analyzes your video type and suggests keyword-rich tags for broader reach and algorithm friendliness.",
    "url": "https://aifreebox.com/list/youtube-tags-generator?ref=zairok"
  },
  {
    "name": "YouTube Title Generator",
    "genre": "Content Creation AI",
    "desc": "Get click-worthy video titles for free with this AI-powered tool. It creates compelling, SEO-friendly YouTube titles that can boost your views and improve your video’s first impression.",
    "url": "https://aifreebox.com/list/youtube-title-generator?ref=zairok"
  },
  {
    "name": "AI Writing Assistant",
    "genre": "Writing AI",
    "desc": "This free writing assistant helps users compose emails, blog posts, and social media captions. With smart suggestions and grammar corrections, it enhances writing quality in real time.",
    "url": "https://aifreebox.com/list/ai-writing-assistant?ref=zairok"
  },
  {
    "name": "YouTube Hooks Generator",
    "genre": "Content Creation AI",
    "desc": "This free AI-based tool helps you craft strong opening lines or “hooks” for your YouTube videos. Designed to maximize audience retention, it generates catchy intros that improve click-through and viewer engagement.",
    "url": "https://aifreebox.com/list/youtube-hooks-generator?ref=zairok"
  },
  {
    "name": "AI Blog Writer",
    "genre": "Writing AI",
    "desc": "AI Blog Writer is a free writing platform that helps users create complete blog posts based on input topics. It’s ideal for marketers and bloggers who want fast, structured, and SEO-friendly content creation.",
    "url": "https://aifreebox.com/list/ai-blog-writer?ref=zairok"
  },
  {
    "name": "YouTube Script Generator",
    "genre": "Content Creation AI",
    "desc": "This free tool enables creators to write engaging YouTube scripts instantly. With AI-driven suggestions, it helps structure scenes and dialogues for clear, professional, and captivating video content.",
    "url": "https://aifreebox.com/list/youtube-video-script-generator?ref=zairok"
  },
  {
    "name": "Instagram Hashtag Generator",
    "genre": "Content Creation AI",
    "desc": "Optimize your Instagram reach using this free AI tool that generates popular and trending hashtags tailored to your niche. It increases visibility and ensures posts are discovered by relevant audiences.",
    "url": "https://aifreebox.com/list/instagram-hashtag-generator?ref=zairok"
  },
  {
    "name": "AI Essay Extender",
    "genre": "Writing AI",
    "desc": "This free tool helps expand the length of your essays while preserving the original meaning. Perfect for students and professionals who need to meet word count requirements effortlessly.",
    "url": "https://aifreebox.com/list/ai-essay-extender?ref=zairok"
  },
  {
    "name": "AI Art Generator",
    "genre": "Image Generation AI",
    "desc": "Create stunning digital artwork using this free AI image generator. Simply enter a prompt and let the platform produce detailed visuals in various styles suitable for creative projects.",
    "url": "https://aifreebox.com/image-generator/ai-art-generator?ref=zairok"
  },
  {
    "name": "AI Vectormind Generator",
    "genre": "Art Style & Effects AI",
    "desc": "This free tool specializes in generating vector-style illustrations based on AI prompts. Users can create minimal, mind-map-inspired graphics perfect for presentations and infographics.",
    "url": "https://aifreebox.com/image-generator/ai-vectormind-generator?ref=zairok"
  },
  {
    "name": "AI Movie Cover Generator",
    "genre": "Art Style & Effects AI",
    "desc": "Transform text prompts into cinematic movie-style covers for free. This AI tool allows users to explore a unique blend of illustration and storytelling perfect for digital creators.",
    "url": "https://aifreebox.com/image-generator/ai-movie-cover-generator?ref=zairok"
  },
  {
    "name": "AI Pixel Game Art Generator",
    "genre": "Art Style & Effects AI",
    "desc": "This free AI tool generates 2D pixel-style game art from simple ideas or prompts. It’s great for indie developers or retro-themed artists looking for quick asset inspiration.",
    "url": "https://aifreebox.com/image-generator/ai-2d-pixel-games-art-generator?ref=zairok"
  },
  {
    "name": "AI Charisma Image Generator",
    "genre": "Art Style & Effects AI",
    "desc": "Create expressive, emotionally charged images using this free AI-powered visual tool. It’s great for portrait-style illustration with vibrant, stylized effects.",
    "url": "https://aifreebox.com/image-generator/ai-charisma-image-generator?ref=zairok"
  },
  {
    "name": "Flat Vector Art Generator",
    "genre": "Art Style & Effects AI",
    "desc": "This free platform converts prompts into flat vector illustrations, making it ideal for web designers and marketers who need sleek, scalable graphics for modern branding.",
    "url": "https://aifreebox.com/image-generator/ai-flatvector-generator?ref=zairok"
  },
  {
    "name": "Minimal Abstract Generator",
    "genre": "Art Style & Effects AI",
    "desc": "Generate minimal, abstract artwork for free using this AI-based tool. Ideal for modern visual aesthetics, it supports various themes with high-quality abstract outputs.",
    "url": "https://aifreebox.com/image-generator/ai-minimalabstract-generator?ref=zairok"
  },
  {
    "name": "PromptHackers Prompt Generator",
    "genre": "Creative Ideas AI",
    "desc": "This free tool by PromptHackers helps generate effective prompts for ChatGPT and other LLMs. It’s perfect for users looking to get better, more accurate AI responses.",
    "url": "https://www.prompthackers.co/chatgpt-prompt-generator?ref=zairok"
  },
  {
    "name": "Qwen AI",
    "genre": "Writing AI",
    "desc": "Qwen AI, built by Alibaba’s Tongyi Lab, is a powerful assistant for writing, reasoning, and coding. It offers a free version for general use and serves both personal and enterprise needs.",
    "url": "https://chat.qwen.ai/?ref=zairok"
  },
  {
    "name": "TinyWow",
    "genre": "Productivity AI",
    "desc": "TinyWow provides over 200 free online tools that handle PDFs, text editing, image compression, and more. With no login required, it’s ideal for fast, one-click utilities for personal and professional use.",
    "url": "https://tinywow.com?ref=zairok"
  },
  {
    "name": "Napkin AI",
    "genre": "Content Creation AI",
    "desc": "Napkin AI is a free visual content creator that transforms plain text into engaging graphics for storytelling. It’s ideal for decks, documents, and social media visuals that need compelling presentation.",
    "url": "https://www.napkin.ai/?ref=zairok"
  },
  {
    "name": "ChatGPT Free Hub",
    "genre": "Search & Discovery AI",
    "desc": "ChatGPT Free Hub gives access to popular AI models like Claude, Gemini, and GPT for free. It acts as a centralized gateway for exploring various LLMs from one interface.",
    "url": "https://chatgptfree.ai?ref=zairok"
  },
  {
    "name": "ChatJams",
    "genre": "Audio AI",
    "desc": "ChatJams is a free AI music assistant that curates custom Spotify playlists. It’s an experimental open-source tool designed to recommend unique and niche tracks based on your taste.",
    "url": "https://www.chatjams.ai/?ref=zairok"
  },
  {
    "name": "Genspark AI",
    "genre": "Writing AI",
    "desc": "Genspark AI is a free super-agent that offers tools like AI chat, slides, sheets, and more. It’s designed for productivity and supports personalized AI workflows across creative and technical domains.",
    "url": "https://www.genspark.ai/?ref=zairok"
  },
  {
    "name": "AI Icon Maker",
    "genre": "Logo & Icons",
    "desc": "Create custom icons for free with this AI tool that transforms text prompts into clean, versatile iconography. Useful for UI/UX, branding, and personal projects.",
    "url": "https://aifreebox.com/image-generator/ai-icon-maker?ref=zairok"
  },
  {
    "name": "AI Doodle Logo Generator",
    "genre": "Logo & Icons",
    "desc": "This free AI tool allows users to generate creative logo designs with a hand-drawn or doodle style. It’s especially useful for fun projects, personal branding, or playful marketing visuals without hiring a designer.",
    "url": "https://aifreebox.com/image-generator/ai-doodlelogo-image-generator?ref=zairok"
  },
  {
    "name": "YouTube Thumbnail Generator",
    "genre": "Logo & Icons",
    "desc": "Generate custom YouTube thumbnails for free using this AI tool. Whether it’s for tutorials or entertainment videos, it helps creators grab viewer attention with bold, optimized visuals.",
    "url": "https://aifreebox.com/image-generator/ai-youtube-thumbnail-generator?ref=zairok"
  },
  {
    "name": "AI Hype Thumbnail Generator",
    "genre": "Logo & Icons",
    "desc": "This free generator produces “hype-style” YouTube thumbnails packed with emotion, contrast, and text. Ideal for vloggers and influencers aiming to boost their video click-through rates.",
    "url": "https://aifreebox.com/image-generator/ai-hype-thumbnail-generator?ref=zairok"
  },
  {
    "name": "Text-to-Speech Online",
    "genre": "Audio AI",
    "desc": "This free online text-to-speech tool allows users to convert any written content into spoken words. With multiple voices and adjustable speeds, it’s great for accessibility, learning, or media production.",
    "url": "https://www.text-to-speech.online/?ref=zairok"
  },
  {
    "name": "Infografix",
    "genre": "Productivity AI",
    "desc": "Infografix is a free AI tool that helps users create visually appealing infographics and data presentations. With customizable templates and smart design suggestions, it turns complex data into digestible visuals.",
    "url": "https://infografix.app/app/?ref=zairok"
  },
  {
    "name": "Mistral AI",
    "genre": "Coding AI",
    "desc": "Mistral AI offers a free, powerful platform for building and deploying custom AI models. With a focus on privacy, control, and flexibility, it enables developers to create tailored AI systems efficiently.",
    "url": "https://huggingface.co/spaces/hysts/mistral-7b/?ref=zairok"
  },
  {
    "name": "LearChat",
    "genre": "Study AI",
    "desc": "LearChat is a free AI-driven learning platform that enables users to engage in structured chat discussions. It offers a conversational approach to studying with intelligent guidance.",
    "url": "https://learchat.com/?ref=zairok"
  },
  {
    "name": "MindMap AI",
    "genre": "Writing AI",
    "desc": "MindMap AI helps users generate AI-powered mind maps for brainstorming and planning. The free tool instantly turns thoughts into structured visual maps ideal for students and professionals.",
    "url": "https://mindmapai.app/?ref=zairok"
  },
  {
    "name": "AI Drum Generator",
    "genre": "Audio AI",
    "desc": "AI Drum Generator lets music creators build drum tracks quickly with AI. The free tool supports BPM adjustment and multiple percussion styles for unique rhythm compositions.",
    "url": "https://aidrumgenerator.com/?ref=zairok"
  },
  {
    "name": "Photo Restoration AI",
    "genre": "Image Generation AI",
    "desc": "This free AI tool restores and enhances old or damaged photos online. It automatically improves image quality, reviving important visual memories with ease.",
    "url": "https://photobooth.online/en-us/photo-restoration?ref=zairok"
  },
  {
    "name": "Houmify",
    "genre": "Miscellaneous",
    "desc": "Houmify is a free AI-powered real estate assistant offering personalized property search, expert advice, and selling tools to help users find and manage homes with ease.",
    "url": "https://houmify.com/?ref=zairok"
  },
  {
    "name": "Write Me A Prayer",
    "genre": "Writing AI",
    "desc": "Write Me A Prayer generates heartfelt prayers based on topic and recipient. This free tool offers multi-language support and easy customization for spiritual needs.",
    "url": "https://writemeaprayer.com/?ref=zairok"
  },
 
  {
    "name": "Frodo Chatbot",
    "genre": "Writing AI",
    "desc": "Frodo is a private, free AI chatbot that runs directly in your browser using WebGPU. It provides secure and fast conversations without any login required.",
    "url": "https://frodo-chi.vercel.app/?ref=zairok"
  },
  {
    "name": "Decopy AI Detector",
    "genre": "Study AI",
    "desc": "Decopy's free AI Detector checks content for traces of AI generation with 99% accuracy. It supports multiple languages and helps identify ChatGPT, Gemini, and other models.",
    "url": "https://decopy.ai/ai-detector/?ref=zairok"
  },
  {
    "name": "Nouswise",
    "genre": "Study AI",
    "desc": "Nouswise is a free AI platform for managing knowledge and extracting answers from documents and media. It’s secure, private, and useful for teams or individuals.",
    "url": "https://nouswise.com/#plans?ref=zairok"
  },
  {
    "name": "Humanize.im",
    "genre": "Writing AI",
    "desc": "Humanize.im refines robotic AI content into smooth human-sounding text. This free tool helps bypass AI detection systems and improve readability.",
    "url": "https://humanize.im/?ref=zairok"
  },
  {
    "name": "Gen-Image",
    "genre": "Image Generation AI",
    "desc": "Gen-Image is a premium-level free AI image generator. It allows quick creation of artworks with community engagement and powerful rendering models.",
    "url": "https://gen-image.com/?ref=zairok"
  },
  {
    "name": "SupaWork Face Swap",
    "genre": "Image Generation AI",
    "desc": "SupaWork offers a free AI-based face swap tool for videos and photos. No registration is needed, and it works fast across platforms.",
    "url": "https://supawork.ai/ai-video-face-swap?ref=zairok"
  },
  {
    "name": "Vidu Studio",
    "genre": "Image Generation AI",
    "desc": "Vidu Studio provides a free AI tool that turns static images into video animations. Upload photos and generate smooth video clips effortlessly.",
    "url": "https://vidustudio.co/image-to-video?ref=zairok"
  },
  {
    "name": "PlantPhotoAI",
    "genre": "Image Generation AI",
    "desc": "PlantPhotoAI offers a free library of AI-generated plant images with accurate details. It caters to botany lovers and designers with downloadable content.",
    "url": "https://www.plantphotoai.com?ref=zairok"
  },
  {
    "name": "MemFree",
    "genre": "Miscellaneous",
    "desc": "MemFree is a hybrid AI-powered search engine. The free platform improves research by intelligently combining queries and returning structured results.",
    "url": "https://www.memfree.me?ref=zairok"
  },
  {
    "name": "BaiRBIE.me",
    "genre": "Image Generation AI",
    "desc": "BaiRBIE is a free AI parody generator that turns user images into playful caricatures inspired by dolls. No login or setup required.",
    "url": "https://www.bairbie.me/?ref=zairok"
  },
  {
    "name": "HeySong",
    "genre": "Audio AI",
    "desc": "HeySong AI lets users generate original songs using free tools. Compose tunes easily by describing moods, genres, or lyrics with natural input.",
    "url": "https://heysong.ai/?ref=zairok"
  },
  {
    "name": "SlideFlow",
    "genre": "Writing AI",
    "desc": "SlideFlow is a free AI slide generator that turns your text ideas into neat presentations. It saves time and effort while keeping your message strong.",
    "url": "https://slideflow.io?ref=zairok"
  },
  {
    "name": "SlideAI",
    "genre": "Writing AI",
    "desc": "SlideAI is a powerful presentation generator that uses AI to create beautiful slides. This free platform focuses on clarity and simplicity.",
    "url": "https://www.slideai.net?ref=zairok"
  },
  {
    "name": "Leia",
    "genre": "Coding AI",
    "desc": "Leia is a free AI website builder that lets users create personalized websites in minutes. No coding or design skills required.",
    "url": "https://heyleia.com?ref=zairok"
  },
  {
    "name": "Lenso.ai",
    "genre": "Image Generation AI",
    "desc": "Lenso.ai is a reverse image search tool using AI to find visually similar pictures. The free tool supports faces, places, and related images.",
    "url": "https://lenso.ai/?ref=zairok"
  },
  {
    "name": "Dejams",
    "genre": "Miscellaneous",
    "desc": "Dejams is a free AI-enhanced movie search engine. It provides suggestions, streaming availability, and film details from sources like IMDb and JustWatch.",
    "url": "https://dejams.com?ref=zairok"
  },
  {
    "name": "FreeFlux AI",
    "genre": "Image Generation AI",
    "desc": "FreeFlux.ai generates stunning AI images with high flexibility. Its credit-based system is free to use and supports multiple rendering models.",
    "url": "https://freeflux.ai/?ref=zairok"
  },
  {
    "name": "Shepherd.study",
    "genre": "Study AI",
    "desc": "Shepherd is a free AI-powered study tool backed by Y Combinator. It integrates flashcards, Q&A, and academic workspaces in one platform.",
    "url": "https://shepherd.study?ref=zairok"
  },
  {
    "name": "AI Logo Generator",
    "genre": "Image Generation AI",
    "desc": "This free AI logo generator transforms written prompts into beautiful logo designs. Users get results in minutes by just typing their idea.",
    "url": "https://ailogogenerator.net?ref=zairok"
  },
  {
    "name": "AI Face Swap IO",
    "genre": "Image Generation AI",
    "desc": "AI Face Swap is a free and no-login image editing tool that lets users swap faces for fun, memes, or personalization.",
    "url": "https://aifaceswap.io?ref=zairok"
  },
  {
    "name": "Faune AI",
    "genre": "Writing AI",
    "desc": "Faune is a free AI chatbot interface that supports large models like GPT-4 and Mistral. No login needed and built for privacy.",
    "url": "https://faune.ai?ref=zairok"
  },
  {
    "name": "ChatGPT Image Generator",
    "genre": "Image Generation AI",
    "desc": "This free image tool generates photos from text descriptions using ChatGPT’s ecosystem. It’s beginner-friendly and fast.",
    "url": "https://chat-gpt.photos/generateimage?ref=zairok"
  },
  {
    "name": "Thiings Collection",
    "genre": "Others",
    "desc": "Thiings.co is a curated platform offering free access to 3D models, animals, vehicles, and more. It invites creators to explore and contribute.",
    "url": "https://thiings.co/?ref=zairok"
  },
  {
    "name": "AI.Summarizer",
    "genre": "Writing AI",
    "desc": "AI.Summarizer offers free online summarization of long texts. It helps distill complex content into quick, readable overviews.",
    "url": "https://articlesummarizer.com/?ref=zairok"
  },
  {
    "name": "Geordy AI",
    "genre": "Others",
    "desc": "Geordy AI converts any URL into geo-optimized content using AI. It’s a free tool aimed at enhancing SEO and online presence.",
    "url": "https://geordy.ai/?ref=zairok"
  },
  {
    "name": "LMArena",
    "genre": "Games",
    "desc": "LMArena is a community-driven platform where users vote on AI improvements. Free and interactive, it gamifies AI research.",
    "url": "https://lmarena.ai/?ref=zairok"
  },
  {
    "name": "FLUX Playground",
    "genre": "Image Generation AI",
    "desc": "FLUX Playground by Black Forest Labs is a free creative platform where users can generate and refine images from text prompts. It features diverse visual styles and customization tools.",
    "url": "https://playground.bfl.ai?ref=zairok"
  },
  {
    "name": "Wondera",
    "genre": "Audio AI",
    "desc": "Wondera is a free AI music platform that lets users generate and collaborate on songs. It offers genre-spanning tools and hands-on production capabilities without cost.",
    "url": "https://www.wondera.ai/?ref=zairok"
  },
  {
    "name": "Golex AI",
    "genre": "Coding AI",
    "desc": "Golex AI allows users to build fully functional websites without coding. This free platform streamlines app creation with fast prototyping and user-friendly design.",
    "url": "https://golex.ai/?ref=zairok"
  },
  {
    "name": "Mimi Panda",
    "genre": "Image Generation AI",
    "desc": "Mimi Panda provides a free AI coloring page generator that transforms text prompts into printable art. Suitable for all ages, it encourages creativity effortlessly.",
    "url": "https://mimi-panda.com/ai-coloring-pages/?ref=zairok"
  },
  {
    "name": "Hunyuan T1",
    "genre": "Coding AI",
    "desc": "Hunyuan T1 by Tencent is a free AI demo space hosted on Hugging Face, showcasing intelligent generation for developers and learners to explore and test AI capabilities.",
    "url": "https://huggingface.co/spaces/tencent/Hunyuan-T1?ref=zairok"
  },
  {
    "name": "Baidu Yiyan",
    "genre": "Writing AI",
    "desc": "Yiyan by Baidu is a free AI assistant that helps with writing, brainstorming, and idea generation. It supports a wide range of creative and professional tasks.",
    "url": "https://yiyan.baidu.com/?ref=zairok"
  },
  {
    "name": "Lovable",
    "genre": "Coding AI",
    "desc": "Lovable is a free AI website and app builder that allows users to create fully functional digital products through conversation with AI — no tech background needed.",
    "url": "https://lovable.dev/?ref=zairok"
  },
  {
    "name": "Bugfree AI",
    "genre": "Study AI",
    "desc": "Bugfree AI is a free platform to prepare for technical interviews with system design challenges, AI mock interviews, and curated tech content to boost confidence.",
    "url": "https://bugfree.ai?ref=zairok"
  },
  {
    "name": "Journey AI Art",
    "genre": "Image Generation AI",
    "desc": "Journey AI Art Generator turns text prompts into stunning digital artworks. This free tool supports a wide creative range for designers and hobbyists alike.",
    "url": "https://journeyaiart.com/?ref=zairok"
  },
  {
    "name": "Vizcom",
    "genre": "Image Generation AI",
    "desc": "Vizcom is a free cloud-based platform that turns design sketches into 3D models and renders. Ideal for creatives and professionals looking to prototype fast.",
    "url": "https://app.vizcom.ai/?ref=zairok"
  },
  {
    "name": "Aipictors",
    "genre": "Image Generation AI",
    "desc": "Aipictors offers free AI-based image generation from prompts or references. Users can explore different styles and models with easy export options.",
    "url": "https://aipictors.com/generation?ref=zairok"
  },
  {
    "name": "TeeAI",
    "genre": "Image Generation AI",
    "desc": "TeeAI allows free generation of custom T-shirt designs using AI. Enter your ideas and get unique apparel visuals without needing design experience.",
    "url": "https://teeai.co.uk?ref=zairok"
  },
  {
    "name": "DigArt365",
    "genre": "Image Generation AI",
    "desc": "DigArt365 showcases AI-generated artworks in different categories. It serves as a free creative hub for artists to explore styles and visual inspirations.",
    "url": "https://digart365.com/?ref=zairok"
  },
  {
    "name": "AI Up House",
    "genre": "Image Generation AI",
    "desc": "AI Up House is a niche AI image platform focusing on iconic house-themed art. Users can create or explore themed visuals freely and instantly.",
    "url": "https://aiuphouse.com/?ref=zairok"
  },
  {
    "name": "thea.study",
    "genre": "Writing AI",
    "desc": "SmartStudy AI lets you create custom flashcards and quizzes effortlessly. Ideal for revision and spaced learning, this free platform is tailored for students seeking a smarter way to retain information.",
    "url": "https://thea.study?ref=zairok"
  },
  {
    "name": "scribehow.com",
    "genre": "Writing AI",
    "desc": "Scribe generates step-by-step guides from screen recordings. This free tool is perfect for onboarding, tutorials, and process documentation without manual effort.",
    "url": "https://scribehow.com?ref=zairok"
  },
  {
    "name": "gamma",
    "genre": "Writing AI",
    "desc": "Gamma enables you to turn ideas into beautiful presentations or documents. The free plan helps users design slides that are both interactive and responsive, using minimal input.",
    "url": "https://gamma.app?ref=zairok"
  },
  {
    "name": "klingai.com",
    "genre": "Writing AI",
    "desc": "Kling AI allows you to generate engaging videos and images from written prompts. This free AI-powered storytelling platform simplifies content creation with a visual twist.",
    "url": "https://klingai.com?ref=zairok"
  },
  {
    "name": "comic factory",
    "genre": "Writing AI",
    "desc": "AI Comic Factory by Hugging Face helps users create comic strips from text. This free tool supports various art styles, making it fun and accessible for storytelling.",
    "url": "https://huggingface.co/spaces/makem/ai-comic-factory?ref=zairok"
  },
  {
    "name": "DeepSite AI",
    "genre": "Coding AI",
    "desc": "This Hugging Face demo offers a GPT-powered coding assistant to generate, debug, and explain code in multiple languages. It’s a free and lightweight tool for developers.",
    "url": "https://enzostvs-deepsite.hf.space?ref=zairok"
  },
  {
    "name": "websim.ai",
    "genre": "Coding AI",
    "desc": "Websim AI allows users to build simple websites just by describing them. This free web development assistant is perfect for prototyping without any coding knowledge.",
    "url": "https://websim.ai?ref=zairok"
  },
  {
    "name": "w3schools.com",
    "genre": "Coding AI",
    "desc": "W3Schools offers beginner-friendly coding tutorials and references. The platform includes interactive editors and certifications—all freely available for learning web development.",
    "url": "https://w3schools.com?ref=zairok"
  },
  {
    "name": "Z AI",
    "genre": "Coding AI",
    "desc": "Z.ai is  designed to enhance user productivity through several applications and tools. The platform operates with an AI assistant.",
    "url": "https://chat.z.ai/?ref=zairok"
  },
  {
    "name": " Kobalt AI",
    "genre": "Coding AI",
    "desc": "KoboldAI is an open-source, browser-based AI storytelling assistant designed to help users create interactive fiction using local or remote large language models (LLMs). Unlike online AI tools, KoboldAI Lite runs locally or semi-locally with reduced system resource needs, giving you more privacy and customization..",
    "url": "https://lite.koboldai.net/?ref=zairok"
  },
  {
    "name": "emupedia.net",
    "genre": "Coding AI",
    "desc": "EmuOS by Emupedia emulates retro operating systems in your browser. It’s a fun, free tool that recreates classic computing experiences with access to old software.",
    "url": "https://emupedia.net/beta/emuos?ref=zairok"
  },
  {
    "name": "opensourcealternative.to",
    "genre": "Miscellaneous",
    "desc": "This site curates free, open-source alternatives to popular paid software. A useful tool for developers and teams seeking budget-friendly options.",
    "url": "https://opensourcealternative.to?ref=zairok"
  },
  {
    "name": "colorifyai.art",
    "genre": "Image Generation AI",
    "desc": "ColorifyAI transforms simple ideas or descriptions into vivid artworks. This free AI-powered painter is ideal for creating colorful digital visuals with ease.",
    "url": "https://colorifyai.art?ref=zairok"
  },
  {
    "name": "photopea.com",
    "genre": "Image Generation AI",
    "desc": "Photopea is a free web-based image editor offering Photoshop-like features. It supports PSD, XCF, and other formats, making it perfect for graphic designers and students.",
    "url": "https://photopea.com?ref=zairok"
  },
  {
    "name": "photoeditor.ai",
    "genre": "Image Generation AI",
    "desc": "This free tool lets you clean up images by removing objects or imperfections. It’s designed for fast edits and requires no installation or sign-up.",
    "url": "https://photoeditor.ai?ref=zairok"
  },
  {
    "name": "leiapix.com",
    "genre": "Image Generation AI",
    "desc": "LeiaPix turns regular photos into 3D parallax animations. This free tool enables users to export unique visual formats for social media and digital storytelling.",
    "url": "https://leiapix.com?ref=zairok"
  },
  {
    "name": "geospy.ai",
    "genre": "Search & Discovery AI",
    "desc": "GeoSpy AI attempts to find the location of a photo using clues in the image. This free tool is popular for games and challenges like GeoGuessr.",
    "url": "https://geospy.ai?ref=zairok"
  },
  {
    "name": "watermarkremover.io",
    "genre": "Image Generation AI",
    "desc": "WatermarkRemover.io is a free AI service that instantly removes watermarks from images. It supports high-resolution files and automatic detection.",
    "url": "https://watermarkremover.io?ref=zairok"
  },
  {
    "name": "metademolab.com",
    "genre": "Image Generation AI",
    "desc": "Meta Demo Lab’s SketchToon lets users draw and animate with AI. It turns sketches into lifelike motion, useful for creators and hobbyists.",
    "url": "https://sketch.metademolab.com?ref=zairok"
  },
  {
    "name": "wombo.art",
    "genre": "Art Style & Effects AI",
    "desc": "Wombo’s NFT art generator allows free creation of AI artworks suitable for NFTs. Choose styles, enter prompts, and generate shareable images in seconds.",
    "url": "https://app.wombo.art?ref=zairok"
  },
  {
    "name": "QR Code AI Art Gen",
    "genre": "Productivity AI",
    "desc": "This tool generates artistic QR codes that blend form and function. It’s free and perfect for marketing or branding purposes.",
    "url": "https://huggingface.co/spaces/innoai/QR-Code-Generator?ref=zairok"
  },
  {
    "name": "AI QR Code Generator",
    "genre": "Productivity AI",
    "desc": "This free AI QR code generator creates custom QR codes from text prompts. It’s ideal for marketing, events, and personal branding, allowing users to design unique codes.",
    "url": "https://www.qrgpt.io/start?ref=zairok"
  },
  {
    "name": "csm.ai",
    "genre": "Image Generation AI",
    "desc": "CSM’s 3D avatar generator creates realistic characters from photos. Free and fast, it’s popular for games, AR, and creative projects.",
    "url": "https://3d.csm.ai?ref=zairok"
  },
  {
    "name": "yandex.com/images",
    "genre": "Search & Discovery AI",
    "desc": "Yandex Image Search helps users find similar or reverse images. It’s a free visual search engine used globally for research and discovery.",
    "url": "https://yandex.com/images?ref=zairok"
  },
  {
    "name": "fotoforensics.com",
    "genre": "Search & Discovery AI",
    "desc": "FotoForensics provides tools to analyze image authenticity. With features like error level analysis, this free platform is useful for spotting photo edits.",
    "url": "https://fotoforensics.com?ref=zairok"
  },
  {
    "name": "lumalabs.ai",
    "genre": "Video AI",
    "desc": "Luma Labs’ Dream Machine generates realistic videos from text. This free platform supports high-quality rendering for creative storytelling.",
    "url": "https://lumalabs.ai/dream-machine?ref=zairok"
  },
  {
    "name": "scribehow.com",
    "genre": "Writing AI",
    "desc": "scribehow.com enables users to create detailed step-by-step guides automatically by capturing user actions. It’s ideal for onboarding, documentation, and process training. The platform is free to use and intuitive even for beginners.",
    "url": "https://scribehow.com?ref=zairok"
  },
  {
    "name": "gamma.app",
    "genre": "Writing AI",
    "desc": "gamma.app offers a powerful AI presentation builder that helps users create beautiful slides, documents, and web pages effortlessly. With drag-and-drop editing and AI support, it’s free and perfect for productivity and clarity.",
    "url": "https://gamma.app?ref=zairok"
  },
  {
    "name": "klingai.com",
    "genre": "Video AI",
    "desc": "klingai.com is a free tool to turn your text into video or image narratives. Whether youre storytelling or marketing, this platform provides high-quality, AI-powered visual content generation with minimal effort.",
    "url": "https://klingai.com?ref=zairok"
  },
  {
    "name": "comicfactory",
    "genre": "Creative Ideas AI",
    "desc": "comicfactory allows users to turn prompts into comic strips using Hugging Face models. The free tool is fun, easy to use, and great for storytelling or creative exploration.",
    "url": "https://huggingface.co/spaces/jbilcke-hf/ai-comic-factory?ref=zairok"
  },
  {
    "name": "enzostvs-deepsite.hf.space",
    "genre": "Coding AI",
    "desc": "This Hugging Face demo helps users write, debug, or explain code snippets using AI. With support for various languages, this free tool is excellent for learners and developers alike.",
    "url": "https://enzostvs-deepsite.hf.space?ref=zairok"
  },
  {
    "name": "websim.ai",
    "genre": "Coding AI",
    "desc": "websim.ai lets users build and deploy websites using simple instructions. The free AI platform removes technical barriers and generates complete responsive sites quickly.",
    "url": "https://websim.ai?ref=zairok"
  },
  {
    "name": "w3schools.com",
    "genre": "Study AI",
    "desc": "w3schools.com is one of the largest free platforms for learning web development. It offers step-by-step tutorials and AI-assisted learning to help beginners code confidently.",
    "url": "https://w3schools.com?ref=zairok"
  },
  {
    "name": "emupedia.net",
    "genre": "Games",
    "desc": "emupedia.net lets you explore a virtual OS interface and run retro apps and games inside your browser. It’s completely free and nostalgic for fans of early PC interfaces.",
    "url": "https://emupedia.net/beta/emuos?ref=zairok"
  },
  {
    "name": "opensourcealternative.to",
    "genre": "Search & Discovery AI",
    "desc": "opensourcealternative.to is a curated directory of free and open-source alternatives to popular paid SaaS tools. Users can explore by category and find cost-free software solutions easily.",
    "url": "https://opensourcealternative.to?ref=zairok"
  },
  {
    "name": "photopea.com",
    "genre": "Image Generation AI",
    "desc": "photopea.com is a powerful browser-based Photoshop alternative. It’s free and allows users to edit PSD, XD, and other formats directly in the browser without installation.",
    "url": "https://photopea.com?ref=zairok"
  },
  {
    "name": "photoeditor.ai",
    "genre": "Image Generation AI",
    "desc": "photoeditor.ai offers a clean interface for removing unwanted objects, enhancing photos, and adding effects. The free platform supports advanced features and quick edits.",
    "url": "https://photoeditor.ai?ref=zairok"
  },
  {
    "name": "leiapix.com",
    "genre": "Art Style & Effects AI",
    "desc": "leiapix.com turns your photos into animated 3D visuals using depth effects. It’s free and used widely for immersive social media visuals and profile enhancements.",
    "url": "https://leiapix.com?ref=zairok"
  },
  {
    "name": "geospy.ai",
    "genre": "Search & Discovery AI",
    "desc": "geospy.ai helps trace the origin of a photo using AI. Ideal for investigators, OSINT professionals, and curious minds, the platform is free to use and doesn’t require sign-up.",
    "url": "https://geospy.ai?ref=zairok"
  },
  {
    "name": "watermarkremover.io",
    "genre": "Image Generation AI",
    "desc": "watermarkremover.io removes unwanted watermarks from images in seconds. The tool is free, user-friendly, and ensures high output quality for personal or commercial use.",
    "url": "https://watermarkremover.io?ref=zairok"
  },
  {
    "name": "metademolab.com",
    "genre": "Art Style & Effects AI",
    "desc": "Sketch RNN at metademolab.com converts hand-drawn sketches into animated AI-driven visuals. This free tool is fun, experimental, and suited for creators of all skill levels.",
    "url": "https://sketch.metademolab.com?ref=zairok"
  },
  {
    "name": "wombo.art",
    "genre": "Art Style & Effects AI",
    "desc": "wombo.art is a well-known platform that generates stunning AI-powered artworks. Users can create NFTs, wallpapers, or prints with ease and zero design skills — all free.",
    "url": "https://app.wombo.art?ref=zairok"
  },
  {
    "name": "yandex.com",
    "genre": "Search & Discovery AI",
    "desc": "yandex.com/images offers powerful reverse image search capabilities. Users can upload any image and find visually similar content across the web instantly — completely free.",
    "url": "https://yandex.com/images?ref=zairok"
  },
  {
    "name": "fotoforensics.com",
    "genre": "Image Generation AI",
    "desc": "fotoforensics.com is a free tool to verify image authenticity. It performs deep forensic analysis like ELA and metadata extraction to check if a photo has been altered.",
    "url": "https://fotoforensics.com?ref=zairok"
  },
  {
    "name": "hailuoai.video",
    "genre": "Video AI",
    "desc": "hailuoai.video allows users to create videos from scripts or prompts using AI. It’s free and suitable for storytelling, education, or content marketing.",
    "url": "https://hailuoai.video?ref=zairok"
  },
  {
    "name": "lumalabs.ai",
    "genre": "Video AI",
    "desc": "lumalabs.ai offers Dream Machine, a free AI tool to convert text ideas into cinematic video clips. The platform is known for high realism and smooth transitions.",
    "url": "https://lumalabs.ai/dream-machine?ref=zairok"
  },
  {
    "name": "genmo.ai",
    "genre": "Video AI",
    "desc": "genmo.ai enables users to animate text and images with AI-powered visuals. This free platform helps creators build dynamic, engaging videos with minimal effort.",
    "url": "https://alpha.genmo.ai"
  },
  {
    "name": "runwayml.com",
    "genre": "Video AI",
    "desc": "runwayml.com is a full suite of AI media tools for video editing, image generation, and more. It offers generous free credits and is trusted by creative professionals.",
    "url": "https://app.runwayml.com?ref=zairok"
  },
  {
    "name": "vidmix.app",
    "genre": "Video AI",
    "desc": "vidmix.app is a free online video editor that supports AI templates, text overlays, transitions, and music syncing. Perfect for quick content creation on mobile and desktop.",
    "url": "https://vidmix.app?ref=zairok"
  },
  {
    "name": "eyecannndy.com",
    "genre": "Video AI",
    "desc": "eyecannndy.com provides a searchable library of video effects. It’s designed for editors and creators who want to quickly find and replicate VFX styles for free.",
    "url": "https://eyecannndy.com?ref=zairok"
  },
  {
    "name": "unscreen.com",
    "genre": "Video AI",
    "desc": "unscreen.com removes video backgrounds automatically without green screens. This free tool saves hours of editing and works directly in your browser.",
    "url": "https://unscreen.com?ref=zairok"
  },
  {
    "name": "vidwud.com",
    "genre": "Art Style & Effects AI",
    "desc": "vidwud.com provides AI face swapping tools for photos and videos. The tool is fast, browser-based, and completely free to use without login.",
    "url": "https://vidwud.com?ref=zairok"
  },
  {
    "name": "readtheirlips.com",
    "genre": "AI Assistant",
    "desc": "readtheirlips.com is a lip-reading AI that attempts to decode what a person is saying from silent video. It’s free and experimental, best used for fun or testing.",
    "url": "https://readtheirlips.com?ref=zairok"
  },
  {
    "name": "noclip.website",
    "genre": "Games",
    "desc": "noclip.website allows users to explore maps from classic video games in 3D. This free fan-made archive is both nostalgic and educational for gamers and developers.",
    "url": "https://noclip.website?ref=zairok"
  },
  {
    "name": "emulatorgames.online",
    "genre": "Games",
    "desc": "emulatorgames.online hosts hundreds of retro console games you can play right in your browser. From Pokémon to Mario, it’s all free and ready to play.",
    "url": "https://emulatorgames.online?ref=zairok"
  },
  {
    "name": "bluemaxima.org",
    "genre": "Games",
    "desc": "bluemaxima.org hosts Flashpoint, a free offline archive for thousands of Flash games and animations. Perfect for reliving early web entertainment.",
    "url": "https://bluemaxima.org/flashpoint/?ref=zairok"
  },

  {
    "name": "dungeonscrawl.com",
    "genre": "Creative Ideas AI",
    "desc": "dungeonscrawl.com lets you create RPG-style dungeon maps with AI. Ideal for game developers, DMs, and storytellers — and completely free to use.",
    "url": "https://dungeonscrawl.com?ref=zairok"
  },
  {
    "name": "geekprank.com",
    "genre": "Games",
    "desc": "geekprank.com offers fake screens and mock interfaces like “Windows XP,” fake virus alerts, and hacker terminals — all in good fun and totally free.",
    "url": "https://geekprank.com?ref=zairok"
  },
  {
    "name": "omnicontrol.space",
    "genre": "Art Style & Effects AI",
    "desc": "omnicontrol.space lets you upload real-world objects and receive AI-generated renderings or enhancements. Great for prototyping and exploration — all free.",
    "url": "https://huggingface.co/spaces/Yuanshi/OminiControl?ref=zairok"
  },
  {
    "name": "pdftobrainrot.org",
    "genre": "Games",
    "desc": "pdftobrainrot.org turns PDF textbooks into quirky, gamified AI videos. It’s a hilarious and educational way to reinterpret dry content for fun.",
    "url": "https://pdftobrainrot.org?ref=zairok"
  },
  {
    "name": "GptGames",
    "genre": "Games",
    "desc": "GptGames is a free platform where users can play text-based games powered by GPT-3.5. It offers a variety of interactive adventures, puzzles, and challenges that adapt to player choices.",
    "url": "https://gptgames.io?ref=zairok"
  },
  {
    "name": "AI writer",
    "genre": "Writing AI",
    "desc": "ToolBaz is a 100% free AI writer tool that helps you generate quality text quickly. It supports all types of writing, from essays to blog posts. No sign-up is needed and it's ideal for boosting writing speed. Simple, fast, and completely free to use.",
    "url": "https://toolbaz.com/writer/ai-writer?ref=zairok"
  },
  {
    "name": "AI Content Generator",
    "genre": "Writing AI",
    "desc": "AIContentGenerator lets you create engaging content for any topic with the help of AI. This free tool is perfect for marketers, students, and creators needing fast content. It saves time and boosts creativity. No login or payment required.",
    "url": "https://toolbaz.com/writer/ai-content-generator?ref=zairok"
  },
  {
    "name": "AI Writing Assistant",
    "genre": "Writing AI",
    "desc": "AIWritingAssistant improves your drafts by suggesting edits and generating better phrasing. It’s a free tool that helps you write cleaner and more naturally. Perfect for emails, reports, and essays. Fast, effective, and free with no account needed.",
    "url": "https://toolbaz.com/writer/ai-writing-assistant?ref=zairok"
  },
  {
    "name": "AI Story Generator",
    "genre": "Writing AI",
    "desc": "AIStoryGenerator helps you write original stories with plot and character ideas in seconds. It’s a free tool for writers, students, and creatives seeking inspiration. Great for fiction, kids’ tales, or brainstorming. No sign-up required and fully free.",
    "url": "https://toolbaz.com/writer/ai-story-generator?ref=zairok"
  },
  {
    "name": "AI Comic Generator",
    "genre": "Writing AI",
    "desc": "AIComicGenerator creates funny or creative comic dialogues instantly for free. Ideal for comic fans, creators, or casual entertainment. Generate amusing scripts in seconds with no cost. Easy to use and totally free with no login required.",
    "url": "https://toolbaz.com/writer/ai-comic-generator?ref=zairok"
  },
  {
    "name": "AI Image Generator",
    "genre": "Image Generation AI",
    "desc": "AIImageGenerator allows users to turn text into high-quality images for free. Ideal for creatives, designers, or content creators needing visuals fast. No design skills needed — just type and generate. No login required and 100% free.",
    "url": "https://toolbaz.com/image/ai-image-generator?ref=zairok"
  },
  {
    "name": "Lyric Generator",
    "genre": "Writing AI",
    "desc": "LyricGenerator helps you write song lyrics across various genres instantly. It’s a free and fun tool for musicians, rappers, or casual writers. Just enter a theme and get lyrics in seconds. No account needed, and totally free.",
    "url": "https://toolbaz.com/writer/lyric-generator?ref=zairok"
  },
  {
    "name": "Rhyme Generator",
    "genre": "Writing AI",
    "desc": "RhymeGenerator is a free AI tool that finds perfect rhymes for your songs or poems. Great for artists, poets, and writers looking for lyrical flow. Fast, simple, and creative aid for your writing. Free to use with no login.",
    "url": "https://toolbaz.com/writer/rhyme-generator?ref=zairok"
  },
  {
    "name": "Plagiarism Remover",
    "genre": "Writing AI",
    "desc": "PlagiarismRemover helps you rewrite text to make it unique and plagiarism-free. It’s a free AI tool ideal for students, bloggers, or writers. Simply paste content and get a fresh version. Completely free and no sign-up required.",
    "url": "https://toolbaz.com/writer/plagiarism-remover?ref=zairok"
  },
  {
    "name": "Sentence Rewriter",
    "genre": "Writing AI",
    "desc": "SentenceRewriter rephrases your sentences for better clarity and uniqueness. This free AI tool helps improve grammar and tone effortlessly. Ideal for essays, reports, or online posts. Easy to use and totally free.",
    "url": "https://toolbaz.com/writer/sentence-rewriter?ref=zairok"
  },
  {
    "name": "Paragraph Rewriter",
    "genre": "Writing AI",
    "desc": "ParagraphRewriter is a free tool that transforms full paragraphs into improved, unique versions. Great for students, bloggers, or content creators. Keeps your meaning while enhancing clarity. No account required — 100% free.",
    "url": "https://toolbaz.com/writer/paragraph-rewriter?ref=zairok"
  },
  {
    "name": "Essay Rewriter",
    "genre": "Writing AI",
    "desc": "EssayRewriter helps you rewrite essays to be clearer, more original, and error-free. It’s a completely free tool for students and academic writers. Just paste and improve instantly. No sign-up needed, fully free.",
    "url": "https://toolbaz.com/writer/essay-rewriter?ref=zairok"
  },
  {
    "name": "Essay Extender",
    "genre": "Writing AI",
    "desc": "EssayExtender increases your essay length while maintaining meaning and flow. It’s a free AI tool useful for meeting word counts quickly. Helpful for students under deadline pressure. Totally free and no login needed.",
    "url": "https://toolbaz.com/writer/essay-extender?ref=zairok"
  },
  {
    "name": "AI Summarizer",
    "genre": "Writing AI",
    "desc": "AISummarizer shortens long text into quick summaries using smart AI. This free tool is perfect for studying, research, or content briefs. Just paste any text and get key points. Fast, accurate, and fully free.",
    "url": "https://toolbaz.com/writer/ai-summarizer?ref=zairok"
  },
  {
    "name": "AI CodeWriter",
    "genre": "Coding AI",
    "desc": "AICodeWriter helps generate or improve code snippets in seconds using AI. It’s a free tool useful for developers, students, and learners. Supports multiple languages and is easy to use. No account needed, 100% free.",
    "url": "https://toolbaz.com/writer/ai-code-writer?ref=zairok"
  },
  {
    "name": "Wellpin",
    "genre": "Productivity AI",
    "desc": "Wellpin is a free AI scheduling tool for individuals and teams. It helps avoid overlapping meetings and integrates with calendars and video apps. The interface is clean and easy to use. Great for boosting productivity without paying anything.",
    "url": "https://wellpin.io?ref=zairok"
  },
  {
    "name": "URLtoAny",
    "genre": "Productivity AI",
    "desc": "URLtoAny is a free tool that converts web pages into different formats quickly. It helps you extract, transform, and share web content with ease. No need for coding or complex steps. Completely free and simple to use.",
    "url": "https://www.urltoany.com?ref=zairok"
  },
  {
    "name": "OpenAIFM",
    "genre": "Audio AI",
    "desc": "OpenAIFM is a free interactive tool for trying OpenAI’s text-to-speech voices. Developers can customize and test different voice styles using the API. Great for building speech features into apps. It’s totally free to explore and use.",
    "url": "https://www.openai.fm?ref=zairok"
  },
  {
    "name": "TextBehindImage",
    "genre": "Image Generation AI",
    "desc": "TextBehindImage lets you add text to images using a free online tool. Upload your image or use templates for fast design. Great for quotes, posts, or visual content. No login needed and completely free to use.",
    "url": "https://textbehindimage.site/app?ref=zairok"
  },
  {
    "name": "WukoAI",
    "genre": "Study AI",
    "desc": "WukoAI is a free article summarizer that works by email. Just send a URL to their special email and get a quick summary back. Great for saving time on long reads. It’s easy to use and totally free.",
    "url": "https://wuko.ai?ref=zairok"
  },
  {
    "name": "PubMedAI",
    "genre": "Search & Discovery AI",
    "desc": "PubMedAI is a smart tool for finding and analyzing medical research. It gives better search results with AI and supports deep exploration. Ideal for students, doctors, and researchers. It’s free and very useful for academic work.",
    "url": "https://www.pubmed.ai/?ref=zairok"
  },
  {
    "name": "CROBenchmark",
    "genre": "Productivity AI",
    "desc": "CROBenchmark helps users compare websites based on conversion performance. It includes free access to data across many industries and countries. Great for marketers and business owners. Insightful and completely free to explore.",
    "url": "https://app.crobenchmark.com?ref=zairok"
  },
  {
    "name": "GitPodcast",
    "genre": "Audio AI",
    "desc": "GitPodcast turns GitHub activity into spoken podcast updates. It helps developers stay informed through audio summaries. A fun and free way to keep up with projects. No sign-up needed to try.",
    "url": "https://www.gitpodcast.com/?ref=zairok"
  },
  {
    "name": "XToVoice",
    "genre": "Audio AI",
    "desc": "XToVoice transforms your X (Twitter) profile into a voice and animated avatar. It uses AI to create a digital version of your social media style. Perfect for creators and developers. Free and easy to try.",
    "url": "https://xtovoice.elevenlabs.io?ref=zairok"
  },
  {
    "name": "LivePortrait",
    "genre": "Video AI",
    "desc": "LivePortrait is a free AI tool that turns photos into moving animations. It brings portraits to life by adding smooth, natural motion. Perfect for creating avatars, story visuals, or fun effects. Hosted on Hugging Face and easy to try.",
    "url": "https://huggingface.co/spaces/KwaiVGI/LivePortrait?ref=zairok"
  },
  {
    "name": "CharacterGen",
    "genre": "Creative Ideas AI",
    "desc": "CharacterGen is a free AI tool to create characters for games, stories, and art. Just describe a character and it generates cool designs instantly. Great for creators and hobbyists. Fast, interactive, and totally free to use.",
    "url": "https://huggingface.co/spaces/VAST-AI/CharacterGen?ref=zairok"
  },
  {
    "name": "Formshare",
    "genre": "Productivity AI",
    "desc": "Formshare is a free AI-powered tool that builds smart forms without code. It lets you create interactive, chat-style forms with ease. Perfect for surveys, feedback, or lead capture. Easy, fast, and completely free to use.",
    "url": "https://formshare.ai/?ref=zairok"
  },
  {
    "name": "ChainClarity",
    "genre": "Search & Discovery AI",
    "desc": "ChainClarity is a free AI tool that explains cryptocurrency whitepapers in simple terms. It helps users understand crypto projects better and stay informed. Ideal for investors, learners, or researchers. Easy to use and no cost.",
    "url": "https://chainclarity.io?ref=zairok"
  },
  {
    "name": "Ploogins",
    "genre": "Productivity AI",
    "desc": "Ploogins is a free AI tool for discovering and comparing WordPress plugins. It offers smart suggestions based on your needs and site goals. Great for bloggers, developers, or businesses. Simple, efficient, and free to explore.",
    "url": "https://ploogins.com?ref=zairok"
  },
  {
    "name": "Sonauto",
    "genre": "Audio AI",
    "desc": "Sonauto is a music creation platform powered by AI that’s free to try. You can generate tracks, auto-tag genres, and edit lyrics easily. It’s built for music lovers, artists, and creators. Fun, creative, and completely free.",
    "url": "https://sonauto.ai/?ref=zairok"
  },
  {
    "name": "MagicTime",
    "genre": "Video AI",
    "desc": "MagicTime is a free AI tool that generates smooth, realistic time-lapse videos. It uses powerful simulators to improve animation quality. Great for artists, filmmakers, and researchers. Easy to use and no sign-up required.",
    "url": "https://huggingface.co/spaces/BestWishYsh/MagicTime?ref=zairok"
  },
  {
    "name": "Creatie",
    "genre": "Productivity AI",
    "desc": "Creatie was a free AI product design tool built to simplify UI/UX workflows. It helped designers create mockups and ideas quickly. The service ended on August 4, 2025. Users are encouraged to check out Readdy.ai instead.",
    "url": "https://creatie.ai?ref=zairok"
  },
  {
    "name": "AskLegal",
    "genre": "Productivity AI",
    "desc": "AskLegal is a free AI tool that helps answer legal questions and draft documents. It’s easy to use and built for people with no legal background. Great for personal or business use. Simple, fast, and totally free.",
    "url": "https://asklegal.bot?ref=zairok"
  },
  {
    "name": "LogoFast",
    "genre": "Art Style & Effects AI",
    "desc": "LogoFast is a free online logo maker that helps you create high-quality logos fast. It includes templates and customization for businesses and creators. No design skills needed to get started. Simple, professional, and free to use.",
    "url": "https://logofa.st?ref=zairok"
  },
  {
    "name": "Wasitai",
    "genre": "Miscellaneous",
    "desc": "Wasitai is a unique platform offering tools or experiences that aren’t widely known yet. The details are limited, but the site may include experimental or creative AI features. It appears free to use. More exploration may be needed.",
    "url": "https://wasitai.com?ref=zairok"
  },
  {
    "name": "LumaLabs",
    "genre": "Video AI",
    "desc": "LumaLabs lets you create and explore NeRFs (Neural Radiance Fields) using AI. It features free tools for capturing and sharing 3D scenes. Ideal for creators, hobbyists, and 3D enthusiasts. Completely free to explore and use.",
    "url": "https://lumalabs.ai/?ref=zairok"
  },
  {
    "name": "IllusionDiffusion",
    "genre": "Art Style & Effects AI",
    "desc": "IllusionDiffusion is a free tool that turns your ideas into mind-bending visual illusions. It uses Stable Diffusion and QR Control Net for stunning results. Great for creative artists and designers. Hosted on Hugging Face and free to try.",
    "url": "https://huggingface.co/spaces/AP123/IllusionDiffusion?ref=zairok"
  },
  {
    "name": "Sizzle",
    "genre": "Study AI",
    "desc": "Sizzle is an interactive learning platform powered by AI that makes studying fun. It uses free quizzes and smart questions to help you learn better. Ideal for students of all ages. Easy to use and totally free.",
    "url": "https://web.szl.ai?ref=zairok"
  },
  {
    "name": "LookRight",
    "genre": "Creative Ideas AI",
    "desc": "LookRight lets you upload photos and get AI-powered feedback on your outfits. The tool is currently free and in beta, offering a range of prompt-based style insights. Ideal for fashion lovers and creators. Simple and fun to use.",
    "url": "https://lookright.ai?ref=zairok"
  },
  {
    "name": "ChecklistGenerator",
    "genre": "Productivity AI",
    "desc": "ChecklistGenerator is a free AI tool that builds detailed checklists for any task or industry. It uses GPT-4 to offer smart templates tailored to your needs. Great for teams, planning, and workflows. Easy and completely free.",
    "url": "https://checklistgenerator.ai?ref=zairok"
  },
  {
    "name": "TextFX",
    "genre": "Writing AI",
    "desc": "TextFX is a free AI tool by Google that plays with words creatively. It helps generate similes, acronyms, alliterations, and more for your writing. Built for poets, writers, and creators. Totally free and fun to use.",
    "url": "https://textfx.withgoogle.com?ref=zairok"
  },
  {
    "name": "Tripadvisor",
    "genre": "Search & Discovery AI",
    "desc": "Tripadvisor is a popular platform for travel reviews, planning, and bookings. While not fully AI-driven, it features free tools to compare hotels, restaurants, and activities. Used by millions worldwide. Great for planning trips easily.",
    "url": "https://www.tripadvisor.com?ref=zairok"
  },
  {
    "name": "Layla",
    "genre": "Search & Discovery AI",
    "desc": "Layla is a free AI travel planner that helps you organize your trip from start to finish. It finds flights, hotels, and builds itineraries quickly. Saves you time and effort. Easy, helpful, and completely free to use.",
    "url": "https://layla.ai?ref=zairok"
  },
  {
    "name": "SiteExplainer",
    "genre": "Productivity AI",
    "desc": "SiteExplainer is a free AI tool that simplifies confusing websites into plain summaries. Great for users trying to understand corporate or technical pages. Saves time and boosts clarity. No account needed and fully free.",
    "url": "https://www.siteexplainer.com/?ref=zairok"
  },

  {
    "name": "VOID",
    "genre": "Productivity AI",
    "desc": "VOID is your personal AI companion for daily tasks. It helps with writing, coding, and brainstorming ideas. The tool is easy to use and designed to boost your creativity. It’s completely free and requires no setup.",
    "url": "https://thevoidai.vercel.app/"
  },
  {
    "name": "UltimaX AI",
    "genre": "Productivity AI",
    "desc": "UltimaX Intelligence lets you explore many AI tools in one place. It offers a smooth and easy-to-use interface for quick access. Great for users who want different AI features together. Free to use with no login required.",
    "url": "https://umint-ai.hf.space/"
  },
  {
    "name": "DrafterPlus AI",
    "genre": "Image Generation AI",
    "desc": "DrafterPlus AI helps you explore various AI models online. You can try out different image generation tools easily. It’s useful for both beginners and creative users. This platform is free and works in the browser.",
    "url": "https://ai.drafterplus.nl/"
  },
  {
    "name": "DreamBig",
    "genre": "Content Creation AI",
    "desc": "DreamBig lets you create text, images, and audio using AI. It’s an all-in-one creative tool for fun and work. The site is easy to explore with no learning curve. Everything is free and ready to try instantly.",
    "url": "https://dreambiglabs.vercel.app/"
  },
  {
    "name": "WhizzyAI",
    "genre": "Writing AI",
    "desc": "WhizzyAI gives you many types of AI chats for different uses. It supports casual talk, writing help, and more. You can start chatting right away without sign-ups. All features are free to use anytime.",
    "url": "https://www.whizzyai.xyz"
  },
  {
    "name": "RizqiO Chat",
    "genre": "Image Generation AI",
    "desc": "RizqiO Chat is an AI chatbot that also makes images. You can chat or generate visuals in a simple interface. It’s great for both fun and creative tasks. The tool is free with no login needed.",
    "url": "https://chatbot.rizqioliveira.my.id/"
  },
  {
    "name": "Chat100 AI",
    "genre": "Writing AI",
    "desc": "Chat100.ai lets you use GPT-4o and Claude 3.5 for free. You can chat in real-time without creating an account. It supports multiple languages and smart replies. Simple and free for everyone to try.",
    "url": "https://chat100.ai"
  },

  {
    "name": "MealGenie",
    "genre": "Creative Ideas AI",
    "desc": "MealGenie is a free recipe generator that offers meal ideas based on your preferences. It’s perfect for anyone looking to cook healthy and tasty dishes. Quick, smart, and personalized. Easy to use and totally free.",
    "url": "https://mealgenie.ai/?ref=zairok"
  },
  {
    "name": "ObjectRemover",
    "genre": "Image Generation AI",
    "desc": "ObjectRemover is a free AI tool that removes unwanted objects from your photos. Just upload an image and erase anything in seconds. Great for clean edits and design fixes. No sign-up needed and completely free.",
    "url": "https://objectremover.com?ref=zairok"
  },
  {
    "name": "Prompter",
    "genre": "Creative Ideas AI",
    "desc": "Prompter by fofrAI is a free tool for generating AI image prompts easily. It helps artists and creators brainstorm ideas quickly. You can also collaborate or contribute prompts. Simple, helpful, and totally free to use.",
    "url": "https://prompter.fofr.ai?ref=zairok"
  },
  {
    "name": "DoodleDash",
    "genre": "Games",
    "desc": "DoodleDash is a fun, free drawing game where players sketch objects based on prompts. An AI tries to guess what you're drawing in real-time. Great for kids and creatives. Fast-paced and fully free to play.",
    "url": "https://xenova-doodle-dash.static.hf.space?ref=zairok"
  },
  {
    "name": "Postfluencer",
    "genre": "Writing AI",
    "desc": "Postfluencer is a free tool that helps you write engaging LinkedIn posts. It uses proven writing frameworks to build your personal brand. Great for professionals and creators. Easy to use and completely free.",
    "url": "https://www.postfluencer.app/?ref=zairok"
  },
  {
    "name": "HeyDoc",
    "genre": "Study AI",
    "desc": "HeyDoc is a free AI medical assistant that answers your health-related questions. It provides friendly, quick responses to help you stay informed. Great for general advice and awareness. Totally free and easy to use.",
    "url": "https://heydoc.ai/webchat?ref=zairok"
  },
  {
    "name": "Pi",
    "genre": "Miscellaneous",
    "desc": "Pi is a free personal AI that chats with you in a helpful and kind way. Ask it questions, get advice, or simply talk for support. Great for everyday help or companionship. Always ready, always free.",
    "url": "https://pi.ai/talk?ref=zairok"
  },
  {
    "name": "ColorMatch",
    "genre": "Art Style & Effects AI",
    "desc": "ColorMatch by Polarr is a free tool that transfers color styles between images. Upload a reference and apply its aesthetic to your own photos. Perfect for editors, photographers, or designers. Easy and fully free to use.",
    "url": "https://colormatch.polarr.com/?ref=zairok"
  },
  {
    "name": "Genie",
    "genre": "Video AI",
    "desc": "Genie by LumaLabs is a free AI tool for creating interactive 3D scenes. It helps bring your creative ideas to life visually. Great for prototyping or storytelling. User-friendly and completely free.",
    "url": "https://lumalabs.ai/genie?ref=zairok"
  },
  {
    "name": "DreamMachine",
    "genre": "Video AI",
    "desc": "DreamMachine by Luma is a free AI video generator that turns your ideas into visuals. Just enter a prompt and watch it create clips or images. Great for creatives and storytellers. Simple to use and totally free.",
    "url": "https://dream-machine.lumalabs.ai?ref=zairok"
  },
  {
    "name": "DeepSeek",
    "genre": "Writing AI",
    "desc": "DeepSeek is a free AI platform offering powerful models for writing and coding tasks. It’s built for developers, students, and creators needing reliable AI assistance. Fast, multilingual, and fully free.",
    "url": "https://www.deepseek.com?ref=zairok"
  },
  {
    "name": "AIWatermarkRemover",
    "genre": "Image Generation AI",
    "desc": "AIWatermarkRemover is a free tool that removes watermarks from images automatically. Just upload and clean your image with a click. Fast and ideal for editing visuals. No cost or account needed.",
    "url": "https://freeaiden.com/ai-watermark-remover/?ref=zairok"
  },
  {
    "name": "ImageToText",
    "genre": "Productivity AI",
    "desc": "ImageToText is a free tool that extracts text from any image instantly. Upload your picture and get editable text right away. Great for notes, OCR, or digitalizing content. Free, simple, and accurate.",
    "url": "https://freeaiden.com/free-image-to-text/?ref=zairok"
  },
  {
    "name": "QRCodeGen",
    "genre": "Productivity AI",
    "desc": "QRCodeGen is a free AI tool for generating QR codes with custom inputs. Enter text, URLs, or contact info and get a downloadable code. Easy for business cards, promotions, or links. Fully free and fast.",
    "url": "https://freeaiden.com/qr-code-generator/?ref=zairok"
  },
  {
    "name": "BarcodeGen",
    "genre": "Productivity AI",
    "desc": "BarcodeGen is a free tool to generate standard barcodes for products or labels. Enter your text or ID and create a barcode instantly. Simple to use for retail or logistics. No login and totally free.",
    "url": "https://freeaiden.com/barcode-generator/?ref=zairok"
  },
  {
    "name": "Humanizer",
    "genre": "Writing AI",
    "desc": "Humanizer is a free AI tool that rewrites robotic-sounding text to sound more natural. It’s great for emails, articles, and online writing. Makes AI content feel human. Just paste and go — free and fast.",
    "url": "https://freeaiden.com/humanizer/?ref=zairok"
  },
  {
    "name": "ImageToPDF",
    "genre": "Productivity AI",
    "desc": "ImageToPDF is a free converter that turns your images into a single PDF file. Just upload your pictures and download the document in seconds. Useful for reports, forms, or records. Easy and totally free.",
    "url": "https://freeaiden.com/image-to-pdf-converter/?ref=zairok"
  },
  {
    "name": "Image2SFX",
    "genre": "Audio AI",
    "desc": "Image2SFX is a free tool that turns pictures into sound effects using AI. Just upload an image and hear matching audio instantly. Perfect for creators, filmmakers, and game devs. Easy to use and totally free.",
    "url": "https://huggingface.co/spaces/fffiloni/Image2SFX-comparison?ref=zairok"
  },
  {
    "name": "OpenVoice",
    "genre": "Audio AI",
    "desc": "OpenVoice is a free AI voice cloning tool that copies voices from short samples. It gives you control over pitch, tone, and speed. Useful for creators, apps, or dubbing. Powerful and totally free to use.",
    "url": "https://huggingface.co/spaces/myshell-ai/OpenVoice?ref=zairok"
  },
  {
    "name": "ExpressionEditor",
    "genre": "Art Style & Effects AI",
    "desc": "ExpressionEditor is a free AI tool for changing facial expressions in images. Just upload a photo and tweak the emotion or look. Great for designers, content creators, or research. No cost and easy to use.",
    "url": "https://huggingface.co/spaces/fffiloni/expression-editor?ref=zairok"
  },
  {
    "name": "ToonCrafter",
    "genre": "Video AI",
    "desc": "ToonCrafter helps animators create smooth transitions between two cartoon frames. It’s a free AI tool that improves animation flow and quality. Useful for pros and beginners alike. Easy to use and totally free.",
    "url": "https://huggingface.co/spaces/Doubiiu/tooncrafter?ref=zairok"
  },
  {
    "name": "ToolBazGPT",
    "genre": "Writing AI",
    "desc": "ChatGPTAlt is a free alternative to ChatGPT for chatting and generating content. It offers helpful, AI-powered conversations for various tasks. No sign-up required and completely free to use. Ideal for quick responses or ideas.",
    "url": "https://toolbaz.com/writer/chat-gpt-alternative?ref=zairok"
  },
  {
    "name": "LinkedIn Summary",
    "genre": "Writing AI",
    "desc": "LinkedInSummary creates strong professional summaries for your profile in seconds. This free AI tool makes it easy to stand out in your career. Great for job seekers and students. No sign-up needed, fully free.",
    "url": "https://toolbaz.com/writer/linkedin-summary?ref=zairok"
  },
  {
    "name": "Speech Writer",
    "genre": "Writing AI",
    "desc": "SpeechWriter helps you write impactful speeches for any event using AI. This free tool is ideal for formal, casual, or creative speeches. Just enter your topic and get polished content. Easy and completely free to use.",
    "url": "https://toolbaz.com/writer/speech-writer?ref=zairok"
  },
  {
    "name": "Notes Generator",
    "genre": "Study AI",
    "desc": "NotesGenerator creates study notes from any text using AI in seconds. This free tool helps students save time and learn faster. Just paste content and receive clear notes. Fully free and no login required.",
    "url": "https://toolbaz.com/writer/ai-notes-generator?ref=zairok"
  },
  {
    "name": "Homework Helper",
    "genre": "Study AI",
    "desc": "HomeworkHelper solves school questions and explains answers with free AI support. It’s great for students who need quick, accurate help. Saves time and boosts understanding. No cost or sign-up needed.",
    "url": "https://toolbaz.com/writer/ai-hw-helper?ref=zairok"
  },
  {
    "name": "Recipe Generator",
    "genre": "Creative Ideas AI",
    "desc": "RecipeGenerator creates free custom recipes based on ingredients or themes. It’s fun and useful for home cooks or food lovers. Easy to use with fast results. No login required, completely free.",
    "url": "https://toolbaz.com/writer/ai-recipe-generator?ref=zairok"
  },
  {
    "name": "Email Writer",
    "genre": "Productivity AI",
    "desc": "EmailWriter helps you draft professional and personal emails with AI support. This free tool saves time and improves clarity. Just input the topic and tone. No sign-up needed and totally free.",
    "url": "https://toolbaz.com/writer/email-writer?ref=zairok"
  },
  {
    "name": "Poem Generator",
    "genre": "Writing AI",
    "desc": "PoemGenerator writes beautiful poems using free AI based on your ideas or prompts. Great for fun, gifts, or writing inspiration. Fast, creative, and no login required. 100% free to use anytime.",
    "url": "https://toolbaz.com/writer/poem-generator?ref=zairok"
  },
  {
    "name": "Plot Generator",
    "genre": "Creative Ideas AI",
    "desc": "PlotGenerator creates original story plots in seconds using AI. It’s free and perfect for writers, students, and content creators. Get instant plot ideas with no account needed. Simple and completely free.",
    "url": "https://toolbaz.com/writer/plot-generator?ref=zairok"
  },

  {
    "name": "radio.garden",
    "genre": "Audio AI",
    "desc": "radio.garden offers a globe-based interface to tune into live radio from thousands of cities. A unique, free experience to discover music and culture across the world.",
    "url": "https://radio.garden?ref=zairok"
  },
  {
    "name": "openlibrary.org",
    "genre": "Study AI",
    "desc": "openlibrary.org is a free online library with millions of books. Users can borrow digital copies, browse academic resources, and explore rare texts from anywhere.",
    "url": "https://openlibrary.org?ref=zairok"
  },
  {
    "name": "litsolutions.org",
    "genre": "Study AI",
    "desc": "litsolutions.org provides textbook solutions to academic problems. It’s a free study helper where users can search books and get detailed explanations.",
    "url": "https://litsolutions.org?ref=zairok"
  },
  {
    "name": "edx.org",
    "genre": "Study AI",
    "desc": "edx.org is a world-class platform offering free university-level courses from MIT, Harvard, and more. Learn tech, business, and science online at no cost.",
    "url": "https://edx.org?ref=zairok"
  },
  {
    "name": "roadmap.sh",
    "genre": "Study AI",
    "desc": "roadmap.sh offers visual guides and structured paths for developers and professionals. It’s a free resource to explore career journeys step-by-step.",
    "url": "https://roadmap.sh?ref=zairok"
  },
  {
    "name": "spoken.io",
    "genre": "Miscellaneous",
    "desc": "spoken.io helps shoppers find the best prices, reviews, and product alternatives in one place. This free platform streamlines decision-making and reduces buyer regret.",
    "url": "https://spoken.io?ref=zairok"
  },
  {
    "name": "reviewmeta.com",
    "genre": "Miscellaneous",
    "desc": "reviewmeta.com is a free analyzer that checks for fake product reviews. Just paste an Amazon link to see adjusted ratings and review authenticity.",
    "url": "https://reviewmeta.com?ref=zairok"
  },
  {
    "name": "sidehustlestack.co",
    "genre": "Miscellaneous",
    "desc": "sidehustlestack.co is a free guide to earning income online. It lists tools, platforms, and tutorials for launching freelancing, e-commerce, and creator careers.",
    "url": "https://sidehustlestack.co?ref=zairok"
  },
  {
    "name": "tinywow.com",
    "genre": "Productivity AI",
    "desc": "tinywow.com offers over 200 free tools for files, documents, images, and PDFs. No login needed—just click, upload, and use instantly.",
    "url": "https://tinywow.com?ref=zairok"
  },
  {
    "name": "wetransfer.com",
    "genre": "Productivity AI",
    "desc": "wetransfer.com lets users send large files (up to 2GB) for free without registration. It’s a simple and reliable way to transfer files globally.",
    "url": "https://wetransfer.com?ref=zairok"
  },
 
  {
    "name": "repairclinic.com",
    "genre": "Miscellaneous",
    "desc": "repairclinic.com helps users identify problems and order parts for home appliances. It offers free troubleshooting and how-to repair videos.",
    "url": "https://repairclinic.com?ref=zairok"
  },
  {
    "name": "deskspace",
    "genre": "Productivity AI",
    "desc": "deskspacing.com helps you visualize and customize your desk setup with templates and accessories. This free tool is great for workspace inspiration.",
    "url": "https://deskspacing.com?ref=zairok"
  },
  {
    "name": "atlasobscura.com",
    "genre": "Search & Discovery AI",
    "desc": "atlasobscura.com helps you discover hidden travel destinations and weird, wonderful places. The site is free to explore and full of local gems.",
    "url": "https://atlasobscura.com?ref=zairok"
  },

  {
    "name": "citywalki.com",
    "genre": "Search & Discovery AI",
    "desc": "citywalki.com lets you explore cities in 3D through interactive, free simulations. Great for virtual tourism, research, or curiosity.",
    "url": "https://citywalki.com?ref=zairok"
  },
  {
    "name": "zoo.dev",
    "genre": "Productivity AI",
    "desc": "zoo.dev/text-to-cad offers a free AI tool to generate CAD-ready 3D models from natural language. It simplifies industrial design and creativity.",
    "url": "https://zoo.dev/text-to-cad?ref=zairok"
  },
  {
    "name": "backflip.ai",
    "genre": "Productivity AI",
    "desc": "backflip.ai allows you to generate game-ready 3D models from descriptions or sketches. The platform is free, ideal for indie developers and prototypers.",
    "url": "https://backflip.ai?ref=zairok"
  },
  {
    "name": "sketch2app.io",
    "genre": "Productivity AI",
    "desc": "sketch2app.io turns hand-drawn sketches into working apps or websites. This free AI tool is designed for rapid prototyping and creativity.",
    "url": "https://sketch2app.io?ref=zairok"
  }
];




const List<String> genres = [
  'Writing AI',
  'Coding AI',
  'Image Generation AI',
  'Video AI',
  'Audio AI',
  'Study AI',
  'Search & Discovery AI',
  'Content Creation AI',
  'Art Style & Effects AI',
  'Creative Ideas AI',
  'Productivity AI',
   'Games',
  'Miscellaneous',
];class ToolCardShimmer extends StatelessWidget {
  final bool isDark;
  const ToolCardShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Color outerColor = isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF0F0F0);
    final Color innerColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: outerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Circular icon shimmer
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerColor,
            ),
          ),
          const SizedBox(width: 16),

          // Text shimmer blocks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: innerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: innerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Heart shimmer
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerColor,
            ),
          ),
        ],
      ),
    );
  }
}
List<Map<String, dynamic>> remoteTools = [];
Timer? _remoteFetchTimer;
Future<void> fetchRemoteTools() async {
  final prefs = await SharedPreferences.getInstance();
  final url = Uri.parse("https://zairok.web.app/t.json");

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      await prefs.setString("cached_tools", response.body);

      remoteTools = decoded.map<Map<String, dynamic>>((tool) => {
        'name': tool['name'] ?? 'Unknown',
        'desc': tool['desc'] ?? 'No description available',
        'url': tool['url'] ?? '',
        'genre': tool['genre'] ?? 'Unknown',
      }).toList();

    } else {
    }
  } catch (e) {
  }
}
Future<void> loadCachedTools() async {
  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getString("cached_tools");

  if (cached != null) {
    final List decoded = json.decode(cached);
    remoteTools = decoded.map<Map<String, dynamic>>((tool) => {
      'name': tool['name'] ?? 'Unknown',
      'desc': tool['desc'] ?? 'No description available',
      'url': tool['url'] ?? '',
      'genre': tool['genre'] ?? 'Unknown',
    }).toList();

  } else {
  }
}
// ---------------- MainUIScreen ----------------
int _currentCarouselIndex = 0;
class MainUIScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkModeNotifier;
  final String userName;
  final String avatarPath;
  final VoidCallback onToggleTheme;

  const MainUIScreen({
    super.key,
    required this.avatarPath,
    required this.isDarkModeNotifier,
    required this.userName,
    required this.onToggleTheme,
  });

  @override
  State<MainUIScreen> createState() => _MainUIScreenState();
}

class _MainUIScreenState extends State<MainUIScreen> with WidgetsBindingObserver {
  String selectedGenre = 'Writing AI';
  bool hasNotificationDot = true;
  int selectedIndex = 0;
  late String userName;
  ValueNotifier<String> userNameNotifier = ValueNotifier<String>(''); // reactive value
  bool isLoading = false;
  final CarouselSliderController _carouselController = CarouselSliderController();
  bool _hasAutoPlayed = false;
  int _currentCarouselIndex = 0;
  bool hasCompletedOnboarding = false;
  late String greetingMessage;
  int zairokTapCount = 0;
  List<Map<String, dynamic>> remoteTools = [];
Timer? _remoteFetchTimer;
  final ScrollController _scrollController = ScrollController();
  void _onSetName(String newName) {
  setState(() {
    userName = newName;
    greetingMessage = getGreeting(newName); // Update greeting live
  });
}
bool showScrollToTop = false;
  final List<String> genres = [
    'All',
    'Writing AI',
    'Coding AI',
    'Audio AI',
    'Study AI',
    'Video AI',
    'Content Creation AI',
    'Art Style & Effects AI',
    'Creative Ideas AI',
    'Image Generation AI',
    'Search & Discovery AI',
    'Productivity AI',
    'Games',
    'Miscellaneous',
  ];

void initToolLoading() async {
  await loadCachedTools();
  setState(() {}); // display from cache immediately

  await fetchRemoteTools();
  setState(() {}); // update UI with fresh

  _remoteFetchTimer = Timer.periodic(Duration(minutes: 2), (_) async {
    await fetchRemoteTools();
    setState(() {});
  });
}
@override
void initState() {
  super.initState();
  initToolLoading();
  maybeAddFakeNotification(); 
   setState(()=> hasNotificationDot=true); // ✅ Initialize notification dot state,

  userName = widget.userName;
  greetingMessage = getGreeting(userName); // ✅ Cache greeting once
  

  WidgetsBinding.instance.addObserver(this); // ✅ To detect resume
  _checkOnboardingStatus();
 
  _scrollController.addListener(() {
    if (_scrollController.offset > 600 && !showScrollToTop) {
      setState(() => showScrollToTop = true);
    } else if (_scrollController.offset <= 600 && showScrollToTop) {
      setState(() => showScrollToTop = false);
    }
  });
  // ✅ Load cached blacklist instantly
  loadCachedBlacklist();

  // ✅ Then fetch latest blacklist from remote
  fetchAndApplyBlacklist();
  // ✅ Start skeletonizer shimmer for 10 seconds
isLoading = true;
Future.delayed(const Duration(milliseconds: 1000), () {
  if (mounted) setState(() => isLoading = false);
});

  // ✅ Auto-refresh blacklist every 2 minutes
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (!mounted) return;

    try {
      final updated = await fetchBlacklist();
      final cleaned = updated.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (!_areListsEqualIgnoreCase(blacklistedNamesNotifier.value, cleaned)) {
        blacklistedNamesNotifier.value = List.from(cleaned);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('cachedBlacklist', cleaned);
      } else {
      }
    } catch (e) {
    }
  });

  // ✅ Load rewarded interstitial ad
  loadRewardedInterstitialAd();

  // ✅ Carousel autoplay once after 10 seconds
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasAutoPlayed) {
        _carouselController.animateToPage(
          1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() {
          _hasAutoPlayed = true;
          _currentCarouselIndex = 1;
        });
      }
    });
  });

  // ✅ Carousel loop logic every 1 min
  Timer.periodic(const Duration(minutes: 1), (timer) {
    if (!mounted) return;

    final loopTargets = [1, 2, 4];
    final nextIndex = loopTargets[DateTime.now().second % loopTargets.length];

    _carouselController.animateToPage(0);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _carouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() => _currentCarouselIndex = nextIndex);
      }
    });
  });
}
@override
void dispose() {
  _remoteFetchTimer?.cancel();
  super.dispose();
}
Future<void> _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    hasCompletedOnboarding = prefs.getBool('hasLaunched') ?? false;
  });
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    fetchAndApplyBlacklist(); // ✅ Re-check blacklist on resume
  }
}
Future<void> _onRefresh() async {
  if (!mounted) return;

  setState(() => isLoading = true);

  try {
    final updatedBlacklist = await fetchBlacklist();
    final cleaned = updatedBlacklist.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    blacklistedNamesNotifier.value = List.from(cleaned); // ✅ Force rebuild

  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}
Widget bannerContainer({required Widget child, required bool isDark}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? Colors.grey.shade700 : const Color.fromARGB(255, 226, 175, 175),
        width: 1.2,
      ),
    ),
    child: Center(child: child),
  );
}
List<Widget> getCarouselItems(bool isDark) {
  // ✅ Prevent rendering anything until skeletonizer finishes
  if (isLoading) return [];

  return [
    // ✅ Top Ad Banner
    bannerContainer(
      child: AdBannerWidget(adUnitId: 'ca-app-pub-1372661529203718/5037632231'),
      isDark: isDark,
    ),

    // ✅ Promo Banners
    promoBanner(
      text: 'We are the 1st \n  Free AI Tools Discovery App',
      assetPath: 'assets/1st.svg',
      isDark: isDark,
      bgColor: const Color(0xFFFFF4E5),
      borderColor: Colors.deepOrange,
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
    promoBanner(
      text: '250+ Free Tools Only On Zairok.',
      assetPath: 'assets/rocket.svg',
      isDark: isDark,
      bgColor: const Color(0xFFEFF7FF),
      borderColor: Colors.blueAccent,
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    promoBanner(
      text: 'Zairok. – Discover AI Like Never Befor!',
      assetPath: 'assets/superhero.svg',
      isDark: isDark,
      bgColor: const Color(0xFFFFEBF0),
      borderColor: Colors.pinkAccent,
      textStyle: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
     bannerContainer(
      child: AdBannerWidget(adUnitId: 'ca-app-pub-1372661529203718/5037632231'),
      isDark: isDark,
    ),
    promoBanner(
      text: 'Exploring – Artificial Intelligence Made Easy',
      assetPath: 'assets/bannerbot.svg',
      isDark: isDark,
      bgColor: const Color(0xFFF1FFF2),
      borderColor: Colors.greenAccent,
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    bannerContainer(
      child: AdBannerWidget(adUnitId: 'ca-app-pub-1372661529203718/5037632231'),
      isDark: isDark,
    ),
    // ✅ Bottom Ad Banner
   
  ];
}
Widget navIcon(IconData icon, String label, int index, bool isDark) {
  final isSelected = selectedIndex == index;

  return GestureDetector(
    onTap: () async {
      setState(() => selectedIndex = index);
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      switch (index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(isDarkMode: isDark),
            ),
          );
          break;

        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoritesScreen(isDarkMode: isDark),
            ),
          );
          break;

       
 case 3:
  zairokTapCount++; // Increment counter on every tap

  if (zairokTapCount % 2 == 0 && _rewardedInterstitialAd != null) {
    // Even number: Show ad
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        zairokTapCount = 0; // Reset counter after ad shown

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZairokTextScreen(
              isDark: isDark,
              userName: userName,
              avatarPath: widget.avatarPath,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      },
    );

    _rewardedInterstitialAd = null;
      loadRewardedInterstitialAd();

  } else {
    // Odd number: Just navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZairokTextScreen(
          isDark: isDark,
          userName: userName,
          avatarPath: widget.avatarPath,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }
  break;

  case 4:
    final updatedName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode: isDark,
          userName: userName,
          onToggleTheme: widget.onToggleTheme,
          onSetName: (newName) => Navigator.pop(context, newName),
        ),
      ),
    );

    if (updatedName != null && updatedName.trim().isNotEmpty) {
      if (!mounted) return;
      setState(() {
        userName = updatedName;
        greetingMessage = getGreeting(updatedName);
      });
    }
    break;
}
    }
    ,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.deepOrange : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.deepOrange : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
@override
Widget build(BuildContext context) {
  return ValueListenableBuilder<bool>(
    valueListenable: widget.isDarkModeNotifier,
    builder: (context, isDark, _) {
      final bg = isDark ? Colors.black : Colors.white;
      final textC = isDark ? Colors.white : Colors.black;

      return ValueListenableBuilder<List<String>>(
        valueListenable: blacklistedNamesNotifier,
        builder: (context, blacklist, _) {
          final filteredTools = selectedGenre == 'All'
              ? tools.where((t) => !blacklist.contains(t['name'])).toList()
              : tools
                  .where((t) =>
                      t['genre'] == selectedGenre &&
                      !blacklist.contains(t['name']))
                  .toList();

          return Scaffold(
            extendBody: true,
            backgroundColor: bg,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Skeletonizer(
                  enabled: isLoading,
                  child: CustomScrollView(
                    controller:_scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                   slivers: [
  buildSliverAppBar(context, textC, isDark),
  buildGreeting(textC, isDark),
  buildSearchBar(textC, isDark),
  buildCarouselSlider(isDark),
  buildFeaturedGenres(textC, isDark),

  // ✅ Combine tools before sending
  buildSpecialForYou(
    selectedGenre == 'All'
        ? [...tools, ...remoteTools]
        : [...tools, ...remoteTools]
            .where((t) => t['genre'] == selectedGenre)
            .toList(),
    textC,
    isLoading,
    isDark,
  ),

  buildSliverFooter(textC, isDark),

  const SliverToBoxAdapter(child: SizedBox(height: 20)),
],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: buildBottomNavBar(isDark),
            floatingActionButton: showScrollToTop
    ? FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          
          );
        },
        child: const Icon(Icons.arrow_upward),
      )
    : null,
          );
        },
      );
    },
  );
}
SliverToBoxAdapter buildSliverFooter(Color textC, bool isDark) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        kBottomNavigationBarHeight + 16,
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),

          Divider(
            color: isDark ? Colors.white12 : Colors.black12,
            thickness: 0.6,
          ),

          Text(
            'Crafted with ❤️ by Zairok Team',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: textC.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            '© ${DateTime.now().year} Zairok. All rights reserved.',
            style: GoogleFonts.poppins(
              fontSize: 11.8,
              color: textC.withOpacity(0.55),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              final uri = Uri.parse('mailto:zairokcare@gmail.com');
              launchUrl(uri);
            },
            child: Text(
              'Contact Us',
              style: GoogleFonts.poppins(
                fontSize: 13.2,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  // ✂️ Split methods for Slivers and BottomNav
int _tapCount = 0;
bool _showEasterEgg = false;

SliverAppBar buildSliverAppBar(BuildContext context, Color textC, bool isDark) {
  return SliverAppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    pinned: false,
    floating: false,
    snap: false,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            _tapCount++;
            if (_tapCount >= 10 && !_showEasterEgg) {
              _showEasterEgg = true;

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "🕰️ Time Capsule Note",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "To the future: This was built by a 17-year-old dreamer named Lohit, "
                          "your Great-great-great-great-great-great-great-grandparent in 2025.\n\n"
                          "👶👵 Hope you're still dreaming too.\n– Zairok Team ✨",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _tapCount = 0;
                            _showEasterEgg = false;
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.orange.shade300 : Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
          child: Text(
            'Zairok.',
            style: GoogleFonts.poppins(
              color: textC,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
  );
}
SliverToBoxAdapter buildGreeting(Color textC, bool isDark) {
  final shimmerColor = isDark ? Colors.grey[800]! : const Color(0xFFE6E6E6);

  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ValueListenableBuilder<String>(
        valueListenable: avatarNotifier,
        builder: (context, avatarPath, _) {
          return Row(
            children: [
              // Avatar or shimmer
              isLoading
                  ? CircleAvatar(
                      radius: 24,
                      backgroundColor: shimmerColor,
                    )
                  : Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: avatarPath.startsWith('assets/')
                            ? AssetImage(avatarPath)
                            : FileImage(File(avatarPath)) as ImageProvider,
                      ),
                    ),

              const SizedBox(width: 12),

              // Greeting text or shimmer
              Expanded(
                child: isLoading
                    ? Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                    : Text(
                        greetingMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textC,
                        ),
                      ),
              ),

              // Notification icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    hasNotificationDot = false;
                    showNotificationPopup(context);
                  });
                },
                child: Stack(
                  children: [
                    Icon(Icons.notifications_none, size: 30, color: textC),
                    if (hasNotificationDot && !isLoading)
                      Positioned(
                        right: 0,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
SliverToBoxAdapter buildSearchBar(Color textC, bool isDark) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tools...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
SliverToBoxAdapter buildCarouselSlider(bool isDark) {
  if (isLoading) {
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey.shade300;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  final carouselItems = getCarouselItems(isDark);

  return SliverToBoxAdapter(
    child: Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items: carouselItems,
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            viewportFraction: 1,
            enlargeCenterPage: true,
            initialPage: 0,
            autoPlayAnimationDuration: const Duration(milliseconds: 250),
            enableInfiniteScroll: false,
            onPageChanged: (index, _) {
              setState(() => _currentCarouselIndex = index);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselItems.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == index
                    ? Colors.deepOrange
                    : isDark
                        ? Colors.white30
                        : Colors.grey.shade400,
              ),
            );
          }),
        ),
      ],
    ),
  );
}
SliverToBoxAdapter buildFeaturedGenres(Color textC, bool isDark) {
  final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Text(
                  'Featured Genres',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textC,
                  ),
                ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: isLoading
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) => Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: genres.skip(1).map((g) {
                      final isSelected = selectedGenre == g;
                      final showOrange = isSelected;

                      return GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            setState(() => selectedGenre = g);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: showOrange
                                ? Colors.deepOrange
                                : isDark
                                    ? Colors.grey[700]
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            g,
                            style: GoogleFonts.poppins(
                              color: showOrange
                                  ? Colors.white
                                  : textC.withOpacity(isLoading ? 0.5 : 1),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    ),
  );
}
Widget buildSpecialForYou(List<Map<String, dynamic>> tools, Color textC, bool isLoading, bool isDark) {
  return ValueListenableBuilder<List<String>>(
    valueListenable: blacklistedNamesNotifier,
    builder: (context, blacklist, _) {
      final blacklistSet = blacklist.map((e) => e.trim().toLowerCase()).toSet();

      final cleanTools = tools.where((tool) {
        final name = (tool['name'] ?? '').toString().trim().toLowerCase();
        final desc = (tool['desc'] ?? '').toString().trim();
        return name.isNotEmpty && desc.isNotEmpty && !blacklistSet.contains(name);
      }).map<Map<String, String>>((tool) {
        return tool.map((key, value) => MapEntry(
          key.toString().trim(),
          value.toString().trim(),
        ));
      }).toList();

      final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

      return SliverToBoxAdapter(
        key: ValueKey(cleanTools.length),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Container(
                      height: 20,
                      width: 140,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    )
                  : Text(
                      'Special for You',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textC,
                      ),
                    ),
              const SizedBox(height: 12),

              Column(
                children: isLoading
                    ? List.generate(4, (_) => ToolCardShimmer(isDark: isDark))
                    : cleanTools.map((tool) {
                        final toolName = tool['name'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FinalLandingPage(tool: tool),
                              ),
                            );
                          },
                          child: ToolCard(
                            tool: tool,
                            isFavorite: favoriteNames.contains(toolName),
                            onFavoriteToggle: (name) {
                              if (favoriteNames.contains(name)) {
                                favoriteNames.remove(name);
                              } else {
                                favoriteNames.add(name);
                              }
                              blacklistedNamesNotifier.notifyListeners();
                            },
                          ),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
Widget buildBottomNavBar(bool isDark) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                navIcon(Icons.home, "Home", 0, isDark),
                navIcon(Icons.search, "Search", 1, isDark),
                navIcon(Icons.favorite, "Favorites", 2, isDark),
                navIcon(Icons.chat_bubble_outline, "Zairok AI", 3, isDark),
                navIcon(Icons.settings, "Settings", 4, isDark),
                
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}


 
// ---------------- SearchScreen ----------------
class SearchScreen extends StatefulWidget {
  final bool isDarkMode;
  const SearchScreen({super.key, required this.isDarkMode});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<String> history = [];
  List<String> selectedGenres = [];
  bool showGenrePopup = false;
  bool isSearchFocused = false;
  bool isLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isSearchFocused = _focusNode.hasFocus;
        if (!isSearchFocused && showGenrePopup) {
          showGenrePopup = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

Future<void> _onRefresh() async {
  try {
    setState(() {
      isLoading = true;
      showGenrePopup = false; // Close filter popup during refresh
    });

    await fetchAndApplyBlacklist();

    // Optional: mimic network delay for shimmer effect
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final textC = isDark ? Colors.white : Colors.black;
    final subC = isDark ? Colors.white70 : Colors.black54;
    final searchBarColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
    final filterIconBg = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    final hintTextColor = isDark ? Colors.white54 : Colors.black54;

    return ValueListenableBuilder<List<String>>(
      valueListenable: blacklistedNamesNotifier,
      builder: (context, blacklist, _) {
        final blacklistSet = blacklist.map((e) => e.trim().toLowerCase()).toSet();
             final allTools = [...tools, ...remoteTools];
final results = allTools.where((t) {
  // Normalize tool data
  final toolName = t['name']?.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
  final toolDesc = t['desc']?.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
  final toolGenre = t['genre']?.toString().toLowerCase().trim() ?? '';

  // Normalize search query
  final normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  // Blacklist filter
  final matchesBlacklist = !blacklistSet.contains(toolName);

  // Search filter
  final matchesQuery = normalizedQuery.isEmpty ||
      toolName.contains(normalizedQuery) ||
      toolDesc.contains(normalizedQuery);

  // Genre filter
  final selectedGenresLower = selectedGenres.map((g) => g.toLowerCase().trim()).toList();
  final matchesGenre = selectedGenres.isEmpty || selectedGenresLower.contains(toolGenre);

  return matchesBlacklist && matchesQuery && matchesGenre;
}).toList();
        return Scaffold(
          backgroundColor: bg,
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0, // ⛔️ Prevent elevation on scroll
  surfaceTintColor: Colors.transparent, // ✅ Disable Android's scroll tint
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    color: textC,
    onPressed: () => Navigator.pop(context),
  ),
  title: Text(
    'Search',
    style: GoogleFonts.poppins(color: textC),
  ),
  actions: [
    GestureDetector(
      onTap: () => _showRandomTool(context), // make sure context is passed
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: const [
            Icon(Icons.casino_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'Surprise Me',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
  ],
),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 Search Bar + Filter
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: searchBarColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  focusNode: _focusNode,
                                  style: TextStyle(color: textC),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search tools...',
                                    hintStyle: TextStyle(color: hintTextColor),
                                  ),
                                  onChanged: (v) => setState(() => query = v.trim()),
                                  onSubmitted: (v) {
                                    final trimmed = v.trim();
                                    if (trimmed.isNotEmpty) {
                                      setState(() {
                                        history.remove(trimmed);
                                        history.insert(0, trimmed);
                                        if (history.length > 15) history.removeLast();
                                        showGenrePopup = false;
                                      });
                                    }
                                    _focusNode.unfocus();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSearchFocused || showGenrePopup)
                              GestureDetector(
                                onTap: () => setState(() => showGenrePopup = !showGenrePopup),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: filterIconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.tune, color: textC),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 🕘 Recent Searches
                        if (history.isNotEmpty) ...[
                          Text('Recent Searches', style: GoogleFonts.poppins(color: subC)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: history
                                .map((h) => Chip(
                                      label: Text(h),
                                      onDeleted: () => setState(() => history.remove(h)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 🔎 Results
                       Expanded(
  child: isLoading
      ? ListView.builder(
          itemCount: 6, // Number of shimmer cards
          itemBuilder: (context, index) => ToolCard.fake(isDarkOverride:isDark),
        )
      : results.isEmpty
          ? Center(
              child: Text(
                'No matches found',
                style: GoogleFonts.poppins(color: subC),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final t = results[index];
               return GestureDetector(
  onTap: () async {
    FocusScope.of(context).unfocus();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Slide from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

         return SlideTransition(
  position: slideAnimation,
  child: FinalLandingPage(
    tool: Map<String, String>.from(
      t.map((key, value) => MapEntry(key.toString(), value.toString())),
    ),
  ),
);
        },
      ),
    );
  },
                 child: ToolCard(
  tool: Map<String, String>.from(
    t.map((key, value) => MapEntry(key.toString(), value.toString())),
  ),
  isFavorite: favoriteNames.contains(t['name']),
  onFavoriteToggle: (name) {
    setState(() {
      if (favoriteNames.contains(name)) {
        favoriteNames.remove(name);
      } else {
        favoriteNames.add(name);
      }
    });
  },
),
                );
              },
            ),
)
                      ],
                    ),
                  ),
                ),
                // 🎯 Genre Filter Popup
                if (showGenrePopup)
                  Positioned(
                    top: 75,
                    right: 16,
                    child: Material(
                      elevation: 12,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 350,
                        height: 370,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.1 * 255).toInt()),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 8,
                            children: genres.skip(1).map((g) {
                              final selected = selectedGenres.contains(g);
                              return FilterChip(
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                label: Text(
                                  g,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.8,
                                    color: selected ? Colors.white : textC,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: Colors.deepOrange,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                onSelected: (_) {
                                  setState(() {
                                    if (selected) {
                                      selectedGenres.remove(g);
                                    } else {
                                      selectedGenres.add(g);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
//toolcard
class ToolCard extends StatelessWidget {
  final Map<String, String> tool;
  final bool isFavorite;
  final void Function(String)? onFavoriteToggle;
  final bool? isDarkOverride; // 🆕 Only used for .fake()

  const ToolCard({
    super.key,
    required this.tool,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : isDarkOverride = null;

  // 🔸 Fake constructor for shimmer placeholders
  const ToolCard.fake({super.key, required this.isDarkOverride})
      : tool = const {},
        isFavorite = false,
        onFavoriteToggle = null;

  @override
  Widget build(BuildContext context) {
    final isSkeleton = tool.isEmpty;

    // 🧠 Use override if given (for shimmer), else fallback to theme
    final isDark = isDarkOverride ?? Theme.of(context).brightness == Brightness.dark;

    final textC = isDark ? Colors.white : Colors.black;
    final subC = isDark ? Colors.white70 : Colors.black54;
    final skeletonColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final outerSkeletonColor = isDark ? Colors.grey[900]! : const Color(0xFFF0F0F0);
    final name = tool['name'] ?? 'Unknown';
    final desc = tool['desc'] ?? '';
    final genreKey = tool['genre']?.toLowerCase().replaceAll(' ', '') ?? 'misc';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isSkeleton ? 0 : 2,
      color: isSkeleton ? outerSkeletonColor : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 135),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Icon or shimmer
              isSkeleton
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        'assets/genre_$genreKey.svg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
              const SizedBox(width: 12),

              // 🔹 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isSkeleton
                        ? Container(
                            height: 16,
                            width: 120,
                            decoration: BoxDecoration(
                              color: skeletonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                        : Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: textC,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                    const SizedBox(height: 8),
                    isSkeleton
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: skeletonColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 14,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: skeletonColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: subC,
                              height: 1.4,
                            ),
                          ),
                  ],
                ),
              ),

              // 🔹 Favorite button
              if (!isSkeleton)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : subC,
                  ),
                  onPressed: () => onFavoriteToggle?.call(name),
                )
            ],
          ),
        ),
      ),
    );
  }
}
// ---------------- FinalLandingPage ----------------

class FinalLandingPage extends StatefulWidget {
  final Map<String, String> tool;
  const FinalLandingPage({super.key, required this.tool});

  @override
  State<FinalLandingPage> createState() => _FinalLandingPageState();
}

class _FinalLandingPageState extends State<FinalLandingPage> {
  static int _browseTapCount = 0;
  static InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => FocusManager.instance.primaryFocus?.unfocus());
    _loadInterstitialAd();
    loadRewardedInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (_interstitialAd == null) {
      InterstitialAd.load(
        adUnitId: 'ca-app-pub-1372661529203718/4128392167', // ✅ Test ID
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (error) => _interstitialAd = null,
        ),
      );
    }
  }

 Future<void> _handleBrowseTap() async {
  _browseTapCount++;
  final uri = Uri.parse(widget.tool['url']!);

  // Show ad every 3 taps
  if (_browseTapCount % 3 == 0) {
    // Try showing rewarded interstitial first
    if (_rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadRewardedInterstitialAd(); // reload for next time
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadRewardedInterstitialAd(); // try reload
          
          // Fallback to interstitial if available
          if (_interstitialAd != null) {
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) async {
                ad.dispose();
                _interstitialAd = null;
                _loadInterstitialAd();
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              onAdFailedToShowFullScreenContent: (ad, error) async {
                ad.dispose();
                _interstitialAd = null;
                _loadInterstitialAd();
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            );
            _interstitialAd!.show();
          } else {
            _loadInterstitialAd(); // preload for future
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          }
        },
      );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          // No reward logic needed
        },
      );
    }

    // Fallback: only interstitial is available
    else if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      );

      _interstitialAd!.show();
    }

    // Nothing is available — proceed anyway
    else {
      _loadInterstitialAd();
      loadRewardedInterstitialAd();
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  } else {
    // Not a multiple of 3 — no ad, just open link
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textC = isDark ? Colors.white : Colors.black;
    final subC = textC.withAlpha((0.7 * 255).toInt());
    final genreKey = widget.tool['genre']!.toLowerCase().replaceAll(' ', '');

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: textC,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/landing_$genreKey.svg', height: 200),
                      const SizedBox(height: 20),
                      SvgPicture.asset('assets/genre_$genreKey.svg', height: 50),
                      const SizedBox(height: 20),
                      Text(
                        widget.tool['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textC,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        widget.tool['desc']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 16, color: subC),
                      ),
                      const SizedBox(height:60),
                     
                      SizedBox(
                        width: double.infinity,
                    
                        child: ElevatedButton(
                          onPressed: _handleBrowseTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Browse for Me',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final bool isFirstLaunch;
  final String savedUserName;
  final ValueNotifier<bool> isDarkModeNotifier;
  final VoidCallback onToggleTheme;

  const LoadingScreen({
    super.key,
    required this.isFirstLaunch,
    required this.savedUserName,
    required this.isDarkModeNotifier,
    required this.onToggleTheme,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  AppOpenAd? _appOpenAd;
  bool _isAdShown = false;
  double _progress = 0.0;
  late Timer _progressTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    _startProgressBar();
    _prepareNext();
  }

  void _startProgressBar() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _progressTimer.cancel();
        }
      });
    });
  }

  Future<void> _prepareNext() async {
    if (!widget.isFirstLaunch) {
      _loadAppOpenAd();
    }

    // Slightly extended delay to finish animation & progress
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateNext();
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/9257395921', // ✅ Test ID
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
        },
      ),
    );
  }

  void _navigateNext() {
    if (widget.isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GetStartedScreen(
            isDarkModeNotifier: widget.isDarkModeNotifier,
            onSetName: (name) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasLaunched', true);
              await prefs.setString('userName', name);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MainUIScreen(
                    avatarPath: 'assets/profile1.jpg',
                    userName: name,
                    isDarkModeNotifier: widget.isDarkModeNotifier,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Show ad if ready and not yet shown
      if (_appOpenAd != null && !_isAdShown) {
        _isAdShown = true;
        _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (_) => _goToMain(),
          onAdFailedToShowFullScreenContent: (_, __) => _goToMain(),
        );
        _appOpenAd!.show();
      } else {
        _goToMain();
      }
    }
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainUIScreen(
          userName: widget.savedUserName,
          avatarPath: 'assets/profile1.jpg',
          isDarkModeNotifier: widget.isDarkModeNotifier,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zairok Logo Text Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  "Zairok.",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.deepOrange.withAlpha((0.3 * 255).toInt()),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32), // Space between logo and bar

            // Cute Rectangular Progress Bar
            Container(
              width: 220,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 220 * _progress,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "${(_progress * 100).toInt()}%",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
