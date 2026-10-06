import 'dart:convert';

import 'package:arpicoiam/iam.dart';

import '../../config/api_paths.dart';
import '../../config/app_config.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../utils/extentions/string_extention.dart';

class InvoiceApiRepository {
  static Future<ApiResponse<Map<String, dynamic>>> requestApproval(
    UserModel currentUser, {
    required CustomerModel customer,
    required InvoiceModel invoice,
  }) async {
    try {
      ApiManager.custom.initialize(
        BaseOptions(baseUrl: AppConfig.approvalWorkflowUrl),
      );
      final dio = ApiManager.custom.dio;

      final res = await dio.post(
        '',
        data: {
          "rep_name": currentUser.userName,
          "cs_code": customer.csCode,
          "cs_name": customer.csName?.replaceSlash,
          "sbu_code": currentUser.sbuCode,
          "loc_code": currentUser.locCode,
          "Invoice_Amount": invoice.originalAmount,
          "Invoice_Number": invoice.docNo,
          "Invoice_Date": invoice.txnDate,
          "Message": "Need approval to skip invoice set-off order",
        },
        options: ApiOptions().bearerToken(
          AppConfig.approvalWorkflowToken,
        ),
      );

      final Map<String, dynamic> data = jsonDecode(res.data) as Map<String, dynamic>;

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: data,
        message: 'Success',
      );

    } catch (e) {
      return ApiResponse.failure(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> checkApprovalState(String docNo) async {
    try {
      final dio = ApiManager.client.dio;

      final res = await dio.get(
        ApiPaths.invoiceApproval,
        queryParameters: {'invoice_number': docNo},
      );

      final list = List<Map<String, dynamic>>.from(res.data).toList();

      if(list.isEmpty){
        return ApiResponse.failure(
          null,
          statusCode: res.statusCode,
          data: null,
          message: 'Empty response',
        );
      }

      return ApiResponse.success(
        statusCode: res.statusCode,
        data: list.first,
        message: 'Success',
      );

    } catch (e) {
      return ApiResponse.failure(e);
    }
  }

}
