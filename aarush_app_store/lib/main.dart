import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const AarushAppStore());
}

class AarushAppStore extends StatelessWidget {
  const AarushAppStore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarush App Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B5CFF)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6FF),
      ),
      home: const BootstrapScreen(),
    );
  }
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  late Future<String?> _nameFuture;

  @override
  void initState() {
    super.initState();
    _nameFuture = _loadName();
  }

  Future<String?> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _nameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final savedName = snapshot.data;
        if (savedName == null || savedName.isEmpty) {
          return const WelcomeScreen();
        }

        return HomeScreen(userName: savedName);
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Welcome to Aarush App Store',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'No login required. Tell us your name and we will set up your Zairok download hub.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Your name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required this.userName});

  final String userName;
  final Uri aarushInstallerUri = Uri.parse('https://example.com/aarush-app-store.apk');
  final Uri directApkUri = Uri.parse('https://example.com/zairok.apk');
  final Uri webDownloadUri = Uri.parse('https://zairok.app/download');

  Future<void> _launchUrl(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the download link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarush App Store'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $userName 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Zairok is ready. Choose how you want to install or open it today.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DownloadCard(
              title: 'Download Zairok with Aarush App Store',
              subtitle: 'Recommended for automatic updates and faster installs.',
              buttonText: 'Download Installer',
              onTap: () => _launchUrl(context, aarushInstallerUri),
            ),
            const SizedBox(height: 16),
            _DownloadCard(
              title: 'Direct Zairok APK',
              subtitle: 'Manual installation with a single APK file.',
              buttonText: 'Download APK',
              onTap: () => _launchUrl(context, directApkUri),
            ),
            const SizedBox(height: 16),
            _DownloadCard(
              title: 'Open the download website',
              subtitle: 'Use the web portal if you prefer downloading on desktop.',
              buttonText: 'Open Website',
              onTap: () => _launchUrl(context, webDownloadUri),
              isOutline: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
    this.isOutline = false,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;
  final bool isOutline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isOutline ? Border.all(color: Colors.black12) : null,
        boxShadow: isOutline
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutline ? Colors.white : null,
                foregroundColor: isOutline ? Colors.black87 : null,
                side: isOutline ? const BorderSide(color: Colors.black12) : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
