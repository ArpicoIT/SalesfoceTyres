import 'package:arpicoiam/iam.dart';

import '../../../helpers/json_helper.dart';
import '../../../models/customer_model.dart';
import '../db_columns.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class CustomerDbRepository {
  CustomerDbRepository._();

  static Future<List<CustomerModel>> getAllCustomers(UserModel currentUser) async {
    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';


    final result = await DBHelper.query(
      DBTables.CUSTOMERS,
      where:
      '${DBColumns.SBU_CODE} = ?',
      whereArgs: [sbuCode],
    );

    return JsonHelper.jsonListToModelList(
      result,
          (json) => CustomerModel.fromJson(json),
    );
  }

}