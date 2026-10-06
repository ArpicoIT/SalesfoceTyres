import 'package:arpicoiam/iam.dart';

import '../../../helpers/json_helper.dart';
import '../../../models/bank_model.dart';
import '../db_columns.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class BankDbRepository {
  BankDbRepository._();

  static Future<List<BankModel>> getAllBanks(UserModel currentUser) async {
    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';

    final result = await DBHelper.query(DBTables.BANKS);

    return JsonHelper.jsonListToModelList(
      result,
      (json) => BankModel.fromJson(json),
    );
  }

  static Future<List<BankBranchModel>> getBankBranches(
    UserModel currentUser, {
    required String bankCode,
  }) async {
    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';

    if (bankCode.isEmpty) return [];

    final result = await DBHelper.query(
      DBTables.BANKS_BRANCHES,
      where: '${DBColumns.BANK_CODE} = ?',
      whereArgs: [bankCode],
    );
    return JsonHelper.jsonListToModelList(
      result,
      (json) => BankBranchModel.fromJson(json),
    );
  }
}
