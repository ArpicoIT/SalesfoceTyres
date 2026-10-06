import 'package:arpicoiam/iam.dart';

import '../../../helpers/json_helper.dart';
import '../../../models/credit_note_model.dart';
import '../db_columns.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class CreditNoteDbRepository {
  CreditNoteDbRepository._();

  static Future<List<CreditNoteModel>> getCustomerCreditNotes(
      UserModel currentUser, {
        required String csCode,
      }) async {
    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';

    final result = await DBHelper.query(
      DBTables.CREDIT_NOTES,
      where:
      '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND  ${DBColumns.CS_CODE} = ? ORDER BY ${DBColumns.TXN_DATE} DESC',
      whereArgs: [sbuCode, locCode, csCode],
    );

    return JsonHelper.jsonListToModelList(
      result,
          (json) => CreditNoteModel.fromJson(json),
    );
  }

  static Future<void> updateSetOffs(List<CreditNoteModel> creditNotes) async {
    for (final creditNote in creditNotes) {
      await DBHelper.update(
        DBTables.CREDIT_NOTES,
        values: creditNote
            .copyWith(dueAmount: creditNote.balanceAmount)
            .toJson(),
        where: '${DBColumns.ID} = ?',
        whereArgs: [creditNote.id],
      );
    }
  }

  static Future<bool> hasCreditNotesForCustomer(String csCode) async {
    final result = await DBHelper.query(
      DBTables.CREDIT_NOTES,
      columns: ['1'],
      where: '${DBColumns.CS_CODE} = ?',
      whereArgs: [csCode],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
