// import 'package:flutter/material.dart';
//
// import '../database/db_columns.dart';
// import '../database/db_helper.dart';
// import '../database/db_tables.dart';
// import '../database/repositories/visit_location_db_repository.dart';
// import '../../shared/enum.dart';
// import '../../repositories/api/sync_api_repository.dart';
//
// class SyncApiService {
//   SyncApiService._();
//
//   /// Sync all pending visit locations to the backend
//   static Future<(int success, int failed)> syncVisitLocations() async {
//     final pending = await DBHelper.query(
//       DBTables.VISIT_LOCATIONS,
//       where: '${DBColumns.SYNSTS} = ? OR ${DBColumns.SYNSTS} = ?',
//       whereArgs: [SyncStatus.PEND.name, SyncStatus.FAIL.name],
//       orderBy: '${DBColumns.CREATED_AT} ASC',
//     );
//
//     int success = 0;
//     int failed = 0;
//
//     for (final row in pending) {
//       try {
//         final res = await SyncApiRepository.syncVisitLocation({
//           DBColumns.SBU_CODE: row[DBColumns.SBU_CODE],
//           DBColumns.LOC_CODE: row[DBColumns.LOC_CODE],
//           DBColumns.CS_CODE: row[DBColumns.CS_CODE],
//           DBColumns.CS_NAME: row[DBColumns.CS_NAME],
//           DBColumns.REMARK: row[DBColumns.REMARK],
//           DBColumns.GPS_LAT: row[DBColumns.GPS_LAT],
//           DBColumns.GPS_LNG: row[DBColumns.GPS_LNG],
//           DBColumns.TXN_DATE: row[DBColumns.TXN_DATE],
//           DBColumns.CREATED_BY: row[DBColumns.CREATED_BY],
//           DBColumns.CREATED_AT: row[DBColumns.CREATED_AT],
//         });
//
//         if (res.success) {
//           await VisitLocationDbRepository.updateSyncStatus(
//             id: row[DBColumns.ID] as int,
//             status: SyncStatus.SUCC,
//           );
//           success++;
//         } else {
//           await VisitLocationDbRepository.updateSyncStatus(
//             id: row[DBColumns.ID] as int,
//             status: SyncStatus.FAIL,
//           );
//           failed++;
//         }
//       } catch (e) {
//         debugPrint('Failed to sync visit location: $e');
//         await VisitLocationDbRepository.updateSyncStatus(
//           id: row[DBColumns.ID] as int,
//           status: SyncStatus.FAIL,
//         );
//         failed++;
//       }
//     }
//
//     return (success, failed);
//   }
// }
