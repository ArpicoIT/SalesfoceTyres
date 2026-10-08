import 'package:arpicoiam/iam.dart';
import 'package:intl/intl.dart';

import '../../../helpers/date_time_helper.dart';
import '../../../helpers/json_helper.dart';
import '../../../helpers/number_helper.dart';
import '../../../models/collection_model.dart';
import '../../../services/database/db_constants.dart';
import '../../../services/database/db_helper.dart';
import '../../../shared/enum.dart';
import '../db_columns.dart';
import '../db_tables.dart';

class CollectionDbRepository {
  CollectionDbRepository._();

  static Future<CollectionModel> insertCollection(
    CollectionHeaderModel header,
    List<CollectionDetailModel> details,
  ) async {
    /// Insert header
    await DBHelper.insert(
      DBTables.COLLECTION_HEADERS,
      header.toSqlJson(),
    );

    /// Insert details
    await DBHelper.batchInsert(
      DBTables.COLLECTION_DETAILS,
      details.map((e) => e.toSqlJson()).toList(),
    );

    return CollectionModel(header: header, details: details);
  }

  static Future<List<CollectionHeaderModel>> getTodayCollections(
    UserModel currentUser,
  ) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await DBHelper.query(
      DBTables.COLLECTION_HEADERS,
      where:
          '''${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.CREATED_BY} = ? AND ${DBColumns.TXN_DATE} = ?''',
      whereArgs: [
        currentUser.sbuCode,
        currentUser.locCode,
        currentUser.userId,
        today,
      ],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );

    return JsonHelper.jsonListToModelList(
      result,
      CollectionHeaderModel.fromJson,
    );
  }

  static Future<List<CollectionHeaderModel>> getPendingBankDepositCollections(
    UserModel currentUser,
  ) async {
    // final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await DBHelper.query(
      DBTables.COLLECTION_HEADERS,
      where:
          ''' ${DBColumns.SBU_CODE} = ?
      AND ${DBColumns.LOC_CODE} = ?
      AND ${DBColumns.CREATED_BY} = ?
      AND ${DBColumns.DEPOSITED} = ?
      ''',
      whereArgs: [
        currentUser.sbuCode,
        currentUser.locCode,
        currentUser.userId,
        0,
      ],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );

    return JsonHelper.jsonListToModelList(
      result,
      CollectionHeaderModel.fromJson,
    );
  }

  static Future<List<CollectionHeaderModel>> getDuplicateChequeCollections(
    String bankCode,
    String chqNo,
  ) async {
    if (bankCode.trim().isEmpty || chqNo.trim().isEmpty) {
      return [];
    }

    final result = await DBHelper.query(
      DBTables.COLLECTION_HEADERS,
      where: '''
        ${DBColumns.BANK_CODE} = ? AND
        ${DBColumns.CHQ_NO} = ?
      ''',
      whereArgs: [bankCode, chqNo],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );

    return JsonHelper.jsonListToModelList(
      result,
      CollectionHeaderModel.fromJson,
    );
  }

  static Future<List<CollectionHeaderModel>> getDuplicateCashCollections({
    required String csCode,
    required double amount,
  }) async {
    if (amount == 0) {
      return [];
    }

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await DBHelper.query(
      DBTables.COLLECTION_HEADERS,
      where: '''
        ${DBColumns.CS_CODE} = ?
        AND ${DBColumns.TOTAL_AMOUNT} = ?
        AND ${DBColumns.TXN_DATE} = ?
      ''',
      whereArgs: [csCode, amount, today],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );

    return JsonHelper.jsonListToModelList(
      result,
      CollectionHeaderModel.fromJson,
    );
  }

  // static Future<double> getInvoiceDiscountPercentage(String docCode, String docNo) async {
  //   final details = JsonHelper.jsonListToModelList(
  //     await DBHelper.query(
  //       DBTables.COLLECTION_DETAILS,
  //       where:
  //       '''${DBColumns.INV_DOC} = ?
  //           AND ${DBColumns.INV_NO} = ?
  //           AND ${DBColumns.DISCOUNTsasasa} > 0''',
  //       whereArgs: [docCode, docNo],
  //       limit: 1,
  //     ),
  //     CollectionDetailModel.fromJson,
  //   );
  //
  //   if (details.isEmpty) {
  //     return 0;
  //   }
  //
  //   return details.first.discount?.toDouble() ?? 0.0;
  // }

  static Future<bool> hasInvoiceDiscountHistory(String docCode, String docNo) async {
    final result = await DBHelper.query(
      DBTables.COLLECTION_DETAILS,
      where:
      '''${DBColumns.INV_DOC} = ? 
            AND ${DBColumns.INV_NO} = ? 
            AND ${DBColumns.DISCOUNT} > 0''',
      whereArgs: [docCode, docNo],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // static Future<CollectionHeaderModel> insertCollectionHeader(UserModel currentUser, CollectionHeaderModel header) async {
  //   final db = AppDatabase.instance.database;
  //   final table = DBTables.COLLECTION_HEADERS;
  //
  //   final String userId = currentUser.userId ?? '';
  //   final String sbuCode = currentUser.sbuCode ?? '';
  //   final String locCode = currentUser.locCode ?? '';
  //   final String tabCode = currentUser.tabCode ?? '';
  //
  //   header = header.copyWith(
  //     sbuCode: sbuCode,
  //     locCode: locCode,
  //     docCode: DBConstants.DOC_RCPD,
  //     docNo: NumberHelper.getSerialNumber(tabCode),
  //     txnDate: DateTimeHelper.getTxnDate(),
  //     synSts: SyncStatus.PEND,
  //     createdBy: userId,
  //     createdAt: DateTimeHelper.getDateTime(),
  //   );
  //
  //   final id =  await db.insert(table, header.toJson());
  //
  //   return header.copyWith(id: id);
  // }
  //
  // static Future<void> insertCollectionDetails(UserModel currentUser, CollectionHeaderModel header, List<CollectionDetailModel> details) async {
  //   final db = AppDatabase.instance.database;
  //   final batch = db.batch();
  //   final table = DBTables.COLLECTION_DETAILS;
  //
  //   final String userId = currentUser.userId ?? '';
  //   final String sbuCode = currentUser.sbuCode ?? '';
  //   final String locCode = currentUser.locCode ?? '';
  //
  //   for (final item in details) {
  //     batch.insert(table, item.toJson());
  //   }
  //
  //   await batch.commit();
  //
  //   return;
  // }
}
