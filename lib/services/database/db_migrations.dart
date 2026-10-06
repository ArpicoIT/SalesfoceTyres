import 'package:sqflite/sqflite.dart';

import 'tables/bank_branch_table.dart';
import 'tables/bank_table.dart';
import 'tables/collection_detail_table.dart';
import 'tables/collection_header_table.dart';
import 'tables/credit_note_table.dart';
import 'tables/customer_table.dart';
import 'tables/invoice_table.dart';
import 'tables/system_file_table.dart';
import 'tables/visit_location_table.dart';

class DBMigrations {
  static Future<void> onCreate(Database db, int version) async {
    await db.execute(SystemFileTable.create);
    await db.execute(CustomerTable.create);
    await db.execute(InvoiceTable.create);
    await db.execute(CreditNoteTable.create);
    await db.execute(BankTable.create);
    await db.execute(BankBranchTable.create);
    await db.execute(CollectionHeaderTable.create);
    await db.execute(CollectionDetailTable.create);
    await db.execute(VisitLocationTable.create);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _migrateV2(db);
    }

    if (oldVersion < 3) {
      await _migrateV3(db);
    }

    if (oldVersion < 4) {
      await _migrateV4(db);
    }
  }

  static Future<void> _migrateV2(Database db) async {}

  static Future<void> _migrateV3(Database db) async {}

  static Future<void> _migrateV4(Database db) async {}
}
