import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../helpers/json_helper.dart';
import '../../helpers/string_helper.dart';
import '../../models/bank_model.dart';
import '../../models/credit_note_model.dart';
import '../../models/customer_model.dart';
import '../../models/download_model.dart';
import '../../models/invoice_model.dart';
import '../../models/system_file_model.dart';
import '../../repositories/api/download_api_repository.dart';
import '../../services/database/db_constants.dart';
import '../../services/database/db_tables.dart';
import '../../services/database/repositories/download_db_repository.dart';
import '../../shared/components/app/app_dialog.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key});

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  final _mainScrollController = ScrollController();
  final _cancelToken = CancelToken();

  bool _isAllDownloading = false;
  bool get isDownloading =>
      downloadOptions.any((e) => e.downloading) || _isAllDownloading;

  late List<DownloadOption> downloadOptions = [
    DownloadOption(
      type: DBConstants.DOWN_SUSTEM_FILES,
      table: DBTables.SYSTEM_FILES,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => SystemFileModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.system_update_alt,
    ),
    DownloadOption(
      type: DBConstants.DOWN_CUSTOMERS,
      table: DBTables.CUSTOMERS,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => CustomerModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.people_alt,
    ),
    DownloadOption(
      type: DBConstants.DOWN_INVOICES,
      table: DBTables.INVOICES,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => InvoiceModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.receipt,
    ),
    DownloadOption(
      type: DBConstants.DOWN_CREDIT_NOTES,
      table: DBTables.CREDIT_NOTES,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => CreditNoteModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.note_add,
    ),
    DownloadOption(
      type: DBConstants.DOWN_BANKS,
      table: DBTables.BANKS,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => BankModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.account_balance_outlined,
    ),
    DownloadOption(
      type: DBConstants.DOWN_BANKS_BRANCHES,
      table: DBTables.BANKS_BRANCHES,
      data: (list) => JsonHelper.jsonListToSqlJsonList(
        list,
        (json) => BankBranchModel.fromJson(json),
        (model) => model.toJson(),
      ),
      icon: Icons.account_balance,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // await AIAMStorage.instance.setAccessToken(TEST_TOKEN);
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _loadDownloadMetadata();
    if (mounted) setState(() {});
  }

  Future<void> _loadDownloadMetadata([int index = -1]) async {
    final snackBar = AppSnackBar.instance;

    if (index < -1 || index >= downloadOptions.length) {
      return;
    }

    try {
      if (index == -1) {
        for (int i = 0; i < downloadOptions.length; i++) {
          await _loadMetadataForOption(i);
        }
      } else {
        await _loadMetadataForOption(index);
      }
    } catch (e) {
      snackBar.error(
        title: 'Download Information',
        message: 'Unable to load download information.',
      );
    }
  }

  Future<void> _loadMetadataForOption(int index) async {
    final option = downloadOptions[index];

    try {
      final metadata = await DownloadDbRepository.getDownloadMetadata(
        option.table,
      );

      if (!mounted) {
        return;
      }

      downloadOptions[index] = option.copyWith(metadata: metadata);
    } catch (e) {
      // Keep the existing metadata if this particular
      // table cannot be read.
      debugPrint(
        'Failed to load download metadata '
        'for ${option.type}: $e',
      );
    }
  }


  Future<bool> _downloadOption(
    UserModel currentUser,
    DownloadOption option,
  ) async {
    final snackBar = AppSnackBar.instance;

    int offset = 0;
    int totalDownloaded = 0;

    try {
      await DownloadDbRepository.clearDownloadData([option.table]);

      while (true) {
        final response = await DownloadApiRepository.download(
          currentUser,
          downloadType: option.type,
          limit: AppConfig.maxDownloadPageSize,
          offset: offset,
          cancelToken: _cancelToken
        );

        if (!response.success) {
          snackBar.error(
            title: StringHelper.formatLabel(option.type),
            message: response.message,
          );
          return false;
        }

        final records = response.data ?? [];

        // No more records.
        if (records.isEmpty) {
          break;
        }

        final data = option.data(records);

        if (data.isNotEmpty) {
          await DownloadDbRepository.insertDownloadData(option.table, data);
          totalDownloaded += data.length;
        }

        // API offset is page/index based:
        // 0 → 1 → 2 → 3 → ...
        offset++;

        // Last page.
        if (records.length < AppConfig.maxDownloadPageSize) {
          break;
        }
      }

      // debugPrint(
      //   "Loop finished with cycle: $offset, totalDownloaded: $totalDownloaded",
      // );

      snackBar.success(
        title: StringHelper.formatLabel(option.type),
        message: '$totalDownloaded records downloaded successfully.',
      );

      return true;
    } catch (e) {
      snackBar.error(
        title: StringHelper.formatLabel(option.type),
        message: 'Unable to complete the download. ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> _clearDownloads() async {
    await DownloadDbRepository.clearDownloadData(
      downloadOptions.map((e) => e.table).toList(),
    );
    await _loadDownloadMetadata();
    return true;
  }

  Future<bool> _cancelDownloading() async {
    _cancelToken.cancel();
    await _loadDownloadMetadata();
    if(mounted) setState(() {});
    return true;
  }

  void onDownload(int index) async {
    final snackBar = AppSnackBar.instance;

    try {
      final currentUser = await IAMService.instance.currentUser();

      setState(() {
        downloadOptions[index] = downloadOptions[index].copyWith(
          downloading: true,
        );
      });

      await _downloadOption(currentUser, downloadOptions[index]);

      await _loadDownloadMetadata(index);
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          downloadOptions[index] = downloadOptions[index].copyWith(
            downloading: false,
          );
        });
      }
    }
  }

  void onDownloadAll() async {
    final snackBar = AppSnackBar.instance;

    try {
      final currentUser = await IAMService.instance.currentUser();

      setState(() {
        _isAllDownloading = true;
        downloadOptions = downloadOptions
            .map((e) => e.copyWith(downloading: true))
            .toList();
      });

      for (int index = 0; index < downloadOptions.length; index++) {
        final success = await _downloadOption(
          currentUser,
          downloadOptions[index],
        );

        // Stop on authorization failure if desired or if not mounted.
        if (!success) break;

        await _loadDownloadMetadata(index);

        if (!mounted) return;

        setState(() {
          downloadOptions[index] = downloadOptions[index].copyWith(
            downloading: false,
          );
        });

        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isAllDownloading = false;
          downloadOptions = downloadOptions
              .map((e) => e.copyWith(downloading: false))
              .toList();
        });
      }
    }
  }

  void onClearAll() async {
    final snackBar = AppSnackBar.instance;

    final confirmed = await context.showConfirmDialog(
      title: 'Clear Downloads?',
      message:
        'This will remove all downloaded data from this device. '
        'You can download the data again later. Do you want to continue?',
      confirmText: 'Clear Downloads',
      cancelText: 'Cancel',
      confirmColor: Theme.of(context).colorScheme.error
    );

    if (confirmed != true) return;

    try {
      await _clearDownloads();
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDownloading,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !isDownloading) {
          return;
        }

        final shouldLeave = await context.showConfirmDialog(
            title: 'Download in Progress',
            message: 'A download is currently in progress. '
                'If you leave this page, the download will be cancelled. '
                'Are you sure you want to leave?',
            confirmText: 'Leave & Cancel',
            cancelText: 'Stay',
            confirmColor: Theme.of(context).colorScheme.error
        );

        if (shouldLeave != true) return;

        await _cancelDownloading();

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },

      child: AppScaffold(
        title: 'Downloads',
        scrollController: _mainScrollController,
        defaultPadding: true,
        scrollableBody: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: downloadOptions.length,
          separatorBuilder: (BuildContext context, int i) =>
              SizedBox(height: 16),
          itemBuilder: (ctx, i) {
            final option = downloadOptions[i];

            return buildDownloadCard(
              i,
              option: option,
              onTap: onDownload,
              onLongPress: (idx) {},
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const .all(16),
          child: Row(
            spacing: 16,
            children: [
              Expanded(child: AppButton.of(context).cancel(
                onPressed: onClearAll,
                label: 'Clear All',
                enabled: !isDownloading,
              )),
              Expanded(child: AppButton.of(context).download(
                label: 'Download All',
                onPressed: onDownloadAll,
                enabled: !isDownloading,
                loading: _isAllDownloading,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDownloadCard(
    int index, {
    required DownloadOption option,
    required Function(int) onTap,
    required Function(int) onLongPress,
  }) {
    final cs = Theme.of(context).colorScheme;

    final date = option.metadata?.lastDownloadAt;
    final lastDownloadAtStr = date == null
        ? '000-00-00'
        : DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    final totalStr = (option.metadata?.count ?? 0).toString();

    return ListTile(
      tileColor: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: .circular(12),
        side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
      ),
      // minTileHeight: 72,
      minVerticalPadding: 12,
      title: Text(
        StringHelper.formatLabel(option.type),
        style: TextStyle(fontWeight: .bold),
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Last Download: $lastDownloadAtStr',
            style: TextStyle(
              color: cs.onSurfaceVariant.withAlpha(400),
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: option.downloading
          ? SizedBox.square(dimension: 24, child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: .circular(6),
              ),
              child: Text(
                totalStr,
                style: TextStyle(fontSize: 14, fontWeight: .bold),
              ),
            ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cs.primary.withAlpha(50),
        child: Icon(option.icon),
      ),
      onTap: () => onTap(index),
      onLongPress: () => onLongPress(index),
      enabled: !(_isAllDownloading || option.downloading),
    );
  }

  @override
  void dispose() {
    if(!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    super.dispose();
  }
}

