import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';

class CustomerModel {
  final dynamic id;
  final String? sbuCode;
  final String? csCode;
  final String? csName;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? repId;
  final String? mobile;
  final num creditLimit;
  final num creditBalance;
  final String? createdBy;
  final DateTime? createdAt;

  const CustomerModel({
    this.id,
    this.sbuCode,
    this.csCode,
    this.csName,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.repId,
    this.mobile,
    this.creditLimit = 0,
    this.creditBalance = 0,
    this.createdBy,
    this.createdAt,
  });

  CustomerModel copyWith({
    dynamic id,
    String? sbuCode,
    String? csCode,
    String? csName,
    String? address1,
    String? address2,
    String? address3,
    String? city,
    String? repId,
    String? mobile,
    num? creditLimit,
    num? creditBalance,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      csCode: csCode ?? this.csCode,
      csName: csName ?? this.csName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      city: city ?? this.city,
      repId: repId ?? this.repId,
      mobile: mobile ?? this.mobile,
      creditLimit: creditLimit ?? this.creditLimit,
      creditBalance: creditBalance ?? this.creditBalance,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE],
      csCode: json[DBColumns.CS_CODE],
      csName: JsonHelper.getValue<String>(json, [DBColumns.CS_NAME, 'name']),
      address1: JsonHelper.getValue<String>(json, [DBColumns.ADDRESS_1, 'add1']),
      address2: JsonHelper.getValue<String>(json, [DBColumns.ADDRESS_2, 'add2']),
      address3: JsonHelper.getValue<String>(json, [DBColumns.ADDRESS_3, 'add3']),
      city: json[DBColumns.CITY],
      repId: json[DBColumns.REP_ID],
      mobile: json[DBColumns.MOBILE],
      creditLimit: JsonHelper.getDouble(json, [DBColumns.CREDIT_LIMIT], defaultValue: 0)!,
      creditBalance: JsonHelper.getDouble(json, [DBColumns.CREDIT_BALANCE], defaultValue: 0)!,
      createdBy: json[DBColumns.CREATED_BY],
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.CS_CODE: csCode,
      DBColumns.CS_NAME: csName,
      DBColumns.ADDRESS_1: address1,
      DBColumns.ADDRESS_2: address2,
      DBColumns.ADDRESS_3: address3,
      DBColumns.CITY: city,
      DBColumns.REP_ID: repId,
      DBColumns.MOBILE: mobile,
      DBColumns.CREDIT_LIMIT: creditLimit,
      DBColumns.CREDIT_BALANCE: creditBalance,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt?.toIso8601String(),
    };
  }

  String get searchKey => "$csCode$csName";
  String get displayText => "$csCode - $csName";
}
