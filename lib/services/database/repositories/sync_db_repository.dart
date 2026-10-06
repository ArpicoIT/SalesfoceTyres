import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import '../../../config/api_paths.dart';
import '../../../helpers/json_helper.dart';
import '../../../models/collection_model.dart';
import '../../../models/visit_model.dart';
import '../../../services/database/db_tables.dart';
import '../../../shared/enum.dart';
import '../db_columns.dart';
import '../db_helper.dart';

class SyncDbRepository {
  SyncDbRepository._();

  static Future<(int success, int failed)> collectionHeaders() async {
    final dio = ApiManager.client.dio;

    final currentUser = await IAMService.instance.currentUser();

    final headers = JsonHelper.jsonListToModelList(
      await DBHelper.query(
        DBTables.COLLECTION_HEADERS,
        where:
            '${DBColumns.SBU_CODE} = ? '
            'AND ${DBColumns.LOC_CODE} = ? '
            'AND (${DBColumns.SYNSTS} = ? OR ${DBColumns.SYNSTS} = ?)',
        whereArgs: [
          currentUser.sbuCode,
          currentUser.locCode,
          SyncStatus.PEND.name,
          SyncStatus.FAIL.name,
        ],
        orderBy: '${DBColumns.CREATED_AT} DESC',
      ),
      CollectionHeaderModel.fromJson,
    );

    int success = 0;
    int failed = 0;

    for (final header in headers) {
      try {
        final res = await dio.post(
          ApiPaths.syncReceiptHeader,
          data: header.toApiJson(),
        );

        if (res.statusCode == 200) {
          await DBHelper.update(
            DBTables.COLLECTION_HEADERS,
            values: header.copyWith(synSts: SyncStatus.SUCC).toSqlJson(),
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [header.id],
          );

          success++;
        } else {
          await DBHelper.update(
            DBTables.COLLECTION_HEADERS,
            values: header.copyWith(synSts: SyncStatus.FAIL).toSqlJson(),
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [header.id],
          );

          failed++;
        }
      } catch (e, stackTrace) {
        debugPrint('Failed to sync receipt header ${header.docNo}');
        debugPrint('$e');
        debugPrint('$stackTrace');

        await DBHelper.update(
          DBTables.COLLECTION_HEADERS,
          values: header.copyWith(synSts: SyncStatus.FAIL).toSqlJson(),
          columns: [DBColumns.SYNSTS],
          where: '${DBColumns.ID} = ?',
          whereArgs: [header.id],
        );

        failed++;
      }
    }

    return (success, failed);
  }

  static Future<(int success, int failed)> collectionDetails() async {
    final dio = ApiManager.client.dio;

    final currentUser = await IAMService.instance.currentUser();

    final details = JsonHelper.jsonListToModelList(
      await DBHelper.query(
        DBTables.COLLECTION_DETAILS,
        where:
            '${DBColumns.SBU_CODE} = ? '
            'AND ${DBColumns.LOC_CODE} = ? '
            'AND (${DBColumns.SYNSTS} = ? OR ${DBColumns.SYNSTS} = ?)',
        whereArgs: [
          currentUser.sbuCode,
          currentUser.locCode,
          SyncStatus.PEND.name,
          SyncStatus.FAIL.name,
        ],
        orderBy: '${DBColumns.CREATED_AT} DESC',
      ),
      CollectionDetailModel.fromJson,
    );

    int success = 0;
    int failed = 0;

    for (final detail in details) {
      try {
        final res = await dio.post(
          ApiPaths.syncReceiptDetail,
          data: detail.toApiJson(),
        );

        if (res.statusCode == 200) {
          await DBHelper.update(
            DBTables.COLLECTION_DETAILS,
            values: detail.copyWith(synSts: SyncStatus.SUCC).toSqlJson(),
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [detail.id],
          );

          success++;
        } else {
          await DBHelper.update(
            DBTables.COLLECTION_DETAILS,
            values: detail.copyWith(synSts: SyncStatus.FAIL).toSqlJson(),
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [detail.id],
          );

          failed++;
        }
      } catch (e, stackTrace) {
        debugPrint('Failed to sync receipt detail ${detail.docNo}');
        debugPrint('$e');
        debugPrint('$stackTrace');

        await DBHelper.update(
          DBTables.COLLECTION_DETAILS,
          values: detail.copyWith(synSts: SyncStatus.FAIL).toSqlJson(),
          columns: [DBColumns.SYNSTS],
          where: '${DBColumns.ID} = ?',
          whereArgs: [detail.id],
        );

        failed++;
      }
    }

    return (success, failed);
  }

  static Future<(int success, int failed)> visitLocations() async {
    final dio = ApiManager.client.dio;

    final currentUser = await IAMService.instance.currentUser();

    final visits = JsonHelper.jsonListToModelList(
      await DBHelper.query(
        DBTables.VISIT_LOCATIONS,
        where:
            '${DBColumns.SBU_CODE} = ? '
            'AND ${DBColumns.LOC_CODE} = ? '
            'AND ${DBColumns.CREATED_BY} = ? '
            'AND (${DBColumns.SYNSTS} = ? OR ${DBColumns.SYNSTS} = ?)',
        whereArgs: [
          currentUser.sbuCode,
          currentUser.locCode,
          currentUser.userId,
          SyncStatus.PEND.name,
          SyncStatus.FAIL.name,
        ],
        orderBy: '${DBColumns.CREATED_AT} DESC',
      ),
      VisitModel.fromJson,
    );

    int success = 0;
    int failed = 0;

    for (final visit in visits) {
      try {
        final res = await dio.post(
          ApiPaths.syncVisitLocation,
          data: visit.toApiJson(),
        );

        if (res.statusCode == 200) {
          await DBHelper.update(
            DBTables.VISIT_LOCATIONS,
            values: {DBColumns.SYNSTS: SyncStatus.SUCC.name},
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [visit.id],
          );

          success++;
        } else {
          await DBHelper.update(
            DBTables.VISIT_LOCATIONS,
            values: {DBColumns.SYNSTS: SyncStatus.FAIL.name},
            columns: [DBColumns.SYNSTS],
            where: '${DBColumns.ID} = ?',
            whereArgs: [visit.id],
          );

          failed++;
        }
      } catch (e, stackTrace) {
        debugPrint('Failed to sync visit location ID: ${visit.id}');
        debugPrint('$e');
        debugPrint('$stackTrace');

        await DBHelper.update(
          DBTables.VISIT_LOCATIONS,
          values: {DBColumns.SYNSTS: SyncStatus.FAIL.name},
          columns: [DBColumns.SYNSTS],
          where: '${DBColumns.ID} = ?',
          whereArgs: [visit.id],
        );

        failed++;
      }
    }

    return (success, failed);
  }
}
