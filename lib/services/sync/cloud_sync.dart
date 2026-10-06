import 'package:flutter/material.dart';

import '../database/repositories/sync_db_repository.dart';

/// High-level sync orchestration service.
/// Calls individual sync operations for all data entities.
class CloudSync {
  CloudSync._();

  /// Sync all data entities to the backend.
  /// Returns a map of entity name to (success, failed) counts.
  static Future<Map<String, (int success, int failed)>> syncAll() async {
    final results = <String, (int, int)>{};

    // 1. Sync receipt headers
    try {
      final headerResult = await SyncDbRepository.collectionHeaders();
      results['Receipt Headers'] = headerResult;
    } catch (e) {
      debugPrint('Sync receipt headers failed: $e');
      results['Receipt Headers'] = (0, -1);
    }

    // 2. Sync receipt details
    try {
      final detailResult = await SyncDbRepository.collectionDetails();
      results['Receipt Details'] = detailResult;
    } catch (e) {
      debugPrint('Sync receipt details failed: $e');
      results['Receipt Details'] = (0, -1);
    }

    // 3. Sync visit locations
    try {
      final visitResult = await SyncDbRepository.visitLocations();
      results['Visit Locations'] = visitResult;
    } catch (e) {
      debugPrint('Sync visit locations failed: $e');
      results['Visit Locations'] = (0, -1);
    }

    return results;
  }

  /// Sync only receipt headers and details.
  static Future<Map<String, (int success, int failed)>> syncReceipts() async {
    final results = <String, (int, int)>{};

    try {
      final headerResult = await SyncDbRepository.collectionHeaders();
      results['Receipt Headers'] = headerResult;
    } catch (e) {
      debugPrint('Sync receipt headers failed: $e');
      results['Receipt Headers'] = (0, -1);
    }

    try {
      final detailResult = await SyncDbRepository.collectionDetails();
      results['Receipt Details'] = detailResult;
    } catch (e) {
      debugPrint('Sync receipt details failed: $e');
      results['Receipt Details'] = (0, -1);
    }

    return results;
  }

