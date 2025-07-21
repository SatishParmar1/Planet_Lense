import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }
}
