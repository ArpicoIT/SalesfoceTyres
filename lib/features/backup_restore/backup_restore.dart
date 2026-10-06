import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arpicoiam/iam.dart';
import 'package:intl/intl.dart';

import '../../services/database/backup/db_backup_service.dart';
import '../../shared/components/app/app_alert.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';

class BackupRestoreView extends StatefulWidget {
  const BackupRestoreView({super.key});

  @override
  State<BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<BackupRestoreView> {
  final DBBackupService _backupService = DBBackupService();

  List<FileSystemEntity> _backups = [];
  bool _isLoading = false;
  bool _isBackupInProgress = false;
  bool _isRestoreInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      _backups = await _backupService.getBackups();
    } catch (e) {
      debugPrint('Error loading backups: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _createBackup() async {
    final snackBar = AppSnackBar.instance;

    setState(() => _isBackupInProgress = true);
    try {
      await _backupService.createBackup();
      if (mounted) {
        snackBar.success(message: 'Backup created successfully');
        _loadBackups();
      }
    } catch (e) {
      snackBar.error(message: 'Backup failed: $e');
    } finally {
      if (mounted) setState(() => _isBackupInProgress = false);
    }
  }

  Future<void> _restoreBackup(File backupFile) async {
    final snackBar = AppSnackBar.instance;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(
          'This will replace your current database with this backup. '
          'All unsaved data will be lost. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoreInProgress = true);
    try {
      await _backupService.restore(backupFile);
      if (mounted) {
        snackBar.success(message: 'Database restored successfully');
        _loadBackups();
      }
    } catch (e) {
      snackBar.error(message: 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isRestoreInProgress = false);
    }
  }

  Future<void> _deleteBackup(File file) async {
    final snackBar = AppSnackBar.instance;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _backupService.deleteBackup(file);
      if (mounted) {
        snackBar.success(message: 'Backup deleted');
        _loadBackups();
      }
    } catch (e) {
      snackBar.error(message: 'Delete failed: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Backup & Restore',
      defaultPadding: true,
      scrollableBody: IgnorePointer(
        ignoring: _isBackupInProgress || _isRestoreInProgress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBackupSection(cs),
            const SizedBox(height: 16),
            _buildRestoreSection(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Backup Database',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create a backup of your current database. This saves all your '
              'data including customers, collections, visits, and tasks.',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton.of(context).filled(
                onPressed: _createBackup,
                icon: Icons.add,
                label: 'Create Backup',
                loadingLabel: 'Creating Backup...',
                loading: _isBackupInProgress,
                enabled: !_isBackupInProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSection(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_download, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Restore Database',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppAlert.warning(message: 'Restoring will replace your current database.'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Backups',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadBackups,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_backups.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_off,
                        size: 48,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No backups found',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._backups.map((entity) {
                if (entity is! File) return const SizedBox.shrink();
                final stat = entity.statSync();
                final fileName = entity.path.split(Platform.pathSeparator).last;
                final size = _formatFileSize(stat.size);
                final modified = DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(stat.modified);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: cs.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.description,
                      color: cs.primary,
                    ),
                    title: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '$size \u2022 $modified',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'restore') {
                          _restoreBackup(entity);
                        } else if (value == 'delete') {
                          _deleteBackup(entity);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              Icon(Icons.restore, size: 18),
                              SizedBox(width: 8),
                              Text('Restore'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 18,
                                color: cs.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: cs.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
