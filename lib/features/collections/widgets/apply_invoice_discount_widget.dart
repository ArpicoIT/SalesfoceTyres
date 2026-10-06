import 'dart:math';

import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/route_paths.dart';
import '../../../app/styles/app_text_style.dart';
import '../../../helpers/number_helper.dart';
import '../../../models/collection_model.dart';
import '../../../models/invoice_model.dart';
import '../../../services/database/db_constants.dart';
import '../../../services/database/repositories/system_file_db_repository.dart';
import '../../../shared/components/app/app_alert.dart';
import '../../../shared/components/app/app_scaffold.dart';
import '../../../shared/components/button/app_button.dart';
import '../../../shared/components/form/discount_input_field.dart';
import '../helpers/collection_ui_helper.dart';
import '../notifiers/invoice_setoff_notifier.dart';

class ApplyInvoiceDiscountWidget extends StatefulWidget {
  const ApplyInvoiceDiscountWidget({super.key});

  @override
  State<ApplyInvoiceDiscountWidget> createState() =>
      _ApplyInvoiceDiscountWidgetState();
}

class _ApplyInvoiceDiscountWidgetState
    extends State<ApplyInvoiceDiscountWidget> {
  /// Scroll controllers
  final _mainScrollController = ScrollController();

  /// Notifiers
  late InvoiceSetOffNotifier notifier;

  /// Editing controllers
  final _cashDiscountController = TextEditingController();
  final _bulkDiscountController = TextEditingController();

  /// Focus nodes
  final _cashDiscountFocus = FocusNode();
  final _bulkDiscountFocus = FocusNode();

  /// Constants
  final int negative = -1;

  /// variables
  double? _maxCashDiscount;
  double? _maxBulkDiscount;
  InvoiceCategory? _category;
  String _error = '';
  bool _isLoading = true;

  /// state variables of discount input
  double _currentCashDiscount = 0;
  double _currentBulkDiscount = 0;
  double _currentCashDiscountAmount = 0;
  double _currentBulkDiscountAmount = 0;

  bool _isSavedCashDiscount = false;
  bool _isSavedBulkDiscount = false;

  /// Getters
  InvoiceModel get currentInvoice => notifier.selectedInvoice;
  List<CollectionSetOffModel> get currentSetOffs => notifier.setOffs;
  double get invoiceAmount => currentInvoice.originalAmount.toDouble();
  double get invoiceBalance => currentInvoice.balanceAmount.toDouble();
  double get maxCashDiscount => _maxCashDiscount ?? 0;
  double get maxBulkDiscount => _maxBulkDiscount ?? 0;
  bool get isMaxCashDiscountAvailable => _maxCashDiscount != null;
  bool get isMaxBulkDiscountAvailable => _maxBulkDiscount != null;

  InvoiceCategory? get category => _category;
  bool get isError => _error.isNotEmpty;

  bool get canEditBulkDiscount {
    if (currentInvoice.bulkDiscount > 0) return false;

    if (currentInvoice.currentBulkDiscount > 0 &&
        currentInvoice.nextInvoiceUnlockedByGivenDiscount) {
      return false;
    }

    if (category == .nonTrading) return true;

    return category == .trading &&
        (_currentCashDiscount > 0 ||
            currentInvoice.currentCashDiscount > 0 ||
            currentInvoice.cashDiscount > 0);
  }

  bool get canSaveDiscount =>
      _currentCashDiscount > 0 || _currentBulkDiscount > 0;

  double get displayCashDiscountAmount {
    if (currentInvoice.cashDiscount > 0) {
      /// undefined, future calculation
      return 0;
    } else if ((currentInvoice.currentCashDiscount * negative) > 0) {
      return (currentInvoice.currentCashDiscount * negative).toDouble();
    } else {
      return _currentCashDiscountAmount;
    }
  }

  double get displayBulkDiscountAmount {
    if (currentInvoice.bulkDiscount > 0) {
      /// undefined, future calculation
      return 0;
    } else if ((currentInvoice.currentBulkDiscount * negative) > 0) {
      return (currentInvoice.currentBulkDiscount * negative).toDouble();
    } else {
      return _currentBulkDiscountAmount;
    }
  }

  /// must be positive
  double get displayTotalDiscountAmount =>
      displayCashDiscountAmount + displayBulkDiscountAmount;

  /// must be positive
  // double get displayRemainingInvoiceBalance =>
  //     invoiceBalance - displayTotalDiscountAmount;

  double get displayRemainingInvoiceBalance =>
      (_currentCashDiscount > 0 || _currentBulkDiscount > 0)
      ? invoiceBalance - displayTotalDiscountAmount
      : invoiceBalance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      // _category = .trading;
      // _category = .nonTrading;
      await _loadInvoiceCategory();
      await _loadMaxCashDiscount();
      await _loadMaxBulkDiscount();

      _isLoading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = context.watch<InvoiceSetOffNotifier>();
  }

  Future<void> _loadInvoiceCategory() async {
    final tradingCodes = await SystemFileDbRepository.getTradingDocCodes();

    if (tradingCodes == null) {
      _error = 'Trading codes not available.';
      return;
    }

    if (tradingCodes.contains(currentInvoice.docCode)) {
      _category = .trading;
      return;
    }

    final nonTradingCodes =
        await SystemFileDbRepository.getNonTradingDocCodes();

    if (nonTradingCodes == null) {
      _error = 'Non-Trading codes not available.';
      return;
    }

    if (nonTradingCodes.contains(currentInvoice.docCode)) {
      _category = .nonTrading;
      return;
    }

    _error = 'Invoice type not available.';
    _category = null;
  }

  Future<void> _loadMaxCashDiscount() async {
    final discount = await SystemFileDbRepository.getMaxCashDiscount();
    _maxCashDiscount = null;

    if (discount == null) {
      _error = 'Cash discount limit not available.';
      return;
    }

    if (currentInvoice.originalAmount == 0) {
      _error = 'Invoice amount is zero.';
      return;
    }

    _maxCashDiscount = min(
      discount,
      currentInvoice.balanceAmount * 100 / currentInvoice.originalAmount,
    );
  }

  Future<void> _loadMaxBulkDiscount() async {
    final discount = await SystemFileDbRepository.getMaxBulkDiscount();
    _maxBulkDiscount = null;

    if (discount == null) {
      _error = 'Bulk discount limit not available.';
      return;
    }

    if (currentInvoice.originalAmount == 0) {
      _error = 'Invoice amount is zero.';
      return;
    }

    _maxBulkDiscount = min(
      discount,
      currentInvoice.balanceAmount * 100 / currentInvoice.originalAmount,
    );
  }

  double _calculateDiscountAmount({
    required double baseAmount,
    required double discountPercentage,
  }) {
    if (baseAmount <= 0 || discountPercentage <= 0) {
      return 0;
    }

    return baseAmount * discountPercentage / 100;
  }

  bool _isValidDiscount({
    required double discount,
    required double maxDiscount,
  }) {
    return discount > 0 && discount <= maxDiscount;
  }

  void _applyCashDiscount() {
    final snackBar = AppSnackBar.instance;

    if (_currentCashDiscount == 0) return;

    if (_currentCashDiscount < 0 || _currentCashDiscount > 100) {
      snackBar.error(
        title: 'Invalid Cash Discount',
        message: 'Please enter a valid cash discount.',
      );
      return;
    }

    final discountAmount = _calculateDiscountAmount(
      baseAmount: invoiceAmount,
      discountPercentage: _currentCashDiscount,
    );

    if (discountAmount == 0) {
      snackBar.error(
        title: 'Invalid Cash Discount',
        message: 'Cash discount amount is zero.',
      );
      return;
    }

    if (discountAmount > invoiceBalance) {
      snackBar.error(
        title: 'Invalid Cash Discount',
        message: 'Cash discount amount exceeds the invoice balance.',
      );
      return;
    }

    /// Add to collection list
    notifier.addSetOff(
      CollectionSetOffModel(
        recType: DBConstants.DOC_CASH_DISCOUNT,
        recDoc: DBConstants.DOC_CASH_DISCOUNT,
        recNo: DBConstants.DOC_CASH_DISCOUNT,
        invDoc: currentInvoice.docCode!,
        invNo: currentInvoice.docNo!,
        setOffAmount: discountAmount * negative,
        discount: _currentCashDiscount,
        createdAt: DateTime.now(),
      ),
    );

    /// Update invoice
    notifier.updateSelectedInvoice(
      (e) => e.copyWith(
        balanceAmount: e.balanceAmount - discountAmount,
        currentCashDiscount: _currentCashDiscount,
        currentCashDiscountAmount: discountAmount * negative,
      ),
    );

    /// Update related invoice object in list
    notifier.updateInvoiceWhere(
      matcher: (item) => item.id == currentInvoice.id,
      updater: (item) => currentInvoice,
    );

    _isSavedCashDiscount = true;
  }

  void _applyBulkDiscount() {
    final snackBar = AppSnackBar.instance;

    if (_currentBulkDiscount == 0) return;

    if (_currentBulkDiscount < 0 || _currentBulkDiscount > 100) {
      snackBar.error(
        title: 'Invalid Bulk Discount',
        message: 'Please enter a valid bulk discount.',
      );
      return;
    }

    late double discountAmount;

    if (category == .nonTrading) {
      discountAmount = _calculateDiscountAmount(
        baseAmount: invoiceAmount,
        discountPercentage: _currentBulkDiscount,
      );
    } else if (category == .trading) {
      discountAmount = _calculateDiscountAmount(
        baseAmount: invoiceBalance,
        discountPercentage: _currentBulkDiscount,
      );
    } else {
      discountAmount = 0;
    }

    if (discountAmount == 0) {
      snackBar.error(
        title: 'Invalid Bulk Discount',
        message: 'Bulk discount amount is zero.',
      );
      return;
    }

    if (discountAmount > invoiceBalance) {
      snackBar.error(
        title: 'Invalid Bulk Discount',
        message: 'Bulk discount amount exceeds the invoice balance.',
      );
      return;
    }

    /// Add to collection list
    notifier.addSetOff(
      CollectionSetOffModel(
        recType: DBConstants.DOC_BULK_DISCOUNT,
        recDoc: DBConstants.DOC_BULK_DISCOUNT,
        recNo: DBConstants.DOC_BULK_DISCOUNT,
        invDoc: currentInvoice.docCode!,
        invNo: currentInvoice.docNo!,
        setOffAmount: discountAmount * negative,
        discount: _currentBulkDiscount,
        createdAt: DateTime.now(),
      ),
    );

    /// Update invoice
    notifier.updateSelectedInvoice(
      (e) => e.copyWith(
        balanceAmount: e.balanceAmount - discountAmount,
        currentBulkDiscount: _currentBulkDiscount,
        currentBulkDiscountAmount: discountAmount * negative,
      ),
    );

    /// Update related invoice object in list
    notifier.updateInvoiceWhere(
      matcher: (item) => item.id == currentInvoice.id,
      updater: (item) => currentInvoice,
    );
    _isSavedBulkDiscount = true;
  }

  void _removeCashDiscount() {
    final snackBar = AppSnackBar.instance;

    if (!_isSavedCashDiscount &&
        currentInvoice.nextInvoiceUnlockedByGivenDiscount) {
      snackBar.error(
        title: 'Cannot Remove Cash Discount',
        message:
        'This cash discount was used to unlock the next invoice and cannot be removed.',
      );
      return;
    }

    if (_category == .trading &&
        (currentInvoice.currentBulkDiscount > 0 ||
            _currentBulkDiscount > 0)) {
      snackBar.error(
        title: 'Cannot Remove Cash Discount',
        message:
        'Please remove the bulk discount before removing this cash discount.',
      );
      return;
    }

    notifier.removeSetOffWhere(
          (e) =>
      e.recType == DBConstants.DOC_CASH_DISCOUNT &&
          e.recDoc == DBConstants.DOC_CASH_DISCOUNT &&
          e.recNo == DBConstants.DOC_CASH_DISCOUNT &&
          e.invDoc == currentInvoice.docCode &&
          e.invNo == currentInvoice.docNo &&
          e.discount == currentInvoice.currentCashDiscount,
    );

    notifier.updateSelectedInvoice(
          (e) => e.copyWith(
        balanceAmount: e.balanceAmount + (e.currentCashDiscountAmount * negative),
        currentCashDiscount: 0,
        currentCashDiscountAmount: 0,
      ),
    );

    notifier.updateInvoiceWhere(
      matcher: (item) => item.id == currentInvoice.id,
      updater: (item) => currentInvoice,
    );

    _cashDiscountController.clear();
    _currentCashDiscountAmount = 0;
    _currentCashDiscount = 0;
    _isSavedCashDiscount = false;

    if (mounted) setState(() {});
  }

  void _removeBulkDiscount() {
    final snackBar = AppSnackBar.instance;

    if (!_isSavedBulkDiscount &&
        currentInvoice.nextInvoiceUnlockedByGivenDiscount) {
      snackBar.error(
        title: 'Cannot Remove Bulk Discount',
        message:
        'This bulk discount was used to unlock the next invoice and cannot be removed.',
      );
      return;
    }

    notifier.removeSetOffWhere(
          (e) =>
      e.recType == DBConstants.DOC_BULK_DISCOUNT &&
          e.recDoc == DBConstants.DOC_BULK_DISCOUNT &&
          e.recNo == DBConstants.DOC_BULK_DISCOUNT &&
          e.invDoc == currentInvoice.docCode &&
          e.invNo == currentInvoice.docNo &&
          e.discount == currentInvoice.currentBulkDiscount,
    );

    notifier.updateSelectedInvoice(
          (e) => e.copyWith(
        balanceAmount: e.balanceAmount + (e.currentBulkDiscountAmount * negative),
        currentBulkDiscount: 0,
        currentBulkDiscountAmount: 0,
      ),
    );

    notifier.updateInvoiceWhere(
      matcher: (item) => item.id == currentInvoice.id,
      updater: (item) => currentInvoice,
    );

    _bulkDiscountController.clear();
    _currentBulkDiscountAmount = 0;
    _currentBulkDiscount = 0;
    _isSavedBulkDiscount = false;

    if (mounted) setState(() {});
  }

  void onSaveDiscount() {
    _applyCashDiscount();
    _applyBulkDiscount();

    _cashDiscountController.clear();
    _currentCashDiscountAmount = 0;
    _currentCashDiscount = 0;

    _bulkDiscountController.clear();
    _currentBulkDiscountAmount = 0;
    _currentBulkDiscount = 0;

    if (mounted) setState(() {});
  }

  void onRemoveCashDiscount() => _removeCashDiscount();

  void onRemoveBulkDiscount() => _removeBulkDiscount();

  void onDownloadMaxDiscount() async {
    await Navigator.of(context).pushNamed(RoutePaths.downloads);
    await _loadMaxCashDiscount();
    await _loadMaxBulkDiscount();
    if (mounted) setState(() {});
  }

  void onChangedCashDiscount(double discount) {
    switch (category) {
      case null:
        throw UnimplementedError();
      case InvoiceCategory.nonTrading:
        if (!_isValidDiscount(
          discount: discount,
          maxDiscount: maxCashDiscount,
        )) {
          _currentCashDiscountAmount = 0;
          _currentCashDiscount = 0;
        } else {
          _currentCashDiscountAmount = _calculateDiscountAmount(
            baseAmount: invoiceAmount,
            discountPercentage: discount,
          );
          _currentCashDiscount = discount;
        }

        if (mounted) setState(() {});
        break;
      case InvoiceCategory.trading:
        if (!_isValidDiscount(
          discount: discount,
          maxDiscount: maxCashDiscount,
        )) {
          _currentCashDiscountAmount = 0;
          _currentCashDiscount = 0;
        } else {
          _currentCashDiscountAmount = _calculateDiscountAmount(
            baseAmount: invoiceAmount,
            discountPercentage: discount,
          );
          _currentCashDiscount = discount;
        }

        if (_currentBulkDiscount > 0) {
          _currentBulkDiscount = 0;
          _bulkDiscountController.clear();
        }

        if (mounted) setState(() {});
        break;
    }
  }

  void onChangedBulkDiscount(double discount) {
    switch (category) {
      case null:
        throw UnimplementedError();
      case InvoiceCategory.nonTrading:
        if (!_isValidDiscount(
          discount: discount,
          maxDiscount: maxBulkDiscount,
        )) {
          _currentBulkDiscountAmount = 0;
          _currentBulkDiscount = 0;
        } else {
          _currentBulkDiscountAmount = _calculateDiscountAmount(
            baseAmount: invoiceAmount,
            discountPercentage: discount,
          );
          _currentBulkDiscount = discount;
        }

        // _updateRemainingBalance();

        if (mounted) setState(() {});
        break;
      case InvoiceCategory.trading:
        if (!_isValidDiscount(
          discount: discount,
          maxDiscount: maxBulkDiscount,
        )) {
          _currentBulkDiscountAmount = 0;
          _currentBulkDiscount = 0;
        } else {
          _currentBulkDiscountAmount = _calculateDiscountAmount(
            baseAmount: invoiceBalance - _currentCashDiscountAmount,
            discountPercentage: discount,
          );
          _currentBulkDiscount = discount;
        }

        // _updateRemainingBalance();
        if (mounted) setState(() {});
        break;
    }
  }

  void unfocus() {
    _cashDiscountFocus.unfocus();
    _bulkDiscountFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Apply Discount'),
        titleTextStyle: AppTextStyle.of(context).smallAppBar,
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      isLoading: _isLoading,
      scrollController: _mainScrollController,
      scrollableBody: Column(
        mainAxisSize: .min,
        // spacing: 24,
        children: [
          Container(
            color: cs.surfaceContainer,
            padding: .symmetric(vertical: 16, horizontal: 24),
            child: CollectionUiHelper.of(context).invoiceDetailLargeHeader(
              currentInvoice,
              showCurrentBalance: true,
              showAppliedCreditAmount: false,
              showMaxDiscount: false,
            ),
          ),

          Padding(
            padding: .symmetric(vertical: 16, horizontal: 24),
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 12,
              children: [
                DiscountAlerts.of(context).info(_category),
                const SizedBox(height: 12),
                ...[
                  if (currentInvoice.cashDiscount > 0) ...[
                    DiscountAlerts.of(context).cashDiscountAlreadyExist(
                      currentInvoice.cashDiscount.toDouble(),
                      null,
                      null,
                    ),
                  ] else if (currentInvoice.currentCashDiscount > 0) ...[
                    DiscountAlerts.of(context).cashDiscountAlreadyExist(
                      currentInvoice.currentCashDiscount.toDouble(),
                      currentInvoice.currentCashDiscountAmount.toDouble(),
                      onRemoveCashDiscount,
                      /// remove need condition
                    ),
                  ] else if (_maxCashDiscount == null) ...[
                    DiscountAlerts.of(
                      context,
                    ).cashDiscountLimitNotAvailable(onDownloadMaxDiscount),
                  ] else ...[
                    buildDiscountInputRow(
                      label: 'Cash Discount',
                      controller: _cashDiscountController,
                      focusNode: _cashDiscountFocus,
                      maxDiscount: maxCashDiscount,
                      discountAmount: _currentCashDiscountAmount * negative,
                      onChanged: onChangedCashDiscount,
                      enabled: true,
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                ...[
                  if (currentInvoice.bulkDiscount > 0) ...[
                    DiscountAlerts.of(context).bulkDiscountAlreadyExist(
                      currentInvoice.bulkDiscount.toDouble(),
                      null,
                      null,
                    ),
                  ] else if (currentInvoice.currentBulkDiscount > 0) ...[
                    DiscountAlerts.of(context).bulkDiscountAlreadyExist(
                      currentInvoice.currentBulkDiscount.toDouble(),
                      currentInvoice.currentBulkDiscountAmount.toDouble(),
                      onRemoveBulkDiscount,

                      /// remove need condition
                    ),
                  ] else if (_maxBulkDiscount == null) ...[
                    DiscountAlerts.of(
                      context,
                    ).bulkDiscountLimitNotAvailable(onDownloadMaxDiscount),
                  ] else ...[
                    buildDiscountInputRow(
                      label: 'Bulk Discount',
                      controller: _bulkDiscountController,
                      focusNode: _bulkDiscountFocus,
                      maxDiscount: maxBulkDiscount,
                      discountAmount: _currentBulkDiscountAmount * negative,
                      onChanged: onChangedBulkDiscount,
                      enabled: canEditBulkDiscount,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
      onTapBackground: unfocus,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: .symmetric(vertical: 12, horizontal: 24),
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          spacing: 12,
          children: [
            CollectionUiHelper.of(context).buildSummaryFooterRow(
              label: 'Total Discount Amount',
              value: NumberHelper.formatCurrency(displayTotalDiscountAmount * negative),
              valueColor: Colors.green,
            ),
            CollectionUiHelper.of(context).buildSummaryFooterRow(
              label: 'Remaining Balance',
              value: NumberHelper.formatCurrency(
                displayRemainingInvoiceBalance,
              ),
            ),
            const SizedBox(height: 6),
            AppButton.of(context).filled(
              onPressed: onSaveDiscount,
              enabled: canSaveDiscount,
              label: 'Save Discount',
            ),
          ],
        ),
      ),
    );
  }



  Widget buildDiscountInputRow({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required double maxDiscount,
    void Function(double)? onChanged,
    required double discountAmount,
    bool enabled = false,
  }) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Text(label, style: tt.bodyLarge?.copyWith(color: cs.secondary)),
        // const SizedBox(height: 8),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                label,
                style: tt.bodyLarge?.copyWith(color: cs.secondary),
              ),
            ),
            Expanded(
              child: DiscountInputField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxDiscount: maxDiscount,
                onChanged: onChanged,
                filled: false,
              ),
            ),
            Expanded(
              child: Container(
                height: kMinInteractiveDimension,
                padding: .symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: .circular(12),
                  color: cs.surfaceContainer,
                  // border: .all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.centerRight,
                child: Text(
                  NumberHelper.formatCurrency(discountAmount),
                  style: tt.bodyMedium?.copyWith(color: Colors.green),
                ),
              ),
            ),
            // IconButton(
            //   onPressed: removable ? onRemove : null,
            //   icon: Icon(Icons.delete_rounded),
            //   color: Colors.red,
            // ),
          ],
        ),
      ],
    );
  }
}

