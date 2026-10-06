import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  ImageService._();

  static final instance = ImageService._();

  final ImagePicker _picker = ImagePicker();

  // ==========================
  // PICK IMAGE
  // ==========================

  Future<File?> pickImage({
    ImageSource source = ImageSource.camera,
    CameraDevice cameraDevice = CameraDevice.front,
    int imageQuality = 70,
    double maxWidth = 1600,
    double maxHeight = 1600,
  }) async {
    final result = await _picker.pickImage(
      source: source,
      preferredCameraDevice: cameraDevice,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    if (result == null) return null;

    return File(result.path);
  }

  // ==========================
  // CAPTURE IMAGE
  // ==========================

  Future<File?> captureImage({
    CameraDevice cameraDevice = CameraDevice.front,
    bool crop = true,
    bool compress = true,
    String? newPath,
  }) async {
    File? file = await pickImage(
      source: ImageSource.camera,
      cameraDevice: cameraDevice,
    );

    if (file == null) return null;

    if (crop) {
      file = await cropImage(file) ?? file;
    }

    if (compress) {
      file = await compressImage(file) ?? file;
    }

    if (newPath != null) {
      return file.copy(newPath);
    }
    return file;
  }

  // ==========================
  // CROP IMAGE
  // ==========================

  Future<File?> cropImage(
    File file, {
    CropAspectRatio? aspectRatio,
    int compressQuality = 80,
  }) async {
    final result = await ImageCropper().cropImage(
      sourcePath: file.path,

      compressQuality: compressQuality,

      aspectRatio: aspectRatio,

      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image', lockAspectRatio: false),

        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (result == null) return null;

    return File(result.path);
  }

  // ==========================
  // COMPRESS IMAGE
  // ==========================

  Future<File?> compressImage(
    File file, {
    int quality = 70,
    int minWidth = 1200,
    int minHeight = 1200,
  }) async {
    final targetPath =
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,

      quality: quality,

      minWidth: minWidth,
      minHeight: minHeight,

      format: CompressFormat.jpeg,
    );

    if (result == null) return null;

    return File(result.path);
  }

  // ==========================
  // SAVE IMAGE
  // ==========================

  Future<File> saveImage(File file, {required String fileName}) async {
    final dir = await getApplicationDocumentsDirectory();

    final path = '${dir.path}/$fileName.jpg';

    return file.copy(path);
  }

  // ==========================
  // FILE SIZE
  // ==========================

  Future<int> fileSize(File file) async {
    return file.length();
  }

  Future<double> fileSizeKB(File file) async {
    final bytes = await file.length();

    return bytes / 1024;
  }

  Future<double> fileSizeMB(File file) async {
    final bytes = await file.length();

    return bytes / (1024 * 1024);
  }

  Future<String> fileSizeString(Object source) async {
    int bytes;

    if (source is File) {
      bytes = await source.length();
    } else if (source is int) {
      bytes = source;
    } else {
      throw ArgumentError(
        'Source must be File or int bytes',
      );
    }

    if (bytes <= 0) return '0 B';

    const units = [
      'B',
      'KB',
      'MB',
      'GB',
      'TB',
    ];

    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 2)} ${units[unitIndex]}';
  }

  // ==========================
  // VALIDATION
  // ==========================

  Future<bool> isSizeAllowed(File file, {int maxMB = 5}) async {
    final size = await file.length();

    return size <= maxMB * 1024 * 1024;
  }

  // ==========================
  // DELETE
  // ==========================

  Future<void> delete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==========================
  // EXTENSIONS
  // ==========================

  String getExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  bool isImage(File file) {
    const extensions = ['jpg', 'jpeg', 'png', 'webp'];

    return extensions.contains(getExtension(file));
  }
}
