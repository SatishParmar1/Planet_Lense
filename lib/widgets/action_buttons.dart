import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSelectImage;
  final VoidCallback? onIdentifyPlant;
  final bool isLoading;
  final bool hasImage;

  const ActionButtons({
    super.key,
    required this.onSelectImage,
    required this.onIdentifyPlant,
    required this.isLoading,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSelectImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (!hasImage || isLoading) ? null : onIdentifyPlant,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(isLoading ? 'Identifying...' : 'Identify'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