  /// Sync only visit locations.
  static Future<(int success, int failed)> syncVisitLocations() async {
    return SyncDbRepository.visitLocations();
  }
}
// class SyncData {
//   static DBHelper dbHelper = DBHelper();
//
//   static Future<void> syncCollectionHeader() async {
//     if (!SysConfig.enableLiveSync) {
//       SysConfig.log('⚠️ Skipping syncCollectionHeader (debug/test mode)');
//       return;
//     }
//
//     debugPrint("🔄 Syncing Collection Header...${DateTime.now()}");
//
//     dbHelper
//         .getData(
//       """SELECT * FROM ${DbConnect.TABLE_collection_header} WHERE ${DbConnect.C_synsts} = '${SyncStatus.PEND.name}' OR ${DbConnect.C_synsts} = '${SyncStatus.FAIL.name}'""",
//     )
//         .then((result) async {
//       if (result != null && result.isNotEmpty) {
//         for (var row in result) {
//           try {
//             Map<String, dynamic> body = {
//               DbConnect.C_sbu_code: row[DbConnect.C_sbu_code],
//               DbConnect.C_loc_code: row[DbConnect.C_loc_code],
//               DbConnect.C_doc_code: row[DbConnect.C_doc_code],
//               DbConnect.C_doc_no: row[DbConnect.C_doc_no],
//               DbConnect.C_cs_code: row[DbConnect.C_cs_code],
//               DbConnect.C_paymod: row[DbConnect.C_paymod],
//               DbConnect.C_total_amount: row[DbConnect.C_total_amount],
//               DbConnect.C_chq_num: row[DbConnect.C_chq_num],
//               DbConnect.C_chq_date: row[DbConnect.C_chq_date],
//               DbConnect.C_bank_code: row[DbConnect.C_bank_code],
//               DbConnect.C_branch_code: row[DbConnect.C_branch_code],
//               DbConnect.C_dd_ref_no: row[DbConnect.C_dd_ref_no],
//               DbConnect.C_remark: row[DbConnect.C_remark],
//               DbConnect.C_gps_lat: row[DbConnect.C_gps_lat],
//               DbConnect.C_gps_lng: row[DbConnect.C_gps_lng],
//               // DbConnect.C_synsts: row[DbConnect.C_synsts],
//               DbConnect.C_creaby: row[DbConnect.C_creaby],
//               DbConnect.C_creadt: row[DbConnect.C_creadt],
//               DbConnect.C_txn_date: row[DbConnect.C_txn_date],
//               DbConnect.C_tb_code: sp.getString(DbConnect.SP_TBCODE),
//               DbConnect.C_verified: false,
//             };
//
//             final response = await HttpService.post(
//               DbConnect.URL_SYNC_COLLECTION_HEADER,
//               body,
//             );
//             final responseBody = jsonDecode(response.body);
//
//             if (response.statusCode == 200) {
//               var count = await dbHelper.updateTable(
//                 DbConnect.TABLE_collection_header,
//                 where: "${DbConnect.C_ID}=?",
//                 whereArgs: [row[DbConnect.C_ID]],
//                 values: {DbConnect.C_synsts: SyncStatus.SUCC.name},
//               );
//
//               debugPrint(
//                 "✅ Synced Collection Header: ${row[DbConnect.C_doc_no]}. Count:$count",
//               );
//             } else {
//               debugPrint(
//                 "❌ Server Error Collection: ${responseBody['error'] ?? 'Unknown'}",
//               );
//             }
//           } catch (e) {
//             debugPrint("❌ Sync Exception Collection: $e");
//           }
//         }
//       } else {
//         debugPrint(
//           "ℹ️ No pending or failed records found in collection header for syncing.",
//         );
//       }
//     });
//   }
//
//   static Future<void> syncCollectionDetail(SharedPreferences sp) async {
//     if (!SysConfig.enableLiveSync) {
//       SysConfig.log('⚠️ Skipping syncCollectionDetail (debug/test mode)');
//       return;
//     }
//
//     debugPrint("🔄 Syncing Collection Details...${DateTime.now()}");
//
//     dbHelper
//         .getData(
//       """SELECT * FROM ${DbConnect.TABLE_collection_detail} WHERE ${DbConnect.C_synsts} = '${SyncStatus.PEND.name}' OR ${DbConnect.C_synsts} = '${SyncStatus.FAIL.name}'""",
//     )
//         .then((result) async {
//       if (result != null && result.isNotEmpty) {
//         for (var row in result) {
//           try {
//             Map<String, dynamic> body = {
//               DbConnect.C_sbu_code: row[DbConnect.C_sbu_code],
//               DbConnect.C_loc_code: row[DbConnect.C_loc_code],
//               DbConnect.C_doc_code: row[DbConnect.C_doc_code],
//               DbConnect.C_doc_no: row[DbConnect.C_doc_no],
//               DbConnect.C_seq_no: row[DbConnect.C_seq_no],
//               DbConnect.C_rec_doc: row[DbConnect.C_rec_doc],
//               DbConnect.C_rec_no: row[DbConnect.C_rec_no],
//               DbConnect.C_inv_doc: row[DbConnect.C_inv_doc],
//               DbConnect.C_inv_no: row[DbConnect.C_inv_no],
//               DbConnect.C_setoff_amount: row[DbConnect.C_setoff_amount],
//               // DbConnect.C_synsts: row[DbConnect.C_synsts],
//               DbConnect.C_creaby: row[DbConnect.C_creaby],
//               DbConnect.C_creadt: row[DbConnect.C_creadt],
//               DbConnect.C_txn_date: row[DbConnect.C_txn_date],
//               DbConnect.C_tb_code: sp.getString(DbConnect.SP_TBCODE),
//               DbConnect.C_verified: false,
//             };
//
//             final response = await HttpService.post(
//               DbConnect.URL_SYNC_COLLECTION_DETAIL,
//               body,
//             );
//             final responseBody = jsonDecode(response.body);
//             if (response.statusCode == 200) {
//               var count = await dbHelper.updateTable(
//                 DbConnect.TABLE_collection_detail,
//                 where: "${DbConnect.C_ID}=?",
//                 whereArgs: [row[DbConnect.C_ID]],
//                 values: {DbConnect.C_synsts: SyncStatus.SUCC.name},
//               );
//
//               debugPrint(
//                 "✅ Synced Collection Detail: ${row[DbConnect.C_doc_no]}-${row[DbConnect.C_seq_no]}. Count:$count",
//               );
//             } else {
//               debugPrint(
//                 "❌ Server Error Collection Detail: ${responseBody['error'] ?? 'Unknown'}",
//               );
//             }
//           } catch (e) {
//             debugPrint("❌ Sync Exception Collection Detail: $e");
//           }
//         }
//       } else {
//         debugPrint(
//           "ℹ️ No pending or failed records found in collection details for syncing.",
//         );
//       }
//     });
//   }
//
//   static Future<void> syncVisitLocation(SharedPreferences sp) async {
//     if (!SysConfig.enableLiveSync) {
//       SysConfig.log('⚠️ Skipping syncVisitLocation (debug/test mode)');
//       return;
//     }
//
//     debugPrint("🔄 Syncing Visit Location...${DateTime.now()}");
//
//     dbHelper
//         .getData("""
//           SELECT * FROM ${DbConnect.TABLE_visit_Location} WHERE ${DbConnect.C_synsts} = '${SyncStatus.PEND.name}' OR ${DbConnect.C_synsts} = '${SyncStatus.FAIL.name}'""")
//         .then((result) async {
//       if (result != null && result.isNotEmpty) {
//         for (var row in result) {
//           try {
//             Map<String, dynamic> body = {
//               DbConnect.C_sbu_code: row[DbConnect.C_sbu_code],
//               DbConnect.C_loc_code: row[DbConnect.C_loc_code],
//               DbConnect.C_cs_code: row[DbConnect.C_cs_code],
//               DbConnect.C_cs_name: row[DbConnect.C_cs_name],
//               DbConnect.C_remark: row[DbConnect.C_remark],
//               DbConnect.C_gps_lat: row[DbConnect.C_gps_lat],
//               DbConnect.C_gps_lng: row[DbConnect.C_gps_lng],
//               DbConnect.C_creaby: row[DbConnect.C_creaby],
//               DbConnect.C_creadt: row[DbConnect.C_creadt],
//               DbConnect.C_txn_date: row[DbConnect.C_txn_date],
//               DbConnect.C_tb_code: sp.getString(DbConnect.SP_TBCODE),
//             };
//
//             final response = await HttpService.post(
//               DbConnect.URL_SYNC_VISIT_LOCATION,
//               body,
//             );
//             final responseBody = jsonDecode(response.body);
//             if (response.statusCode == 200) {
//               var count = await dbHelper.updateTable(
//                 DbConnect.TABLE_visit_Location,
//                 where: "${DbConnect.C_ID}=?",
//                 whereArgs: [row[DbConnect.C_ID]],
//                 values: {DbConnect.C_synsts: SyncStatus.SUCC.name},
//               );
//               debugPrint(
//                 "✅ Synced Visit Location: ${row[DbConnect.C_cs_code]}. Count:$count",
//               );
//             } else {
//               debugPrint(
//                 "❌ Server Error Visit Location: ${responseBody['error'] ?? 'Unknown'}",
//               );
//             }
//           } catch (e) {
//             debugPrint("❌ Sync Exception Visit Location: $e");
//           }
//         }
//       } else {
//         debugPrint(
//           "ℹ️ No pending or failed records found in visit location for syncing.",
//         );
//       }
//     });
//   }
// }