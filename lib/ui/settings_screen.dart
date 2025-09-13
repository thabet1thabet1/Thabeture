import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Settings screen for configuring the Screenshot OCR app
/// 
/// This screen allows users to configure:
/// - OCR language preferences
/// - Screenshot save location
/// - Keyboard shortcuts
/// - Notification preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  String _selectedLanguage = 'en';
  bool _autoSaveScreenshots = true;
  bool _showNotifications = true;
  bool _copyToClipboardAutomatically = true;
  double _ocrConfidence = AppConstants.ocrConfidenceThreshold;
  
  final List<String> _availableLanguages = [
    'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko'
  ];
  
  final Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'OCR Settings',
            [
              _buildLanguageSelector(),
              _buildConfidenceSlider(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Screenshot Settings',
            [
              _buildSwitchTile(
                'Auto-save screenshots',
                'Save screenshots to disk automatically',
                _autoSaveScreenshots,
                (value) => setState(() => _autoSaveScreenshots = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Clipboard Settings',
            [
              _buildSwitchTile(
                'Auto-copy to clipboard',
                'Automatically copy OCR text to clipboard',
                _copyToClipboardAutomatically,
                (value) => setState(() => _copyToClipboardAutomatically = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                'Show notifications',
                'Display success and error notifications',
                _showNotifications,
                (value) => setState(() => _showNotifications = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              _buildInfoTile('Version', AppConstants.appVersion),
              _buildInfoTile('App Name', AppConstants.appName),
              _buildActionTile(
                'View Licenses',
                'Show open source licenses',
                () => _showLicenses(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('OCR Language'),
      subtitle: Text(_languageNames[_selectedLanguage] ?? _selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageSelector(),
    );
  }
  
  Widget _buildConfidenceSlider() {
    return ListTile(
      title: const Text('OCR Confidence Threshold'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${(_ocrConfidence * 100).round()}% - Higher values mean more accurate but potentially less text'),
          const SizedBox(height: 8),
          Slider(
            value: _ocrConfidence,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${(_ocrConfidence * 100).round()}%',
            onChanged: (value) => setState(() => _ocrConfidence = value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
  
  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  Widget _buildActionTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select OCR Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableLanguages.length,
            itemBuilder: (context, index) {
              final languageCode = _availableLanguages[index];
              final languageName = _languageNames[languageCode] ?? languageCode;
              
              return RadioListTile<String>(
                title: Text(languageName),
                subtitle: Text(languageCode.toUpperCase()),
                value: languageCode,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
    );
  }
}