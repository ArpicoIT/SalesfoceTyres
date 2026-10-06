import 'package:arpicoiam/iam.dart';

import '../../../helpers/json_helper.dart';
import '../../../models/invoice_model.dart';
import '../db_columns.dart';
import '../db_constants.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class InvoiceDbRepository {
  InvoiceDbRepository._();

  static Future<List<InvoiceModel>> getCustomerInvoices(
    UserModel currentUser, {
    required String csCode,
  }) async {
    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';

    final result = await DBHelper.query(
      DBTables.INVOICES,
      where:
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.CS_CODE} = ? ORDER BY ${DBColumns.TXN_DATE} DESC',
      whereArgs: [sbuCode, locCode, csCode],
    );

    return JsonHelper.jsonListToModelList(
      result,
      (json) => InvoiceModel.fromJson(json),
    );
  }

  static Future<List<InvoiceModel>> getCustomerInvoicesWithJoinedDiscountsold(
    UserModel currentUser, {
    required String csCode,
  }) async {
    final rows = await DBHelper.rawQuery(
      '''
  SELECT
      i.*,

      CASE
          WHEN i.${DBColumns.CASH_DISCOUNT} <= 0
              THEN COALESCE(cd_cash.${DBColumns.DISCOUNT}, 0)
          ELSE i.${DBColumns.CASH_DISCOUNT}
      END AS ${DBColumns.CASH_DISCOUNT},

      CASE
          WHEN i.${DBColumns.BULK_DISCOUNT} <= 0
              THEN COALESCE(cd_bulk.${DBColumns.DISCOUNT}, 0)
          ELSE i.${DBColumns.BULK_DISCOUNT}
      END AS ${DBColumns.BULK_DISCOUNT}

  FROM ${DBTables.INVOICES} i

  LEFT JOIN ${DBTables.COLLECTION_DETAILS} cd_cash
      ON cd_cash.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
      AND cd_cash.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
      AND cd_cash.${DBColumns.REC_DOC} = ${DBConstants.DOC_CASH_DISCOUNT}
      AND cd_cash.${DBColumns.REC_NO} = ${DBConstants.DOC_CASH_DISCOUNT}
      AND cd_cash.${DBColumns.DISCOUNT} > 0

  LEFT JOIN ${DBTables.COLLECTION_DETAILS} cd_bulk
      ON cd_bulk.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
      AND cd_bulk.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
      AND cd_bulk.${DBColumns.REC_DOC} = ${DBConstants.DOC_BULK_DISCOUNT}
      AND cd_bulk.${DBColumns.REC_NO} = ${DBConstants.DOC_BULK_DISCOUNT}
      AND cd_bulk.${DBColumns.DISCOUNT} > 0

  WHERE i.${DBColumns.SBU_CODE} = ?
    AND i.${DBColumns.LOC_CODE} = ?
    AND i.${DBColumns.CS_CODE} = ?

  ORDER BY i.${DBColumns.TXN_DATE} DESC
  ''',
      [currentUser.sbuCode, currentUser.locCode, csCode],
    );

    return JsonHelper.jsonListToModelList(
      rows,
      (json) => InvoiceModel.fromJson(json),
    );
  }

  static Future<List<InvoiceModel>> getCustomerInvoicesWithJoinedDiscounts(
    UserModel currentUser, {
    required String csCode,
  }) async {
    final rows = await DBHelper.rawQuery(
      '''SELECT
    i.*,

    CASE
        WHEN i.${DBColumns.CASH_DISCOUNT} <= 0 THEN
            COALESCE((
                SELECT cd.${DBColumns.DISCOUNT}
                FROM ${DBTables.COLLECTION_DETAILS} cd
                WHERE cd.${DBColumns.INV_DOC}= i.${DBColumns.DOC_CODE}
                  AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
                  AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_CASH_DISCOUNT}'
                  AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_CASH_DISCOUNT}'
                  AND cd.${DBColumns.DISCOUNT} > 0
                LIMIT 1
            ), 0)
        ELSE i.${DBColumns.CASH_DISCOUNT}
    END AS ${DBColumns.CASH_DISCOUNT},

    CASE
        WHEN i.${DBColumns.BULK_DISCOUNT} <= 0 THEN
            COALESCE((
                SELECT cd.${DBColumns.DISCOUNT}
                FROM ${DBTables.COLLECTION_DETAILS} cd
                WHERE cd.${DBColumns.INV_DOC}= i.${DBColumns.DOC_CODE}
                  AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
                  AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_BULK_DISCOUNT}'
                  AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_BULK_DISCOUNT}'
                  AND cd.${DBColumns.DISCOUNT} > 0
                LIMIT 1
            ), 0)
        ELSE i.${DBColumns.BULK_DISCOUNT}
    END AS ${DBColumns.BULK_DISCOUNT}

FROM ${DBTables.INVOICES} i

WHERE i.${DBColumns.SBU_CODE} = ?
  AND i.${DBColumns.LOC_CODE} = ?
  AND i.${DBColumns.CS_CODE} = ?

ORDER BY i.${DBColumns.TXN_DATE} DESC;
''',
      [currentUser.sbuCode, currentUser.locCode, csCode],
    );

    /// with amount
    //     final rows = await DBHelper.rawQuery(
    //       '''
    // SELECT
    //     i.*,
    //
    //     CASE
    //         WHEN i.${DBColumns.CASH_DISCOUNT} <= 0 THEN
    //             COALESCE((
    //                 SELECT cd.${DBColumns.DISCOUNT}
    //                 FROM ${DBTables.COLLECTION_DETAILS} cd
    //                 WHERE cd.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
    //                   AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
    //                   AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_CASH_DISCOUNT}'
    //                   AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_CASH_DISCOUNT}'
    //                   AND cd.${DBColumns.DISCOUNT} > 0
    //                 LIMIT 1
    //             ), 0)
    //         ELSE i.${DBColumns.CASH_DISCOUNT}
    //     END AS ${DBColumns.CASH_DISCOUNT},
    //
    //     CASE
    //         WHEN i.${DBColumns.BULK_DISCOUNT} <= 0 THEN
    //             COALESCE((
    //                 SELECT cd.${DBColumns.DISCOUNT}
    //                 FROM ${DBTables.COLLECTION_DETAILS} cd
    //                 WHERE cd.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
    //                   AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
    //                   AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_BULK_DISCOUNT}'
    //                   AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_BULK_DISCOUNT}'
    //                   AND cd.${DBColumns.DISCOUNT} > 0
    //                 LIMIT 1
    //             ), 0)
    //         ELSE i.${DBColumns.BULK_DISCOUNT}
    //     END AS ${DBColumns.BULK_DISCOUNT},
    //
    //     CASE
    //         WHEN i.${DBColumns.CASH_DISCOUNT} <= 0 THEN
    //             COALESCE((
    //                 SELECT cd.${DBColumns.SETOFF_AMOUNT}
    //                 FROM ${DBTables.COLLECTION_DETAILS} cd
    //                 WHERE cd.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
    //                   AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
    //                   AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_CASH_DISCOUNT}'
    //                   AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_CASH_DISCOUNT}'
    //                   AND cd.${DBColumns.DISCOUNT} > 0
    //                 LIMIT 1
    //             ), 0)
    //         ELSE i.${DBColumns.CASH_DISCOUNT_AMOUNT}
    //     END AS ${DBColumns.CASH_DISCOUNT_AMOUNT},
    //
    //     CASE
    //         WHEN i.${DBColumns.BULK_DISCOUNT} <= 0 THEN
    //             COALESCE((
    //                 SELECT cd.${DBColumns.SETOFF_AMOUNT}
    //                 FROM ${DBTables.COLLECTION_DETAILS} cd
    //                 WHERE cd.${DBColumns.INV_DOC} = i.${DBColumns.DOC_CODE}
    //                   AND cd.${DBColumns.INV_NO} = i.${DBColumns.DOC_NO}
    //                   AND cd.${DBColumns.REC_DOC} = '${DBConstants.DOC_BULK_DISCOUNT}'
    //                   AND cd.${DBColumns.REC_NO} = '${DBConstants.DOC_BULK_DISCOUNT}'
    //                   AND cd.${DBColumns.DISCOUNT} > 0
    //                 LIMIT 1
    //             ), 0)
    //         ELSE i.${DBColumns.BULK_DISCOUNT_AMOUNT}
    //     END AS ${DBColumns.BULK_DISCOUNT_AMOUNT}
    //
    // FROM ${DBTables.INVOICES} i
    //
    // WHERE i.${DBColumns.SBU_CODE} = ?
    //   AND i.${DBColumns.LOC_CODE} = ?
    //   AND i.${DBColumns.CS_CODE} = ?
    //
    // ORDER BY i.${DBColumns.TXN_DATE} DESC;
    // ''',
    //       [
    //         currentUser.sbuCode,
    //         currentUser.locCode,
    //         csCode,
    //       ],
    //     );

    return JsonHelper.jsonListToModelList(
      rows,
      (json) => InvoiceModel.fromJson(json),
    );
  }

  static Future<void> updateSetOffs(List<InvoiceModel> invoices) async {
    for (final invoice in invoices) {
      await DBHelper.update(
        DBTables.INVOICES,
        values: invoice.copyWith(dueAmount: invoice.balanceAmount).toJson(),
        where: '${DBColumns.ID} = ?',
        whereArgs: [invoice.id],
      );
    }
  }

  /// not use
  // static Future<bool> hasDiscountHistory(
  //   String docCode,
  //   String docNo, {
  //   bool checkInLocal = true,
  // }) async {
  //   if (checkInLocal) {
  //     final localResult = await DBHelper.query(
  //       DBTables.INVOICES,
  //       where:
  //           '${DBColumns.DOC_CODE} = ? '
  //           'AND ${DBColumns.DOC_NO} = ? '
  //           'AND ${DBColumns.DISCOUNTsas} > 0',
  //       whereArgs: [docCode, docNo],
  //       limit: 1,
  //     );
  //
  //     if (localResult.isNotEmpty) return true;
  //   }
  //
  //   final historyResult = await DBHelper.query(
  //     DBTables.COLLECTION_DETAILS,
  //     where:
  //         '${DBColumns.INV_DOC} = ? '
  //         'AND ${DBColumns.INV_NO} = ? '
  //         'AND ${DBColumns.DISCOUNTsasa} > 0',
  //     whereArgs: [docCode, docNo],
  //     limit: 1,
  //   );
  //
  //   return historyResult.isNotEmpty;
  // }

  /// not use
  // static Future<bool> hasDiscountGivenInvoice(InvoiceModel invoice) async {
  //   if (invoice.cashDiscount > 0) return true;
  //
  //   final result = await DBHelper.query(
  //     DBTables.COLLECTION_DETAILS,
  //     where:
  //         '${DBColumns.INV_DOC} = ? AND ${DBColumns.INV_NO} = ? AND ${DBColumns.DISCOUNTssas} > 0',
  //     whereArgs: [invoice.docCode, invoice.docNo],
  //   );
  //
  //   return result.isNotEmpty;
  // }
}
