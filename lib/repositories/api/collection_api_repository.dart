import 'package:arpicoiam/iam.dart';

import '../../config/api_paths.dart';
import '../../helpers/json_helper.dart';
import '../../models/collection_model.dart';

class CollectionApiRepository {
  static Future<ApiResponse<List<CollectionHeaderModel>>> getCollectionHeaders(
    UserModel currentUser, {
    required String csCode,
    required double amount,
    required String fromDate,
    required String toDate,
    String docNo = "",
  }) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.post(
        ApiPaths.receiptSearch,
        data: {
          "sbu_code": currentUser.sbuCode,
          "loc_code": currentUser.locCode,
          "rep_id": "", // currentUser.userId,
          "tbcode": "", // currentUser.tabCode,
          "fromdate": fromDate,
          "todate": toDate,
          "docnum": docNo,
          "cscode": csCode,
          "amount": amount,
          "gridtype": "Header",
        },
        options: ApiOptions().parent(),
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: JsonHelper.jsonListToModelList(
          List<Map<String, dynamic>>.from(res.data).toList(),
          CollectionHeaderModel.fromJson,
        ),
        message: 'Success',
      );
    } catch (e) {
      return ApiResponse.failure(e);
    }
  }

  static Future<ApiResponse<List<CollectionDetailModel>>> getCollectionDetails(
    UserModel currentUser, {
    String fromDate = "",
    String toDate = "",
    required String docNo,
  }) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.post(
        ApiPaths.receiptSearch,
        data: {
          "sbu_code": currentUser.sbuCode,
          "loc_code": currentUser.locCode,
          "rep_id": "", //currentUser.userId,
          "tbcode": "", //currentUser.tabCode,
          "fromdate": fromDate,
          "todate": toDate,
          "docnum": docNo,
          "cscode": "",
          "amount": "",
          "gridtype": "Detail",
        },
      );

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: JsonHelper.jsonListToModelList(
          List<Map<String, dynamic>>.from(res.data).toList(),
          CollectionDetailModel.fromJson,
        ),
        message: 'Success',
      );

    } catch (e) {
      return ApiResponse.failure(e);
    }
  }
}
