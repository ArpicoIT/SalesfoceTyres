import '../../../models/system_file_model.dart';
import '../db_columns.dart';
import '../db_constants.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class SystemFileDbRepository {
  SystemFileDbRepository._();

  static Future<double?> getMaxCashDiscount() async {
    final result = await DBHelper.querySingle(
        DBTables.SYSTEM_FILES,
        where: '${DBColumns.PARA_NAME} = ?',
        whereArgs: [DBConstants.SYS_MAX_CASH_DISCOUNT]
    ).then((res) => res != null ? SystemFileModel.fromJson(res) : null);

    if(result == null){
      return null;
    }

    return double.tryParse(result.comment??'0') ?? 0;
  }

  static Future<double?> getMaxBulkDiscount() async {
    final result = await DBHelper.querySingle(
        DBTables.SYSTEM_FILES,
        where: '${DBColumns.PARA_NAME} = ?',
        whereArgs: [DBConstants.SYS_MAX_BULK_DISCOUNT]
    ).then((res) => res != null ? SystemFileModel.fromJson(res) : null);

    if(result == null){
      return null;
    }

    return double.tryParse(result.comment??'0') ?? 0;
  }

  static Future<List<String>?> getTradingDocCodes() async {
    final result = await DBHelper.querySingle(
        DBTables.SYSTEM_FILES,
        where: '${DBColumns.PARA_NAME} = ?',
        whereArgs: [DBConstants.SYS_TRADING_DOC_CODES]
    ).then((res) => res != null ? SystemFileModel.fromJson(res) : null);

    if(result == null){
      return null;
    }

    final value = result.comment;

    if (value == null || value.trim().isEmpty) {
      return [];
    }

    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static Future<List<String>?> getNonTradingDocCodes() async {
    final result = await DBHelper.querySingle(
        DBTables.SYSTEM_FILES,
        where: '${DBColumns.PARA_NAME} = ?',
        whereArgs: [DBConstants.SYS_NON_TRADING_DOC_CODES]
    ).then((res) => res != null ? SystemFileModel.fromJson(res) : null);

    if(result == null){
      return null;
    }

    final value = result.comment;

    if (value == null || value.trim().isEmpty) {
      return [];
    }

    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static Future<double?> getMaxCashLimit() async {
    final result = await DBHelper.querySingle(
        DBTables.SYSTEM_FILES,
        where: '${DBColumns.PARA_NAME} = ?',
        whereArgs: [DBConstants.SYS_MAX_CASH_LIMIT]
    ).then((res) => res != null ? SystemFileModel.fromJson(res) : null);

    if(result == null){
      return null;
    }

    final value = result.comment;

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value) ?? 0.0;
  }



}