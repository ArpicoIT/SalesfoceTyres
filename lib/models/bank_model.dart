import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';

class BankModel {
  final dynamic id;
  final String sbuCode;
  final String locCode;
  final String bankCode;
  final String bankName;
  final String createdBy;
  final DateTime createdAt;

  const BankModel({
    required this.id,
    required this.sbuCode,
    required this.locCode,
    required this.bankCode,
    required this.bankName,
    required this.createdBy,
    required this.createdAt,
  });

  BankModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? bankCode,
    String? bankName,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return BankModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE] ?? '',
      locCode: json[DBColumns.LOC_CODE] ?? '',
      bankCode: json[DBColumns.BANK_CODE] ?? '',
      bankName: json[DBColumns.BANK_NAME] ?? '',
      createdBy: json[DBColumns.CREATED_BY] ?? '',
      createdAt: JsonHelper.getDateTime(json, [
        DBColumns.CREATED_AT,
      ], defaultValue: DateTime.fromMillisecondsSinceEpoch(0))!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.BANK_CODE: bankCode,
      DBColumns.BANK_NAME: bankName,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt.toIso8601String(),
    };
  }

  String get searchKey => "$bankCode$bankName";
  String get displayText => bankName;

  @override
  String toString() {
    return 'BankModel('
        'id: $id, '
        'sbuCode: $sbuCode, '
        'locCode: $locCode, '
        'bankCode: $bankCode, '
        'bankName: $bankName, '
        'createdBy: $createdBy, '
        'createdAt: $createdAt, '
        ')';
  }
}

class BankBranchModel {
  final dynamic id;
  final String sbuCode;
  final String locCode;
  final String bankCode;
  final String branchCode;
  final String branchName;
  final String createdBy;
  final DateTime createdAt;

  const BankBranchModel({
    this.id,
    required this.sbuCode,
    required this.locCode,
    required this.bankCode,
    required this.branchCode,
    required this.branchName,
    required this.createdBy,
    required this.createdAt,
  });

  BankBranchModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? bankCode,
    String? branchCode,
    String? branchName,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return BankBranchModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: sbuCode ?? this.locCode,
      bankCode: bankCode ?? this.bankCode,
      branchCode: branchCode ?? this.branchCode,
      branchName: branchName ?? this.branchName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BankBranchModel.fromJson(Map<String, dynamic> json) {
    return BankBranchModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE] ?? '',
      locCode: json[DBColumns.LOC_CODE] ?? '',
      bankCode: json[DBColumns.BANK_CODE] ?? '',
      branchCode: json[DBColumns.BRANCH_CODE] ?? '',
      branchName: json[DBColumns.BRANCH_NAME] ?? '',
      createdBy: json[DBColumns.CREATED_BY] ?? '',
      createdAt: JsonHelper.getDateTime(json, [
        DBColumns.CREATED_AT,
      ], defaultValue: DateTime.fromMillisecondsSinceEpoch(0))!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.BANK_CODE: bankCode,
      DBColumns.BRANCH_CODE: branchCode,
      DBColumns.BRANCH_NAME: branchName,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt.toIso8601String(),
    };
  }

  String get searchKey => "$branchCode$branchName";
  String get displayText => branchName;

  factory BankBranchModel.defaults(String bankCode) {
    return BankBranchModel(
      id: -1,
      sbuCode: '',
      bankCode: bankCode,
      locCode: '',
      branchCode: '00',
      branchName: 'DEFAULT',
      createdBy: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BranchModel('
        'id: $id, '
        'sbuCode: $sbuCode, '
        'bankCode: $bankCode, '
        'locCode: $locCode, '
        'branchCode: $branchCode, '
        'branchName: $branchName, '
        'createdBy: $createdBy, '
        'createdAt: $createdAt, '
        ')';
  }
}
