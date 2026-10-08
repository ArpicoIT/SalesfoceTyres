import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arpicoiam/iam.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../helpers/number_helper.dart';
import '../../models/customer_model.dart';
import '../../services/database/db_columns.dart';
import '../../services/database/db_helper.dart';
import '../../services/database/repositories/collection_db_repository.dart';
import '../../services/image_service.dart';
import '../../shared/components/app/app_alert.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';
import '../../models/bank_model.dart';
import '../../models/collection_model.dart';
import '../../repositories/api/upload_api_repository.dart';
import '../../services/database/db_tables.dart';
import '../../shared/components/form/async_search_picker.dart';
import '../../helpers/date_time_helper.dart';
import '../../services/database/repositories/bank_db_repository.dart';
import '../../shared/components/form/form_widgets.dart';
import '../../shared/components/group/date_group_tab.dart';
import '../../shared/components/image/fullscreen_image_viewer.dart';

class DepositItem {
  final List<File> images;
  final BankModel? bank;
  final CollectionHeaderModel? collection;
  final CustomerModel? customer;
  final bool uploading;
  final bool uploaded;

  const DepositItem({
    this.images = const [],
    this.bank,
    this.collection,
    this.customer,
    this.uploading = false,
    this.uploaded = false,
  });

  DepositItem copyWith({
    List<File>? images,
    BankModel? bank,
    CollectionHeaderModel? collection,
    CustomerModel? customer,
    bool? uploading,
    bool? uploaded,
  }) {
    return DepositItem(
      images: images ?? this.images,
      bank: bank ?? this.bank,
      collection: collection ?? this.collection,
      customer: customer ?? this.customer,
      uploading: uploading ?? this.uploading,
      uploaded: uploaded ?? this.uploaded,
    );
  }
}

class BankDeposits extends StatefulWidget {
  const BankDeposits({super.key});

  @override
  State<BankDeposits> createState() => _BankDepositsState();
}

class _BankDepositsState extends State<BankDeposits> {
  final ImagePicker picker = ImagePicker();
  final List<DepositItem> items = [];

