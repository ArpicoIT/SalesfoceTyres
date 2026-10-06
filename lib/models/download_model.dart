import 'package:flutter/material.dart';

class DownloadOption {
  final String type;
  final String table;
  final List<Map<String, dynamic>> Function(List<Map<String, dynamic>> list) data;
  final IconData icon;
  final bool downloading;
  final DownloadMetadata? metadata;

  DownloadOption({
    required this.type,
    required this.table,
    required this.data,
    required this.icon,
    this.downloading = false,
    this.metadata,
  });

  DownloadOption copyWith({
    String? type,
    String? table,
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>> list)? data,
    IconData? icon,
    bool? downloading,
    DownloadMetadata? metadata,
  }) {
    return DownloadOption(
      type: type ?? this.type,
      table: table ?? this.table,
      data: data ?? this.data,
      icon: icon ?? this.icon,
      downloading: downloading ?? this.downloading,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Better default date (Unix epoch start)
  static String get defaultDate =>
      DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
}

class DownloadMetadata {
  final String table;
  final int count;
  final DateTime? lastDownloadAt;

  const DownloadMetadata({
    required this.table,
    required this.count,
    this.lastDownloadAt,
  });
}