class DiscountAlerts {
  final BuildContext context;
  DiscountAlerts._(this.context);
  static DiscountAlerts of(BuildContext context) => DiscountAlerts._(context);

  Widget info(InvoiceCategory? category) {
    String tradingCategoryInfo =
        'This invoice belongs to the **${category?.label}** category. '
        'You must apply the **Cash Discount** before the **Bulk Discount**. '
        'Once the Bulk Discount is applied, the Cash Discount cannot be applied.';

    String nonTradingCategoryInfo =
        'This invoice belongs to the **${category?.label}** category. '
        'You can apply the **Cash Discount** and **Bulk Discount** in any order.';

    String message = category == .trading
        ? tradingCategoryInfo
        : category == .nonTrading
        ? nonTradingCategoryInfo
        : '';

    return AppAlert.info(message: message);
  }

  Widget cashDiscountLimitNotAvailable(Function() onAction) {
    return AppAlert.error(
      title: 'Cash Discount Limit Not Available',
      message:
          'Please download the latest cash discount limit before entering a discount.',
      note: 'Downloads → System Files',
      actionText: 'Download',
      onAction: onAction,
    );
  }

  Widget bulkDiscountLimitNotAvailable(Function() onAction) {
    return AppAlert.error(
      title: 'Bulk Discount Limit Not Available',
      message:
          'Please download the latest bulk discount limit before entering a discount.',
      note: 'Downloads → System Files',
      actionText: 'Download',
      onAction: onAction,
    );
  }

