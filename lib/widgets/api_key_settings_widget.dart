// ============================================================================
// API Key Settings Widget for Zairok
// ============================================================================
// This widget provides a UI for users to configure their Pollinations API key.
// It can be integrated into the app's settings screen.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:zairok/services/pollinations_api_service.dart';

/// A widget that allows users to configure their Pollinations API key
class ApiKeySettingsWidget extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onKeyUpdated;

  const ApiKeySettingsWidget({
    super.key,
    this.isDark = false,
    this.onKeyUpdated,
  });

  @override
  State<ApiKeySettingsWidget> createState() => _ApiKeySettingsWidgetState();
}

class _ApiKeySettingsWidgetState extends State<ApiKeySettingsWidget> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _hasExistingKey = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkExistingKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingKey() async {
    final hasKey = await PollinationsApiConfig.hasApiKey();
    if (mounted) {
      setState(() {
        _hasExistingKey = hasKey;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('Please enter an API key', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await PollinationsApiConfig.setApiKey(key);
      PollinationsApi.instance.clearCachedApiKey();

      if (mounted) {
        setState(() {
          _hasExistingKey = true;
          _isSaving = false;
        });
        _apiKeyController.clear();
        _showSnackBar('✅ API key saved securely');
        widget.onKeyUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Failed to save API key: $e', isError: true);
      }
    }
  }

  Future<void> _deleteApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key?'),
        content: const Text(
          'This will remove your stored API key. '
          'You may need to enter it again to use AI features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PollinationsApiConfig.deleteApiKey();
        PollinationsApi.instance.clearCachedApiKey();

        if (mounted) {
          setState(() => _hasExistingKey = false);
          _showSnackBar('API key deleted');
          widget.onKeyUpdated?.call();
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Failed to delete API key: $e', isError: true);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = widget.isDark;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.key_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'API Key Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status indicator
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasExistingKey ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _hasExistingKey ? 'API key configured' : 'No API key set',
                style: TextStyle(color: hintColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Enter your Pollinations API key to enable AI features. '
            'Your key is stored securely on your device.',
            style: TextStyle(color: hintColor, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Input field
          TextField(
            controller: _apiKeyController,
            obscureText: _isObscured,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: _hasExistingKey ? '••••••••••••' : 'Enter API key',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.vpn_key, color: hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: hintColor,
                ),
                onPressed: () {
                  setState(() => _isObscured = !_isObscured);
                },
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveApiKey,
                  icon: _isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Key'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_hasExistingKey) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _deleteApiKey,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Delete API key',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.red.withOpacity(0.2)
                        : Colors.red[50],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: Some features may work without an API key, '
                    'but having one ensures reliable access.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog to quickly set API key
Future<bool> showApiKeyDialog(
  BuildContext context, {
  bool isDark = false,
}) async {
  final controller = TextEditingController();
  bool obscured = true;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.key, color: Colors.amber),
              SizedBox(width: 8),
              Text('Enter API Key'),
            ],
          ),
          content: TextField(
            controller: controller,
            obscureText: obscured,
            decoration: InputDecoration(
              hintText: 'Your Pollinations API key',
              suffixIcon: IconButton(
                icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => obscured = !obscured),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = controller.text.trim();
                if (key.isNotEmpty) {
                  await PollinationsApiConfig.setApiKey(key);
                  PollinationsApi.instance.clearCachedApiKey();
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  controller.dispose();
  return result ?? false;
}
