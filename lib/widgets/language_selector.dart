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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
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
            child: DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Colors.grey[850],
              items: languages.keys.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onLanguageChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
