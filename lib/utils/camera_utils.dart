import 'package:image_picker/image_picker.dart';

class CameraUtils {
  /// Take a picture and save it to a file. Then run an optional [onCameraFileFunction] function on it.
  static Future<String?> takePicture(
      {Function? onCameraFileFunction, int? imageQuality}) async {
    final picker = ImagePicker();
    var imageFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: imageQuality);
    if (imageFile == null) {
      return null;
    }
    if (onCameraFileFunction != null) {
      onCameraFileFunction(imageFile.path);
    }
    return imageFile.path;
  }

  /// Load an image from the gallery. Then run an optional [onCameraFileFunction] function on it.
  static Future<String?> loadImageFromGallery(
      {Function? onCameraFileFunction}) async {
    final picker = ImagePicker();
    var imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return null;
    }
    if (onCameraFileFunction != null) {
      onCameraFileFunction(imageFile.path);
    }
    return imageFile.path;
  }
}
