import 'package:flutter/material.dart';

import '../../services/sync/cloud_sync.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';

class SyncView extends StatefulWidget {
  const SyncView({super.key});

  @override
  State<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends State<SyncView> {
  final _mainScrollController = ScrollController();

  bool _isAllSyncing = false;
  bool _isReceiptsSyncing = false;
  bool _isVisitsSyncing = false;
  String _syncLog = '';

  bool get _isSyncing =>
      _isAllSyncing || _isReceiptsSyncing || _isVisitsSyncing;

  void _appendLog(String message) {
    setState(() {
      _syncLog += '$message\n';
    });
    // Auto-scroll to bottom
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.hasClients) {
    //     _scrollController.animateTo(
    //       _scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });
  }

  Future<void> _syncAll() async {
    if (_isAllSyncing) return;

    setState(() {
      _isAllSyncing = true;
      _syncLog = '';
    });

    _appendLog('Starting sync process...');
    _appendLog('');

    try {
      final results = await CloudSync.syncAll();

      for (final entry in results.entries) {
        final (success, failed) = entry.value;
        if (failed == -1) {
          _appendLog('[FAILED] ${entry.key} - Error occurred');
        } else if (failed == 0 && success == 0) {
          _appendLog('[SKIP] ${entry.key} - Nothing to sync');
        } else {
          _appendLog('[OK] ${entry.key} - $success synced, $failed failed');
        }
      }

      _appendLog('');
      _appendLog('Sync process completed.');
    } catch (e) {
      _appendLog('Sync failed: $e');
    } finally {
      if (mounted) setState(() => _isAllSyncing = false);
    }
  }

  Future<void> _syncReceipts() async {
    if (_isReceiptsSyncing) return;

    setState(() {
      _isReceiptsSyncing = true;
      _syncLog = '';
    });

    _appendLog('Syncing receipts...');

    try {
      final results = await CloudSync.syncReceipts();

      for (final entry in results.entries) {
        final (success, failed) = entry.value;
        if (failed == -1) {
          _appendLog('[FAILED] ${entry.key} - Error occurred');
        } else if (failed == 0 && success == 0) {
          _appendLog('[SKIP] ${entry.key} - Nothing to sync');
        } else {
          _appendLog('[OK] ${entry.key} - $success synced, $failed failed');
        }
      }

      _appendLog('');
      _appendLog('Receipt sync completed.');
    } catch (e) {
      _appendLog('Receipt sync failed: $e');
    } finally {
      if (mounted) setState(() => _isReceiptsSyncing = false);
    }
  }

  Future<void> _syncVisitLocations() async {
    if (_isVisitsSyncing) return;

    setState(() {
      _isVisitsSyncing = true;
      _syncLog = '';
    });

    _appendLog('Syncing visit locations...');

    try {
      final (success, failed) = await CloudSync.syncVisitLocations();

      if (failed == 0 && success == 0) {
        _appendLog('[SKIP] Visit Locations - Nothing to sync');
      } else {
        _appendLog('[OK] Visit Locations - $success synced, $failed failed');
      }

      _appendLog('');
      _appendLog('Visit location sync completed.');
    } catch (e) {
      _appendLog('Visit location sync failed: $e');
    } finally {
      if (mounted) setState(() => _isVisitsSyncing = false);
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Sync Data',
      scrollController: _mainScrollController,
      defaultPadding: true,
      scrollableBody: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          Card(
            margin: .zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isSyncing ? Icons.sync : Icons.sync_disabled,
                    color: _isSyncing
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSyncing ? 'Sync in progress...' : 'Ready to sync',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSyncing
                            ? 'Please wait while data is being synchronized'
                            : 'All data is up-to-date',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 16),

          // Sync buttons
          Text(
            'Sync Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AppButton.of(context).filled(
            onPressed: _syncAll,
            icon: Icons.sync,
            label: 'Sync All Data',
            loadingLabel: 'Syncing...',
            loading: _isAllSyncing,
            enabled: !_isAllSyncing,
          ),
          const SizedBox(height: 12),
          AppButton.of(context).outlined(
            onPressed: _syncReceipts,
            icon: Icons.receipt_long,
            label: 'Sync Receipts',
            loadingLabel: 'Syncing...',
            loading: _isReceiptsSyncing,
            enabled: !_isReceiptsSyncing,
          ),
          const SizedBox(height: 12),
          AppButton.of(context).outlined(
            onPressed: _syncVisitLocations,
            icon: Icons.location_on,
            label: 'Sync Visit Locations',
            loadingLabel: 'Syncing...',
            loading: _isVisitsSyncing,
            enabled: !_isVisitsSyncing,
          ),

          const SizedBox(height: 24),

          // Sync log
          Text(
            'Sync Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: SingleChildScrollView(
              child: Text(
                _syncLog.isEmpty
                    ? 'No sync activity yet.\n\nPerform a sync operation to see the log here.'
                    : _syncLog,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