  Widget cashDiscountAlreadyExist(
    double discount,
    double? discountAmount,
    Function()? onAction,
  ) {
    return AppAlert.success(
      title: 'Cash Discount',
      message:
          '**${discount.toStringAsFixed(2)}% Cash Discount** applied to this invoice.',
      note: discountAmount != null
          ? 'Discount amount: ${NumberHelper.formatCurrency(discountAmount)}'
          : null,
      actionText: 'Remove',
      onAction: onAction,
    );
  }

  Widget bulkDiscountAlreadyExist(
    double discount,
    double? discountAmount,
    Function()? onAction,
  ) {
    return AppAlert.success(
      title: 'Bulk Discount',
      message:
          '**${discount.toStringAsFixed(2)}% Bulk Discount** applied to this invoice.',
      note: discountAmount != null
          ? 'Discount amount: ${NumberHelper.formatCurrency(discountAmount)}'
          : null,
      actionText: 'Remove',
      onAction: onAction,
    );
  }

  // Widget cashDiscountAlreadyExistWithRemovable(double discount, Function()? onAction) {
  //   return AppAlert.success(
  //     title: 'Cash Discount',
  //     message:
  //     '**${discount.toStringAsFixed(2)}% Cash Discount** already given to this invoice.',
  //     actionText: 'Remove',
  //     onAction: onAction,
  //   );
  // }
  //
  // Widget bulkDiscountAlreadyExistWithRemovable(double discount, Function()? onAction) {
  //   return AppAlert.success(
  //     title: 'Bulk Discount',
  //     message:
  //     '**${discount.toStringAsFixed(2)}% Bulk Discount** already given to this invoice.',
  //     actionText: 'Remove',
  //     onAction: onAction,
  //   );
  // }
}
