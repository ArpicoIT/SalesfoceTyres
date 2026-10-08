import '../helpers/json_helper.dart';
import '../services/database/db_columns.dart';

class SystemFileModel {
  final dynamic id;
  final String sbuCode;
  final String locCode;
  final String userId;
  final String paraCode;
  final String paraName;
  final String comment;
  final String createdBy;
  final DateTime createdAt;

  const SystemFileModel({
    this.id,
    required this.sbuCode,
    required this.locCode,
    required this.userId,
    required this.paraCode,
    required this.paraName,
    required this.comment,
    required this.createdBy,
    required this.createdAt,
  });

  SystemFileModel copyWith({
    dynamic id,
    String? sbuCode,
    String? locCode,
    String? userId,
    String? paraCode,
    String? paraName,
    String? comment,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return SystemFileModel(
      id: id ?? this.id,
      sbuCode: sbuCode ?? this.sbuCode,
      locCode: locCode ?? this.locCode,
      userId: userId ?? this.userId,
      paraCode: paraCode ?? this.paraCode,
      paraName: paraName ?? this.paraName,
      comment: comment ?? this.comment,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SystemFileModel.fromJson(Map<String, dynamic> json) {
    return SystemFileModel(
      id: json[DBColumns.ID],
      sbuCode: json[DBColumns.SBU_CODE] ?? '',
      locCode: json[DBColumns.LOC_CODE] ?? '',
      userId: JsonHelper.getValue<String>(json, [DBColumns.USER_ID, 'userid'], defaultValue: '')!,
      paraCode: JsonHelper.getValue<String>(json, [
        DBColumns.PARA_CODE,
        'prgcod',
      ], defaultValue: '')!,
      paraName: JsonHelper.getValue<String>(json, [
        DBColumns.PARA_NAME,
        'prgnam',
      ], defaultValue: '')!,
      comment: JsonHelper.getValue<String>(json, [DBColumns.COMMENT, 'coment'], defaultValue: '')!,
      createdBy: json[DBColumns.CREATED_BY] ?? '',
      createdAt: JsonHelper.getDateTime(json, [DBColumns.CREATED_AT], defaultValue: DateTime.fromMillisecondsSinceEpoch(0))!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DBColumns.ID: id,
      DBColumns.SBU_CODE: sbuCode,
      DBColumns.LOC_CODE: locCode,
      DBColumns.USER_ID: userId,
      DBColumns.PARA_CODE: paraCode,
      DBColumns.PARA_NAME: paraName,
      DBColumns.COMMENT: comment,
      DBColumns.CREATED_BY: createdBy,
      DBColumns.CREATED_AT: createdAt.toIso8601String(),
    };
  }
}
