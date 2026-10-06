import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';
import '../shared/enum.dart';
import '../shared/widgets/pay_mode_selection.dart';

class CollectionModel {
  final CollectionHeaderModel? header;
  final List<CollectionDetailModel>? details;

  const CollectionModel({this.header, this.details});

  CollectionModel copyWith({
    CollectionHeaderModel? header,
    List<CollectionDetailModel>? details,
  }) {
    return CollectionModel(
      header: header ?? this.header,
      details: details ?? this.details,
    );
  }

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      header: json[DBColumns.HEADER] != null
          ? CollectionHeaderModel.fromJson(
              json[DBColumns.HEADER] as Map<String, dynamic>,
            )
          : null,
      details: json[DBColumns.DETAILS] != null && (json[DBColumns.DETAILS] is List)
          ? (json[DBColumns.DETAILS] as List)
                .map(
                  (e) =>
                      CollectionDetailModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.HEADER: header?.toJson(),
      DBColumns.DETAILS: details?.map((e) => e.toJson()).toList(),
    };
  }
}

class CollectionHeaderModel {
  final dynamic id;
  final String? sbuCode;
  final String? locCode;
  final String? docCode;
  final String? docNo;
  final String? csCode;
  final PayMode? payMode;
  final String? txnDate;
  final num totalAmount;
  final String? chqNo;
  final String? chqDate;
  final String? bankCode;
  final String? branchCode;
  final String? ddRefNo;
  final String? remark;
  final num? gpsLat;
  final num? gpsLng;
  final SyncStatus synSts;
  final String? createdBy;
  final DateTime? createdAt;
  final bool verified;
  final bool deposited;
  final String? tabCode;

  const CollectionHeaderModel({
    this.id,
    this.sbuCode,
    this.locCode,
    this.docCode,
    this.docNo,
    this.csCode,
    this.payMode,
    this.txnDate,
    this.totalAmount = 0.0,
    this.chqNo,
    this.chqDate,
    this.bankCode,
    this.branchCode,
    this.ddRefNo,
    this.remark,
    this.gpsLat,
    this.gpsLng,
    this.synSts = SyncStatus.NONE,
    this.createdBy,
    this.createdAt,
    this.verified = false,
    this.deposited = false,
    this.tabCode,
  });

  CollectionHeaderModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? docCode,
    String? docNo,
    String? csCode,
    PayMode? payMode,
    String? txnDate,
    num? totalAmount,
    String? chqNo,
    String? chqDate,
    String? bankCode,
    String? branchCode,
    String? ddRefNo,
    String? remark,
    num? gpsLat,
    num? gpsLng,
    SyncStatus? synSts,
    String? createdBy,
    DateTime? createdAt,
    bool? verified,
    bool? deposited,
    String? tabCode,
  }) {
    return CollectionHeaderModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      docCode: docCode ?? this.docCode,
      docNo: docNo ?? this.docNo,
      csCode: csCode ?? this.csCode,
      payMode: payMode ?? this.payMode,
      txnDate: txnDate ?? this.txnDate,
      totalAmount: totalAmount ?? this.totalAmount,
      chqNo: chqNo ?? this.chqNo,
      chqDate: chqDate ?? this.chqDate,
      bankCode: bankCode ?? this.bankCode,
      branchCode: branchCode ?? this.branchCode,
      ddRefNo: ddRefNo ?? this.ddRefNo,
      remark: remark ?? this.remark,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      synSts: synSts ?? this.synSts,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      verified: verified ?? this.verified,
      deposited: deposited ?? this.deposited,
      tabCode: tabCode ?? this.tabCode,
    );
  }

  factory CollectionHeaderModel.fromJson(Map<String, dynamic> json) {
    return CollectionHeaderModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE],
      locCode: json[DBColumns.LOC_CODE],
      docCode: json[DBColumns.DOC_CODE],
      docNo: json[DBColumns.DOC_NO],
      csCode: json[DBColumns.CS_CODE],
      payMode: JsonHelper.getEnum<PayMode>(json, [DBColumns.PAY_MODE], PayMode.values, matcher: (e, v) => e.value == v),
      txnDate: json[DBColumns.TXN_DATE],
      totalAmount: JsonHelper.getDouble(json, [DBColumns.TOTAL_AMOUNT], defaultValue: 0)!,
      chqNo: json[DBColumns.CHQ_NO],
      chqDate: json[DBColumns.CHQ_DATE],
      bankCode: json[DBColumns.BANK_CODE],
      branchCode: json[DBColumns.BRANCH_CODE],
      ddRefNo: json[DBColumns.DD_REF_NO],
      remark: json[DBColumns.REMARK],
      gpsLat: JsonHelper.getDouble(json, [DBColumns.GPS_LAT]),
      gpsLng: JsonHelper.getDouble(json, [DBColumns.GPS_LNG]),
      synSts: JsonHelper.getEnum<SyncStatus>(json, [DBColumns.SYNSTS], SyncStatus.values, defaultValue: .NONE)!,
      createdBy: json[DBColumns.CREATED_BY],
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT]),
      verified: JsonHelper.getBool(json, [DBColumns.VERIFIED], defaultValue: false)!,
      deposited: JsonHelper.getBool(json, [DBColumns.DEPOSITED], defaultValue: false)!,
      tabCode: json[DBColumns.TAB_CODE],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.CS_CODE: csCode,
      DBColumns.PAY_MODE: payMode?.value,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.TOTAL_AMOUNT: totalAmount,
      DBColumns.CHQ_NO: chqNo,
      DBColumns.CHQ_DATE: chqDate,
      DBColumns.BANK_CODE: bankCode,
      DBColumns.BRANCH_CODE: branchCode,
      DBColumns.DD_REF_NO: ddRefNo,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
      DBColumns.VERIFIED: verified,
      DBColumns.DEPOSITED: deposited,
      DBColumns.TAB_CODE: tabCode,
    };
  }

  Map<String, dynamic> toSqlJson() {
    return {
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.CS_CODE: csCode,
      DBColumns.PAY_MODE: payMode?.value,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.TOTAL_AMOUNT: totalAmount,
      DBColumns.CHQ_NO: chqNo,
      DBColumns.CHQ_DATE: chqDate,
      DBColumns.BANK_CODE: bankCode,
      DBColumns.BRANCH_CODE: branchCode,
      DBColumns.DD_REF_NO: ddRefNo,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
      DBColumns.DEPOSITED: deposited ? 1 : 0,
      DBColumns.TAB_CODE: tabCode,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.CS_CODE: csCode,
      DBColumns.PAY_MODE: payMode?.value,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.TOTAL_AMOUNT: totalAmount,
      DBColumns.CHQ_NO: chqNo,
      DBColumns.CHQ_DATE: chqDate,
      DBColumns.BANK_CODE: bankCode,
      DBColumns.BRANCH_CODE: branchCode,
      DBColumns.DD_REF_NO: ddRefNo,
      DBColumns.REMARK: remark,
      DBColumns.GPS_LAT: gpsLat,
      DBColumns.GPS_LNG: gpsLng,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.VERIFIED: verified,
      DBColumns.DEPOSITED: deposited,
      'tb_code': tabCode,
      'creaby': createdBy,
      'creadt': createdAt?.toIso8601String(),
    };
  }
}

class CollectionDetailModel {
  final dynamic id;
  final String? sbuCode;
  final String? locCode;
  final String? docCode;
  final String? docNo;
  final int? seqNo;
  final String? recDoc;
  final String? recNo;
  final String? invDoc;
  final String? invNo;
  final num? setOffAmount;
  final num? discount;
  final String? txnDate;
  final SyncStatus synSts;
  final String? createdBy;
  final DateTime? createdAt;
  final bool verified;

  const CollectionDetailModel({
    this.id,
    this.sbuCode,
    this.locCode,
    this.docCode,
    this.docNo,
    this.seqNo,
    this.recDoc,
    this.recNo,
    this.invDoc,
    this.invNo,
    this.setOffAmount,
    this.discount,
    this.txnDate,
    this.synSts = SyncStatus.NONE,
    this.createdBy,
    this.createdAt,
    this.verified = false,
  });

  CollectionDetailModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? docCode,
    String? docNo,
    int? seqNo,
    String? recDoc,
    String? recNo,
    String? invDoc,
    String? invNo,
    num? setOffAmount,
    num? discount,
    String? txnDate,
    SyncStatus? synSts,
    String? createdBy,
    DateTime? createdAt,
    bool? verified,
  }) {
    return CollectionDetailModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      docCode: docCode ?? this.docCode,
      docNo: docNo ?? this.docNo,
      seqNo: seqNo ?? this.seqNo,
      recDoc: recDoc ?? this.recDoc,
      recNo: recNo ?? this.recNo,
      invDoc: invDoc ?? this.invDoc,
      invNo: invNo ?? this.invNo,
      setOffAmount: setOffAmount ?? this.setOffAmount,
      discount: discount ?? this.discount,
      txnDate: txnDate ?? this.txnDate,
      synSts: synSts ?? this.synSts,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      verified: verified ?? this.verified,
    );
  }

  factory CollectionDetailModel.fromJson(Map<String, dynamic> json) {
    return CollectionDetailModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE],
      locCode: json[DBColumns.LOC_CODE],
      docCode: json[DBColumns.DOC_CODE],
      docNo: json[DBColumns.DOC_NO],
      seqNo: json[DBColumns.SEQ_NO],
      recDoc: json[DBColumns.REC_DOC],
      recNo: json[DBColumns.REC_NO],
      invDoc: json[DBColumns.INV_DOC],
      invNo: json[DBColumns.INV_NO],
      setOffAmount: JsonHelper.getDouble(json, [DBColumns.SETOFF_AMOUNT], defaultValue: 0),
      discount: JsonHelper.getDouble(json, [DBColumns.DISCOUNT], defaultValue: 0),
      txnDate: json[DBColumns.TXN_DATE],
      synSts: JsonHelper.getEnum<SyncStatus>(json, [DBColumns.SYNSTS], SyncStatus.values, defaultValue: .NONE)!,
      createdBy: json[DBColumns.CREATED_BY],
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT]),
      verified: JsonHelper.getBool(json, [DBColumns.VERIFIED], defaultValue: false)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.SEQ_NO: seqNo,
      DBColumns.REC_DOC: recDoc,
      DBColumns.REC_NO: recNo,
      DBColumns.INV_DOC: invDoc,
      DBColumns.INV_NO: invNo,
      DBColumns.SETOFF_AMOUNT: setOffAmount,
      DBColumns.DISCOUNT: discount,
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
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.SEQ_NO: seqNo,
      DBColumns.REC_DOC: recDoc,
      DBColumns.REC_NO: recNo,
      DBColumns.INV_DOC: invDoc,
      DBColumns.INV_NO: invNo,
      DBColumns.SETOFF_AMOUNT: setOffAmount,
      DBColumns.DISCOUNT: discount,
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
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.SEQ_NO: seqNo,
      DBColumns.REC_DOC: recDoc,
      DBColumns.REC_NO: recNo,
      DBColumns.INV_DOC: invDoc,
      DBColumns.INV_NO: invNo,
      DBColumns.SETOFF_AMOUNT: setOffAmount,
      DBColumns.DISCOUNT: discount,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.VERIFIED: verified,
      'creaby': createdBy,
      'creadt': createdAt?.toIso8601String(),
    };
  }
}

class CollectionSetOffModel {
  final int? seq;
  final String recType;
  final String recDoc;
  final String recNo;
  final String invDoc;
  final String invNo;
  final num setOffAmount;
  final num discount;
  final DateTime? createdAt;

  CollectionSetOffModel({
    this.seq,
    required this.recType,
    required this.recDoc,
    required this.recNo,
    required this.invDoc,
    required this.invNo,
    required this.setOffAmount,
    this.discount = 0,
    this.createdAt,
  });

  CollectionSetOffModel copyWith({
    int? seq,
    String? recType,
    String? recDoc,
    String? recNo,
    String? invDoc,
    String? invNo,
    num? setOffAmount,
    num? discount,
    DateTime? createdAt,
  }) {
    return CollectionSetOffModel(
      seq: seq ?? this.seq,
      recType: recType ?? this.recType,
      recDoc: recDoc ?? this.recDoc,
      recNo: recNo ?? this.recNo,
      invDoc: invDoc ?? this.invDoc,
      invNo: invNo ?? this.invNo,
      setOffAmount: setOffAmount ?? this.setOffAmount,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CollectionSetOffModel.fromJson(Map<String, dynamic> json) {
    return CollectionSetOffModel(
      seq: json[DBColumns.SEQ_NO],
      recType: json[DBColumns.REC_TYPE],
      recDoc: json[DBColumns.REC_DOC],
      recNo: json[DBColumns.REC_NO],
      invDoc: json[DBColumns.INV_DOC],
      invNo: json[DBColumns.INV_NO],
      setOffAmount: JsonHelper.getDouble(json, [DBColumns.SETOFF_AMOUNT], defaultValue: 0)!,
      discount: JsonHelper.getDouble(json, [DBColumns.DISCOUNT], defaultValue: 0)!,
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.SEQ_NO: seq,
      DBColumns.REC_TYPE: recType,
      DBColumns.REC_DOC: recDoc,
      DBColumns.REC_NO: recNo,
      DBColumns.INV_DOC: invDoc,
      DBColumns.INV_NO: invNo,
      DBColumns.SETOFF_AMOUNT: setOffAmount,
      DBColumns.DISCOUNT: discount,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
    };
  }

  String get searchKey =>
      "$recDoc$recNo$invDoc$invNo$setOffAmount$discount";

}
