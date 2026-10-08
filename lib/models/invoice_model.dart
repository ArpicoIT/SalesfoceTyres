import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';
import '../shared/enum.dart';

enum InvoiceCategory {
  nonTrading('NON_TRADING', 'Non Trading'),
  trading('TRADING', 'Trading');

  final String value;
  final String label;
  const InvoiceCategory(this.value, this.label);
}

class InvoiceModel {
  final dynamic id;
  final String sbuCode;
  final String locCode;
  final String locName;
  final String docCode;
  final String docNo;
  final String csCode;
  final String repId;
  final String txnDate;
  final num dueAmount;
  final num originalAmount;
  final num balanceAmount;
  final num setOffAmount;
  final num cashDiscount;
  final num bulkDiscount;
  final RowStatus rowSts;
  final SyncStatus synSts;
  final String createdBy;
  final DateTime createdAt;

  /// Runtime Fields
  // final num cashDiscountAmount;
  // final num bulkDiscountAmount;

  final num currentCashDiscount;
  final num currentCashDiscountAmount;
  final num currentBulkDiscount;
  final num currentBulkDiscountAmount;
  final num currentCreditAmount;
  final bool nextInvoiceUnlockedByGivenDiscount;

  const InvoiceModel({
    this.id,
    required this.sbuCode,
    required this.locCode,
    required this.locName,
    required this.docCode,
    required this.docNo,
    required this.csCode,
    required this.repId,
    required this.txnDate,
    this.dueAmount = 0,
    this.originalAmount = 0,
    this.balanceAmount = 0,
    this.setOffAmount = 0,
    this.cashDiscount = 0,
    this.bulkDiscount = 0,
    this.rowSts = RowStatus.LCK,
    this.synSts = SyncStatus.NONE,
    required this.createdBy,
    required this.createdAt,

    // this.cashDiscountAmount = 0,
    // this.bulkDiscountAmount = 0,

    this.currentCashDiscount = 0,
    this.currentCashDiscountAmount = 0,
    this.currentBulkDiscount = 0,
    this.currentBulkDiscountAmount = 0,
    this.currentCreditAmount = 0,
    this.nextInvoiceUnlockedByGivenDiscount = false,
  });

  InvoiceModel copyWith({
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
    num? cashDiscount,
    num? bulkDiscount,
    RowStatus? rowSts,
    SyncStatus? synSts,
    String? createdBy,
    DateTime? createdAt,

    num? currentCashDiscount,
    num? currentCashDiscountAmount,
    num? currentBulkDiscount,
    num? currentBulkDiscountAmount,
    num? currentCreditAmount,
    bool? nextInvoiceUnlockedByGivenDiscount,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      locName: locName ?? this.locName,
      docCode: docCode ?? this.docCode,
      docNo: docNo ?? this.docNo,
      csCode: csCode ?? this.csCode,
      repId: repId ?? this.repId,
      txnDate: txnDate ?? this.txnDate,
      dueAmount: dueAmount ?? this.dueAmount,
      originalAmount: originalAmount ?? this.originalAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      setOffAmount: setOffAmount ?? this.setOffAmount,
      cashDiscount: cashDiscount ?? this.cashDiscount,
      bulkDiscount: bulkDiscount ?? this.bulkDiscount,
      rowSts: rowSts ?? this.rowSts,
      synSts: synSts ?? this.synSts,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,

      currentCashDiscount: currentCashDiscount ?? this.currentCashDiscount,
      currentCashDiscountAmount:
          currentCashDiscountAmount ?? this.currentCashDiscountAmount,
      currentBulkDiscount: currentBulkDiscount ?? this.currentBulkDiscount,
      currentBulkDiscountAmount:
          currentBulkDiscountAmount ?? this.currentBulkDiscountAmount,
      currentCreditAmount: currentCreditAmount ?? this.currentCreditAmount,
      nextInvoiceUnlockedByGivenDiscount: nextInvoiceUnlockedByGivenDiscount ?? this.nextInvoiceUnlockedByGivenDiscount,
    );
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE] ?? '',
      locCode: json[DBColumns.LOC_CODE] ?? '',
      locName: json[DBColumns.LOC_NAME] ?? '',
      docCode: json[DBColumns.DOC_CODE] ?? '',
      docNo: json[DBColumns.DOC_NO] ?? '',
      csCode: json[DBColumns.CS_CODE] ?? '',
      repId: json[DBColumns.REP_ID] ?? '',
      txnDate: json[DBColumns.TXN_DATE] ?? '',
      dueAmount: JsonHelper.getDouble(json, [
        DBColumns.DUE_AMOUNT,
      ], defaultValue: 0)!,
      originalAmount: JsonHelper.getDouble(json, [
        DBColumns.ORIGINAL_AMOUNT,
      ], defaultValue: 0)!,
      balanceAmount: JsonHelper.getDouble(json, [
        DBColumns.BALANCE_AMOUNT,
      ], defaultValue: 0)!,
      setOffAmount: JsonHelper.getDouble(json, [
        DBColumns.SETOFF_AMOUNT,
      ], defaultValue: 0)!,
      cashDiscount: JsonHelper.getDouble(json, [
        DBColumns.CASH_DISCOUNT,
      ], defaultValue: 0)!,
      bulkDiscount: JsonHelper.getDouble(json, [
        DBColumns.BULK_DISCOUNT,
      ], defaultValue: 0)!,
      rowSts: JsonHelper.getEnum<RowStatus>(
        json,
        [DBColumns.ROWSTS],
        RowStatus.values,
        defaultValue: .LCK,
      )!,
      synSts: JsonHelper.getEnum<SyncStatus>(
        json,
        [DBColumns.SYNSTS],
        SyncStatus.values,
        defaultValue: .NONE,
      )!,
      createdBy: json[DBColumns.CREATED_BY] ?? '',
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT], defaultValue: DateTime.fromMillisecondsSinceEpoch(0))!,
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
      DBColumns.CASH_DISCOUNT: cashDiscount,
      DBColumns.BULK_DISCOUNT: bulkDiscount,
      DBColumns.ROWSTS: rowSts.name,
      DBColumns.SYNSTS: synSts.name,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt.toIso8601String(),
    };
  }

  /// Getters
  String get searchKey =>
      '$docCode$docNo$originalAmount$dueAmount$balanceAmount$setOffAmount';

  /// Default factory
  factory InvoiceModel.defaults() => InvoiceModel(
    sbuCode: '',
    locCode: '',
    locName: '',
    docCode: '',
    docNo: '',
    csCode: '',
    repId: '',
    txnDate: '',
    createdBy: '',
    createdAt: DateTime.now(),
  );
}
