import 'dart:io';

import 'package:arpicoiam/iam.dart';

import '../../config/api_paths.dart';

class UploadApiRepository {
  static Future<ApiResponse> uploadSlip(UserModel currentUser, {
    required String docCode,
    required String docNo,
    required String bankCode,
    required List<File> files,
  }) async {
    try {
      final dio = ApiManager.client.dio;

      final formData = FormData.fromMap({
        // 'image': await MultipartFile.fromFile(file.path),
        'image': await Future.wait(
          files.map((file) => MultipartFile.fromFile(file.path)),
        ),
        'bank_code': bankCode
      });

      final res = await dio.post(
        '${ApiPaths.uploadReceiptSlips}/$docCode/$docNo',
        data: formData,
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: res.data,
        message: res.data['message'] ?? 'Upload successfully',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }
}
