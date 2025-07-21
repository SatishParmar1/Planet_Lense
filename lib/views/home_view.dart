import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/plant_identification_viewmodel.dart';
import '../widgets/image_display_widget.dart';
import '../widgets/language_selector.dart';
import '../widgets/action_buttons.dart';
import '../widgets/plant_data_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Lens'),
        centerTitle: true,
      ),
      body: Consumer<PlantIdentificationViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Display Area
                  ImageDisplayWidget(
                    imageFile: viewModel.selectedImage,
                    onTap: () => _showImageSourceDialog(context, viewModel),
                  ),
                  const SizedBox(height: 20),

                  // Language Selection
                  LanguageSelector(
                    selectedLanguage: viewModel.selectedLanguage,
                    languages: viewModel.languages,
                    onLanguageChanged: viewModel.changeLanguage,
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  ActionButtons(
                    onSelectImage: () => _showImageSourceDialog(context, viewModel),
                    onIdentifyPlant: viewModel.identifyPlant,
                    isLoading: viewModel.isLoading,
                    hasImage: viewModel.hasImage,
                  ),
                  const SizedBox(height: 20),

                  // Results Display Area
                  _buildResultsWidget(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsWidget(PlantIdentificationViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Identifying your plant..."),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Column(
        children: [
          Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: viewModel.clearResults,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    if (viewModel.hasPlantData) {
      return PlantDataCard(plantData: viewModel.plantData!);
    }

    // Default empty state
    return const SizedBox.shrink();
  }

  void _showImageSourceDialog(BuildContext context, PlantIdentificationViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.tealAccent),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.tealAccent),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
