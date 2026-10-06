
import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';
import '../shared/enum.dart';
import 'customer_model.dart';

class VisitItem {
  final CustomerModel? customer;
  final VisitModel? visit;

  const VisitItem({
    this.customer,
    this.visit,
  });

  factory VisitItem.fromJson(Map<String, dynamic> json) {
    return VisitItem(
      customer: CustomerModel.fromJson(json['customer']),
      visit: VisitModel.fromJson(json['visit']),
    );
  }

  VisitItem copyWith({
    CustomerModel? customer,
    VisitModel? visit,
  }) {
    return VisitItem(
      customer: customer ?? this.customer,
      visit: visit ?? this.visit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer?.toJson(),
      'visit': visit?.toJson(),
    };
  }
}

class VisitModel {
  final dynamic id;
  final String? sbuCode;
  final String? locCode;
  final String? csCode;
  final String? remark;
  final num? gpsLat;
  final num? gpsLng;
  final String? tabCode;
  final String? txnDate;
  final SyncStatus synSts;
  final String? createdBy;
  final DateTime? createdAt;

  const VisitModel({
    this.id,
    this.sbuCode,
    this.locCode,
    this.csCode,
    this.remark,
    this.gpsLat,
    this.gpsLng,
    this.tabCode,
    this.txnDate,
    this.synSts = SyncStatus.NONE,
    this.createdBy,
    this.createdAt,
  });

  VisitModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? csCode,
    String? remark,
    num? gpsLat,
    num? gpsLng,
    String? tabCode,
    String? txnDate,
    SyncStatus? synSts,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return VisitModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      csCode: csCode ?? this.csCode,
      remark: remark ?? this.remark,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      tabCode: tabCode ?? this.tabCode,
      txnDate: txnDate ?? this.txnDate,
      synSts: synSts ?? this.synSts,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE],
      locCode: json[DBColumns.LOC_CODE],
      csCode: json[DBColumns.CS_CODE],
      remark: json[DBColumns.REMARK],
      gpsLat: JsonHelper.getDouble(json, [DBColumns.GPS_LAT, 'gploca']),
      gpsLng: JsonHelper.getDouble(json, [DBColumns.GPS_LNG, 'gplong']),
      tabCode: JsonHelper.getValue<String>(json, [
        DBColumns.TAB_CODE,
        'tbcode',
      ]),
      txnDate: json[DBColumns.TXN_DATE],
      synSts: JsonHelper.getEnum<SyncStatus>(
        json,
        [DBColumns.SYNSTS],
        SyncStatus.values,
        defaultValue: .NONE,
      )!,
      createdBy: JsonHelper.getValue<String>(json, [
        DBColumns.CREATED_BY,
        'creaby',
      ]),
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT, 'creadt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.CS_CODE: csCode,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.TAB_CODE: tabCode,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSqlJson() {
    return {
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.CS_CODE: csCode,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.TAB_CODE: tabCode,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.CS_CODE: csCode,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.TAB_CODE: tabCode,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
      'tbcode': tabCode,
      'gploca': gpsLat,
      'gplong': gpsLng,
      'creaby': createdBy,
      'creadt': createdAt?.toIso8601String(),
    };
  }
}
