import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant_data.dart';
import '../models/app_state.dart';
import '../services/plant_identification_service.dart';
import '../services/image_picker_service.dart';

class PlantIdentificationViewModel extends ChangeNotifier {
  final PlantIdentificationService _plantService = PlantIdentificationService();
  final ImagePickerService _imageService = ImagePickerService();

  // State
  AppState _appState = AppState();
  XFile? _selectedImage;
  PlantData? _plantData;

  // Language options
  final Map<String, String> _languages = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
    'Portuguese': 'pt',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Arabic': 'ar',
    'Hindi': 'hi',
  };

  // Getters
  AppState get appState => _appState;
  XFile? get selectedImage => _selectedImage;
  PlantData? get plantData => _plantData;
  Map<String, String> get languages => _languages;
  String get selectedLanguage => _appState.selectedLanguage;
  bool get isLoading => _appState.isLoading;
  bool get hasError => _appState.hasError;
  String? get errorMessage => _appState.errorMessage;
  bool get hasImage => _selectedImage != null;
  bool get hasPlantData => _plantData != null;

  // Actions
  Future<void> pickImageFromGallery() async {
    try {
      _resetState();
      final image = await _imageService.pickImageFromGallery();
      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      _resetState();
      final image = await _imageService.pickImageFromCamera();
      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to capture image: $e');
    }
  }

  Future<void> setImageFromPath(String imagePath) async {
    try {
      _resetState();
      _selectedImage = XFile(imagePath);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set image: $e');
    }
  }

  Future<void> identifyPlant() async {
    if (_selectedImage == null) {
      _setError('Please select an image first.');
      return;
    }

    try {
      _setLoading();

      // Convert image to base64
      final imageBytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Call the service
      final plantData = await _plantService.identifyPlant(
        base64Image,
        _appState.selectedLanguage,
      );

      _setSuccess(plantData);
    } catch (e) {
      _setError('Failed to identify plant: $e');
    }
  }

  void changeLanguage(String language) {
    if (_languages.containsKey(language)) {
      _appState = _appState.copyWith(selectedLanguage: language);
      // Reset plant data when language changes
      _plantData = null;
      _appState = _appState.copyWith(loadingState: LoadingState.idle);
      notifyListeners();
    }
  }

  void clearResults() {
    _plantData = null;
    _appState = _appState.copyWith(
      loadingState: LoadingState.idle,
      errorMessage: null,
    );
    notifyListeners();
  }

  void _resetState() {
    _selectedImage = null;
    _plantData = null;
    _appState = _appState.copyWith(
      loadingState: LoadingState.idle,
      errorMessage: null,
    );
    notifyListeners();
  }

  void _setLoading() {
    _appState = _appState.copyWith(
      loadingState: LoadingState.loading,
      errorMessage: null,
    );
    _plantData = null;
    notifyListeners();
  }

  void _setSuccess(PlantData plantData) {
    _plantData = plantData;
    _appState = _appState.copyWith(
      loadingState: LoadingState.success,
      errorMessage: null,
    );
    notifyListeners();
  }

  void _setError(String error) {
    _appState = _appState.copyWith(
      loadingState: LoadingState.error,
      errorMessage: error,
    );
    _plantData = null;
    notifyListeners();
  }
}
