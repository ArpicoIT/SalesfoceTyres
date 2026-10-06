import 'package:arpicoiam/iam.dart';

import '../../config/api_paths.dart';
import '../../services/database/db_columns.dart';

class DownloadApiRepository {
  static Future<ApiResponse<List<Map<String, dynamic>>>> download(
    UserModel currentUser, {
    required String downloadType,
    required int limit,
    required int offset,
    required CancelToken cancelToken,
  }) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.get(
        ApiPaths.downloadData,
        queryParameters: {
          "sbu_code": currentUser.sbuCode,
          "loc_code": currentUser.locCode,
          "rep_id": currentUser.userId,
          "dwntyp": downloadType.toLowerCase(),
          "limit": limit,
          "offset": offset,
        },
        cancelToken: cancelToken,
      );

      final data = List<Map<String, dynamic>>.from(res.data).map((e) {
        final map = Map<String, dynamic>.from(e);
        map.remove(DBColumns.ID);
        map[DBColumns.CREATED_AT] = DateTime.now().toIso8601String();
        map[DBColumns.CREATED_BY] = currentUser.userId;
        return map;
      }).toList();

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: data,
        message: 'Download successfully',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }
}