  bool _isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });

    super.initState();
  }

  Future<void> _initialize() async {
    try {
      await _loadCollections();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCollections() async {
    final snackBar = AppSnackBar.instance;

    try {
      final currentUser = await IAMService.instance.currentUser();

      final collectionList =
          await CollectionDbRepository.getPendingBankDepositCollections(
            currentUser,
          );

      final items = await Future.wait(
        collectionList.map((collection) async {
          final customer = await DBHelper.querySingle(
            DBTables.CUSTOMERS,
            where: '${DBColumns.CS_CODE} = ?',
            whereArgs: [collection.csCode],
          ).then((res) => res != null ? CustomerModel.fromJson(res) : null);

          return DepositItem(collection: collection, customer: customer);
        }),
      );

      this.items
        ..clear()
        ..addAll(items);
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> openDepositDetailsSaveSheet(DepositItem item) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: .antiAlias,
      useRootNavigator: true,
      routeSettings: RouteSettings(name: '/deposit-details-model-bottom-sheet'),
      builder: (context) => DepositDetails(item),
    );

    if (!context.mounted || result == null) return;

    final itemIndex = items.indexWhere(
      (element) => element.collection?.id == item.collection?.id,
    );

    if (itemIndex == -1) return;

    setState(() {
      items[itemIndex] = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bank Deposits',
      isLoading: _isLoading,
      isEmpty: items.isEmpty,
      emptyWidget: AppEmptyView(
        icon: Icons.receipt_long,
        title: 'No Deposits Found',
        message: 'Pull down or tap refresh to load the latest deposits.',
        buttonText: 'Refresh',
        onPressed: _loadCollections,
      ),
      body: DateGroupTabs<DepositItem>(
        items: items,
        dateSelector: (e) => e.collection!.createdAt,
        onRefresh: _loadCollections,
        separatorBuilder: (ctx, index) => SizedBox.shrink(),
        itemBuilder: (ctx, item, index) {
          return Card(
            clipBehavior: .antiAlias,
            margin: .fromLTRB(16, 0, 16, 16),
            child: ListTile(
              onTap: () => openDepositDetailsSaveSheet(item),
              enabled: !(item.uploaded || item.uploading),
              title: Text(item.customer!.displayText),
              // leading: Icon(Icons.cached),
              subtitle: Container(
                margin: const .only(top: 4),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    buildSubtitle(
                      item.collection?.payMode.label,
                      NumberHelper.formatCurrency(item.collection?.totalAmount),
                      valueColor: Colors.green,
                    ),
                    buildSubtitle(
                      "Date",
                      DateTimeHelper.getDisplayDateTime(
                        item.collection?.createdAt,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: item.uploaded
                  ? Container(
                      padding: .symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        border: .all(color: Colors.green),
                        borderRadius: .circular(8),
                      ),
                      child: Text(
                        'Uploaded',
                        style: TextStyle(color: Colors.green),
                      ),
                    )
                  : item.images.isNotEmpty
                  ? Stack(
                      alignment: .center,
                      children: [
                        Image.file(
                          item.images.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        if (item.images.length > 1)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: SizedBox.square(
                                dimension: 24,
                                child: Center(
                                  child: Text(
                                    '+${item.images.length - 1}',
                                    style: TextStyle(
                                      fontWeight: .bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Icon(Icons.camera_alt),
            ),
          );
        },
      ),
    );
  }

  Widget buildSubtitle(
    String? label,
    String? value, {
    bool isBold = false,
    bool isGrey = false,
    Color? valueColor,
    double labelWidth = 100,
  }) => Row(
    children: [
      SizedBox(
        width: labelWidth,
        child: Text("$label :", style: Theme.of(context).textTheme.bodySmall),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value ?? '',
          style: TextStyle(
            color: valueColor ?? (isGrey ? Colors.grey : null),
            fontWeight: isBold ? .bold : null,
          ),
        ),
      ),
    ],
  );

  Widget buildPaymodeIcon(){
    return Container();
  }
}

class DepositDetails extends StatefulWidget {
  final DepositItem item;
  const DepositDetails(this.item, {super.key});

  @override
  State<DepositDetails> createState() => _DepositDetailsState();
}

class _DepositDetailsState extends State<DepositDetails> {
  late DepositItem _item;
  BankModel? _selectedBank;
  final List<File> _capturedImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    _item = widget.item;
    _selectedBank = _item.bank;
    _capturedImages.addAll(_item.images);
    super.initState();
  }

  bool canUpload(DepositItem item) {
    return item.images.isNotEmpty &&
        item.bank?.bankCode != null &&
        item.collection?.docCode != null &&
        item.collection?.docNo != null;
  }

  Future<void> captureImage() async {
    final picked = await ImageService.instance.captureImage(
      cameraDevice: CameraDevice.front,
      crop: true,
      compress: true,
    );

    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();

    final file = await File(picked.path).copy(
      '${dir.path}/${_item.collection!.docCode}_${_item.collection!.docNo}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    debugPrint(
      'Captured image: ${(await file.length() / 1024).toStringAsFixed(2)} KB',
    );

    setState(() {
      _capturedImages.add(file);
    });
  }

  Future<void> previewImage(File file) {
    return FullscreenImageViewer.show(
      context,
      current: file.path,
      images: _capturedImages.map((e) => e.path).toList(),
    );
  }

  Future<void> uploadSlip(UserModel currentUser) async {
    final snackBar = AppSnackBar.instance;

    final docCode = _item.collection!.docCode;
    final docNo = _item.collection!.docNo;
    final bankCode = _item.bank!.bankCode;

    final res = await UploadApiRepository.uploadSlip(
      currentUser,
      docCode: docCode,
      docNo: docNo,
      files: _item.images,
      bankCode: bankCode,
    );

    if (res.statusCode != 200) {
      _item = _item.copyWith(uploaded: false);
      snackBar.error(message: res.message);
      return;
    }

    snackBar.success(title: docNo, message: res.message);

    final rows = await DBHelper.update(
      DBTables.COLLECTION_HEADERS,
      values: {DBColumns.DEPOSITED: 1},
      where: '${DBColumns.DOC_NO} = ?',
      whereArgs: [docNo],
    );

    if (rows == 0) {
      snackBar.error(message: 'Failed to update collection: $docNo');
      return;
    }

    _item = _item.copyWith(uploaded: true);
  }

  Future<void> onSave() async {
    final snackBar = AppSnackBar.instance;

    setState(() => _isUploading = true);

    try {
      final currentUser = await IAMService.instance.currentUser();

      _item = _item.copyWith(bank: _selectedBank, images: _capturedImages);

      if (!canUpload(_item)) return;

      await uploadSlip(currentUser);

      if (!mounted || !_item.uploaded) return;

      Navigator.pop(context, _item);
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<List<BankModel>> fetchBanks() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      return await BankDbRepository.getAllBanks(currentUser);
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit Details', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const .all(16),
        child: AppButton.of(context).save(
          onPressed: onSave,
          enabled: _selectedBank != null && _capturedImages.isNotEmpty,
          loading: _isUploading,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 24,
            children: [
              Column(
                spacing: 8,
                children: [
                  _buildInfoRow(
                    Icons.numbers_rounded,
                    'Document No.',
                    _item.collection?.docNo ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.person_rounded,
                    'Customer',
                    _item.customer?.displayText ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.payments_rounded,
                    'Payment Mode',
                    _item.collection?.payMode.label ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.payments_outlined,
                    'Amount',
                    NumberHelper.formatCurrency(_item.collection?.totalAmount),
                  ),
                  _buildInfoRow(
                    Icons.date_range_rounded,
                    'Date',
                    DateTimeHelper.getDisplayDateTime(
                      _item.collection?.createdAt,
                    ),
                  ),
                ],
              ),
              Divider(height: 0),
              AsyncSearchPicker<BankModel>(
                selectedItem: _selectedBank,
                searchKey: (item) => item.searchKey,
                displayText: (item) => item.displayText,
                onChanged: (val) => setState(() => _selectedBank = val),
                hint: 'Select deposit bank',
                title: 'Deposit Bank',
                loadItems: fetchBanks,
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  FormWidgets.of(context).titleBuilder(
                    title: 'Deposit Slips / Documents',
                  ),
                  GridView.builder(
                    itemCount: _capturedImages.length + 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      if (index == _capturedImages.length) {
                        return GestureDetector(
                          onTap: captureImage,
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo),
                                  SizedBox(height: 4),
                                  Text(
                                    _capturedImages.isEmpty
                                        ? 'Add Image'
                                        : 'Add More',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final file = _capturedImages[index];

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onTap: () => previewImage(file),
                              child: Image.file(
                                file,
                                width: .infinity,
                                height: .infinity,
                                fit: .cover,
                              ),
                            ),
                          ),

                          /// DELETE BUTTON
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _capturedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const .all(4),
                                margin: const .only(left: 16, bottom: 16),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              AppAlert.info(
                title: 'Tips for Better Images',
                message:
                    'Place the deposit slip on a flat surface, ensure good lighting, '
                    'and capture the entire document clearly.',
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
