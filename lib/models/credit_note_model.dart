import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';
import '../shared/enum.dart';

class CreditNoteModel {
  final dynamic id;
  final String? sbuCode;
  final String? locCode;
  final String? locName;
  final String? docCode;
  final String? docNo;
  final String? csCode;
  final String? repId;
  final String? txnDate;
  final num dueAmount;
  final num originalAmount;
  final num balanceAmount;
  final num setOffAmount;
  final RowStatus rowSts;
  final SyncStatus synSts;
  final String? createdBy;
  final DateTime? createdAt;

  const CreditNoteModel({
    this.id,
    this.sbuCode,
    this.locCode,
    this.locName,
    this.docCode,
    this.docNo,
    this.csCode,
    this.repId,
    this.txnDate,
    this.dueAmount = 0,
    this.originalAmount = 0,
    this.balanceAmount = 0,
    this.setOffAmount = 0,
    this.rowSts = RowStatus.ENA,
    this.synSts = SyncStatus.NONE,
    this.createdBy,
    this.createdAt,
  });

  CreditNoteModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? locName,
    String? docCode,
    String? docNo,
    String? csCode,
    String? repId,
    String? txnDate,
    num? dueAmount,
    num? originalAmount,
    num? balanceAmount,
    num? setOffAmount,
    RowStatus? rowSts,
    SyncStatus? synSts,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CreditNoteModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      locName: locName ?? this.locName,
      docCode: docCode ?? this.docCode,
      docNo: docNo ?? this.docNo,
      csCode: csCode ?? this.csCode,
      repId: repId ?? this.repId,
      txnDate: txnDate ?? this.txnDate,
      originalAmount: originalAmount ?? this.originalAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      setOffAmount: setOffAmount ?? this.setOffAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      rowSts: rowSts ?? this.rowSts,
      synSts: synSts ?? this.synSts,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CreditNoteModel.fromJson(Map<String, dynamic> json) {
    return CreditNoteModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE],
      locCode: json[DBColumns.LOC_CODE],
      locName: json[DBColumns.LOC_NAME],
      docCode: json[DBColumns.DOC_CODE],
      docNo: json[DBColumns.DOC_NO],
      csCode: json[DBColumns.CS_CODE],
      repId: json[DBColumns.REP_ID],
      txnDate: json[DBColumns.TXN_DATE],
      dueAmount: JsonHelper.getDouble(json, [DBColumns.DUE_AMOUNT], defaultValue: 0)!,
      originalAmount: JsonHelper.getDouble(json, [DBColumns.ORIGINAL_AMOUNT, DBColumns.DUE_AMOUNT], defaultValue: 0)!, /// Remove [DUE_AMOUNT] if api response has [ORIGINAL_AMOUNT] field in future
      balanceAmount: JsonHelper.getDouble(json, [DBColumns.BALANCE_AMOUNT], defaultValue: 0)!,
      setOffAmount: JsonHelper.getDouble(json, [DBColumns.SETOFF_AMOUNT], defaultValue: 0)!,
      rowSts: JsonHelper.getEnum<RowStatus>(json, [DBColumns.ROWSTS], RowStatus.values, defaultValue: .ENA)!,
      synSts: JsonHelper.getEnum<SyncStatus>(json, [DBColumns.SYNSTS], SyncStatus.values, defaultValue: .NONE)!,
      createdBy: json[DBColumns.CREATED_BY],
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.LOC_NAME: locName,
      DBColumns.DOC_CODE: docCode,
      DBColumns.DOC_NO: docNo,
      DBColumns.CS_CODE: csCode,
      DBColumns.REP_ID: repId,
      DBColumns.TXN_DATE: txnDate,
      DBColumns.DUE_AMOUNT: dueAmount,
      DBColumns.ORIGINAL_AMOUNT: originalAmount,
      DBColumns.BALANCE_AMOUNT: balanceAmount,
      DBColumns.SETOFF_AMOUNT: setOffAmount,
      DBColumns.ROWSTS: rowSts.name,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
    };
  }

  /// Getters
  String get searchKey => "$docCode$docNo$txnDate$originalAmount$dueAmount$balanceAmount$setOffAmount";

}