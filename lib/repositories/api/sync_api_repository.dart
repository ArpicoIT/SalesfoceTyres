import 'package:arpicoiam/iam.dart';

import '../../config/api_paths.dart';

class SyncApiRepository {
  SyncApiRepository._();

  /// Sync collection headers to the backend
  static Future<ApiResponse<Map<String, dynamic>>> syncReceiptHeader(
      Map<String, dynamic> body) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.post(
        ApiPaths.syncReceiptHeader,
        data: body,
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: res.data is Map<String, dynamic>
            ? res.data
            : {'message': res.data.toString()},
        message: 'Receipt header synced successfully',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }

  /// Sync collection details to the backend
  static Future<ApiResponse<Map<String, dynamic>>> syncReceiptDetail(
      Map<String, dynamic> body) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.post(
        ApiPaths.syncReceiptDetail,
        data: body,
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: res.data is Map<String, dynamic>
            ? res.data
            : {'message': res.data.toString()},
        message: 'Receipt detail synced successfully',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }

  /// Sync visit location to the backend
  static Future<ApiResponse<Map<String, dynamic>>> syncVisitLocation(
      Map<String, dynamic> body) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.post(
        ApiPaths.syncVisitLocation,
        data: body,
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: res.data is Map<String, dynamic>
            ? res.data
            : {'message': res.data.toString()},
        message: 'Visit location synced successfully',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }
}


// import 'package:arpicoiam/iam.dart';
//
// import '../../config/api_paths.dart';
// import '../../models/collection_model.dart';
// import '../../services/database/db_columns.dart';
//
// class SyncApiRepository {
//
//   static Future<ApiResponse<List<Map<String, dynamic>>>> syncCollectionHeaders(List<CollectionHeaderModel> headers) async {
//     try {
//       final dio = ApiManager.client.dio;
//
//       final user = await AIAMStorage.instance.getUser();
//
//       if(user == null){
//         return ApiResponse.loginUserNotFound();
//       }
//
//       final res = await HttpService.post(
//         DbConnect.URL_SYNC_COLLECTION_HEADER,
//         body,
//       );
//
//       for()
//
//       final res = await dio.post(
//         ApiPaths.syncReceiptHeader,
//         body: ,
//         // options: ApiOptions().parent(),
//       );
//
//       final data = List<Map<String, dynamic>>.from(res.data).map((e) {
//         final map = Map<String, dynamic>.from(e);
//         map.remove(DBColumns.ID);
//         map[DBColumns.CREATED_AT] = DateTime.now().toIso8601String();
//         map[DBColumns.CREATED_BY] = user.userId;
//         return map;
//       }).toList();
//
//       return ApiResponse.success(
//         statusCode: res.statusCode,
//         data: data,//  List<Map<String, dynamic>>.from(res.data).toList(),
//         message: 'Download successfully',
//       );
//     } catch (e) {
//       return ApiResponse.failure(e);
//     }
//
//   }
//
// }