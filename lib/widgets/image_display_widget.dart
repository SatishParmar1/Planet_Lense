import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';

class ImageDisplayWidget extends StatelessWidget {
  final XFile? imageFile;
  final VoidCallback onTap;

  const ImageDisplayWidget({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: imageFile == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 80, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.tapToSelectImage,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}
