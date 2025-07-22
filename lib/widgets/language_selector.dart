import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, String> languages;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
  });

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: languages.keys.map((String language) {
            return ListTile(
              title: Text(language),
              trailing: language == selectedLanguage
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                onLanguageChanged(language); // Notify parent
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLanguageBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.language, color: Colors.tealAccent),
            const SizedBox(width: 12),
            const Text('Language:', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLanguage,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
