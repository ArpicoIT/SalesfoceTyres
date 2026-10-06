import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/styles/app_text_style.dart';
import '../../../helpers/number_helper.dart';
import '../../../models/collection_model.dart';
import '../../../models/credit_note_model.dart';
import '../../../models/invoice_model.dart';
import '../../../services/database/db_constants.dart';
import '../../../shared/components/app/app_scaffold.dart';
import '../../../shared/components/app/app_sliver_scaffold.dart';
import '../../../shared/components/button/app_button.dart';
import '../../../shared/components/list/model_list_view.dart';
import '../helpers/collection_ui_helper.dart';
import '../notifiers/invoice_setoff_notifier.dart';

class ApplyInvoiceCreditWidget extends StatefulWidget {
  const ApplyInvoiceCreditWidget({super.key});

  @override
  State<ApplyInvoiceCreditWidget> createState() =>
      _ApplyInvoiceCreditWidgetState();
}

class _ApplyInvoiceCreditWidgetState extends State<ApplyInvoiceCreditWidget> {
  /// Scroll controllers
  final _mainScrollController = ScrollController();

  /// Keys
  final _creditNotesKey =
      GlobalKey<ModelListViewState<CreditNoteModel>>();

  /// Notifiers
  late InvoiceSetOffNotifier notifier;

  /// Constants
  final int negative = -1;

  /// Variables
  final List<CreditNoteModel> _selectedCreditNotes = [];
  double _displayRemainingInvoiceBalance = 0;
  double _displayTotalDiscountAmount = 0;

  /// Getters
  InvoiceModel get currentInvoice => notifier.selectedInvoice;
  List<CreditNoteModel> get creditNotes => notifier.creditNotes;
  List<CollectionSetOffModel> get creditCollections =>
      notifier.selectedInvoiceCreditCollections;
  double get appliedCredit =>
      creditCollections.fold(0.0, (sum, e) => sum + e.setOffAmount);
  double get applyingCredit =>
      _selectedCreditNotes.fold(0.0, (sum, e) => sum + e.balanceAmount);
  double get amountToApply =>
      (applyingCredit * negative) > currentInvoice.balanceAmount
      ? (currentInvoice.balanceAmount.toDouble() * negative)
      : applyingCredit;
  double get invoiceBalanceAmount => currentInvoice.balanceAmount.toDouble();
  bool get canApply => _selectedCreditNotes.isNotEmpty;

  ModelListViewState<CreditNoteModel>? get creditNotesState =>
      _creditNotesKey.currentState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _displayTotalDiscountAmount = appliedCredit;
      _displayRemainingInvoiceBalance = currentInvoice.balanceAmount.toDouble();

      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = context.watch<InvoiceSetOffNotifier>();
  }

  void onCancel() async {
    Navigator.of(context).pop();
  }

  void onSave() {
    final snackBar = AppSnackBar.instance;

    if (_selectedCreditNotes.isEmpty) {
      debugPrint('No credit notes selected.');
      snackBar.error(
        title: 'No Credit Notes Selected',
        message: 'Please select at least one credit note.',
      );
      return;
    }

    if (invoiceBalanceAmount == 0.0) {
      debugPrint(
        'Invoice ${currentInvoice.docNo} has no outstanding balance.',
      );

      /// Disable selected invoice
      notifier.updateSelectedInvoice((e) => e.copyWith(rowSts: .DIS));
      snackBar.error(
        title: 'No Remaining Balance',
        message:
            'Invoice ${currentInvoice.docCode}${currentInvoice.docNo} has no remaining balance.',
      );

      /// Find and unlock nearest available invoice
      // _getNearestAvailableInvoiceWithUnlocking(selectedInvoice);
      return;
    }

    for (var creditNote in _selectedCreditNotes) {
      final double invSetOffAmount = currentInvoice.setOffAmount.toDouble();
      final double crdnBalanceAmount = creditNote.balanceAmount.toDouble();
      final double crdnSetOffAmount = creditNote.setOffAmount.toDouble();

      if (invoiceBalanceAmount == 0.0) {
        debugPrint(
          'Invoice ${currentInvoice.docNo} has no outstanding balance to set off.',
        );
        notifier.updateSelectedInvoice((e) => e.copyWith(rowSts: .DIS));
        break;
      }

      if (crdnBalanceAmount == 0.0) {
        debugPrint(
          'Credit note ${creditNote.docNo} has no available balance to apply.',
        );
        creditNote = creditNote.copyWith(rowSts: .DIS);
        continue;
      }

      if (invoiceBalanceAmount + crdnBalanceAmount >= 0) {
        final double invNewBalanceAmount =
            invoiceBalanceAmount + crdnBalanceAmount;
        final double finalSetOffAmount = crdnBalanceAmount;
        final double crdnNewBalanceAmount = 0.0;
        final double crdnNewSetOffAmount = crdnSetOffAmount + crdnBalanceAmount;

        /// Update credit note
        // ListHelper.updateLocalRow<CreditNoteModel>(
        //   source: creditNotes,
        //   matcher: (item) => item.id == creditNote.id,
        //   updater: (item) => item.copyWith(
        //     balanceAmount: crdnNewBalanceAmount,
        //     setoffAmount: crdnNewSetOffAmount,
        //     rowSts: .DIS,
        //   ),
        //   setListCallback: notifier.setCreditNotes,
        // )!;

        notifier.updateCreditNoteWhere(
          matcher: (item) => item.id == creditNote.id,
          updater: (item) => item.copyWith(
            balanceAmount: crdnNewBalanceAmount,
            setOffAmount: crdnNewSetOffAmount,
            rowSts: .DIS,
          ),
        );

        /// Add to collection list
        notifier.addSetOff(
          CollectionSetOffModel(
            recType: DBConstants.DOC_CREDIT_NOTE,
            recDoc: creditNote.docCode!,
            recNo: creditNote.docNo!,
            invDoc: currentInvoice.docCode!,
            invNo: currentInvoice.docNo!,
            setOffAmount: finalSetOffAmount,
            createdAt: DateTime.now(),
          ),
        );

        /// Update invoice
        notifier.updateSelectedInvoice(
          (e) => e.copyWith(
            balanceAmount: invNewBalanceAmount,
            currentCreditAmount: appliedCredit,
          ),
        );
      } else {
        /// Credit Note set-off with balance
        /// Invoice balance will be updated to zero
        final double invNewBalanceAmount = 0.0;
        final double finalSetOffAmount = invoiceBalanceAmount * negative;
        final double crdnNewSetOffAmount = crdnSetOffAmount - invoiceBalanceAmount;
        final double crdnNewBalanceAmount =
            crdnBalanceAmount + invoiceBalanceAmount;

        /// Update credit note
        // ListHelper.updateLocalRow<CreditNoteModel>(
        //   source: creditNotes,
        //   matcher: (item) => item.id == creditNote.id,
        //   updater: (item) => item.copyWith(
        //     balanceAmount: crdnNewBalanceAmount,
        //     setoffAmount: crdnNewSetOffAmount,
        //   ),
        //   setListCallback: notifier.setCreditNotes,
        // )!;

        notifier.updateCreditNoteWhere(
          matcher: (item) => item.id == creditNote.id,
          updater: (item) => item.copyWith(
            balanceAmount: crdnNewBalanceAmount,
            setOffAmount: crdnNewSetOffAmount,
          ),
        );

        /// Add to collection list
        notifier.addSetOff(
          CollectionSetOffModel(
            recType: DBConstants.DOC_CREDIT_NOTE,
            recDoc: creditNote.docCode!,
            recNo: creditNote.docNo!,
            invDoc: currentInvoice.docCode!,
            invNo: currentInvoice.docNo!,
            setOffAmount: finalSetOffAmount,
            createdAt: DateTime.now(),
          ),
        );

        /// Update invoice
        notifier.updateSelectedInvoice(
          (e) => e.copyWith(
            balanceAmount: invNewBalanceAmount,
            currentCreditAmount: appliedCredit,
          ),
        );

        break;
      }
    }

    // if (_invBalanceAmount == 0.0) {
    //   debugPrint(
    //     'Invoice ${selectedInvoice.docNo} has no outstanding balance.',
    //   );
    //
    //   /// Disable selected invoice
    //   notifier.updateSelectedInvoice((e) => e.copyWith(rowSts: .DIS));
    // }

    /// Update related invoice object in list
    notifier.updateInvoiceWhere(
      matcher: (item) => item.id == currentInvoice.id,
      updater: (item) => currentInvoice,
    );

    /// Reset data
    creditNotesState?.clearSelection();
  }

  void onMultiSelectChanged(List<CreditNoteModel> creditNotes) {
    final snackBar = AppSnackBar.instance;

    _selectedCreditNotes.clear();
    _selectedCreditNotes.addAll(creditNotes);

    final invoiceNewBalance = currentInvoice.balanceAmount + applyingCredit;

    if (invoiceNewBalance < 0) {
      _displayRemainingInvoiceBalance = 0;
      snackBar.info(
        title: 'Credit Adjusted',
        message: 'Credit applied is limited to the invoice balance.',
      );
    } else {
      _displayRemainingInvoiceBalance = invoiceNewBalance;
    }

    _displayTotalDiscountAmount = appliedCredit + amountToApply;

    if (mounted) setState(() {});
  }

  void unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Apply Credit'),
        titleTextStyle: AppTextStyle.of(context).smallAppBar,
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      isLoading: false, // _isLoading,
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
              showAppliedCreditAmount: true,
              showMaxDiscount: false,
            ),
          ),

          Padding(
            padding: .symmetric(vertical: 16, horizontal: 24),
            child: ModelListView<CreditNoteModel>(
              key: _creditNotesKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              multiSelect: true,
              uniqueKey: (creditNote) => creditNote.id,
              items: creditNotes,
              title: 'Credit Notes',
              subtitle: 'Select any credit note to apply.',
              enablePagination: true,
              enableSearch: true,
              searchMatcher: (creditNote, query) {
                return creditNote.searchKey.toLowerCase().contains(
                  query.toLowerCase(),
                );
              },
              itemBuilder: (context, creditNote, selected) =>
                  CollectionUiHelper.of(context).documentTile(
                    selected,
                    true,
                    rowSts: creditNote.rowSts,
                    docCode: creditNote.docCode ?? 'N/A',
                    docNo: creditNote.docNo ?? 'N/A',
                    amount: creditNote.originalAmount.toDouble(),
                    balance: creditNote.balanceAmount.toDouble(),
                    txnDate: creditNote.txnDate ?? 'N/A',
                    locName: creditNote.locName,
                    // discount: invoice.discountPercentage.toDouble(),
                  ),
              separatorBuilder: (context, i) => SizedBox(height: 12),
              canSelect: (creditNote) => creditNote.rowSts == .ENA,
              onMultiSelectChanged: onMultiSelectChanged,
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
              label: 'Total Credit Amount',
              value: NumberHelper.formatCurrency(_displayTotalDiscountAmount),
              valueColor: Colors.green,
            ),
            CollectionUiHelper.of(context).buildSummaryFooterRow(
              label: 'Remaining Balance',
              value: NumberHelper.formatCurrency(
                _displayRemainingInvoiceBalance,
              ),
            ),
            const SizedBox(height: 6),
            AppButton.of(context).filled(
              onPressed: onSave, // onSaveDiscount,
              enabled: canApply, // canSaveDiscount,
              label: _buttonLabel,
            ),
          ],
        ),
      ),
    );

    return AppSliverScaffold(
      scrollController: _mainScrollController,
      appBar: AppBar(
        title: Text('Apply Credit'),
        titleTextStyle: AppTextStyle.of(context).smallAppBar,
        centerTitle: true,
        forceMaterialTransparency: true,
        // automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close_rounded))
        // ],
      ),
      slivers: [
        AppSliverBox(
          padding: const .symmetric(vertical: 16, horizontal: 24),
          child: CollectionUiHelper.of(context).invoiceDetailHeader(
            currentInvoice,
            showDiscount: true,
            showCurrentBalance: false,
            showAppliedDiscount: true,
          ),
        ),
        AppPinnedHeader(
          height: kToolbarHeight * 1.4,
          child: Container(
            height: double.infinity,
            padding: const .fromLTRB(24, 0, 24, 0),
            color: cs.surfaceContainer,
            child: Column(
              spacing: 8,
              mainAxisAlignment: .center,
              children: [
                CollectionUiHelper.of(context).summaryTextRow(
                  'Total Credit Applied',
                  NumberHelper.formatCurrency(_displayTotalDiscountAmount),
                  valueColor: Colors.red,
                ),
                CollectionUiHelper.of(context).summaryTextRow(
                  'Invoice Balance',
                  NumberHelper.formatCurrency(_displayRemainingInvoiceBalance),
                  valueColor: cs.primary,
                  isEmphasized: true,
                ),
              ],
            ),
          ),
        ),
        AppSliverBox(
          padding: const .symmetric(vertical: 16, horizontal: 24),
          child: ModelListView<CreditNoteModel>(
            key: _creditNotesKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            multiSelect: true,
            uniqueKey: (creditNote) => creditNote.id,
            items: creditNotes,
            title: 'Credit Notes',
            subtitle: 'Select any credit note to apply.',
            enablePagination: true,
            enableSearch: true,
            searchMatcher: (creditNote, query) {
              return creditNote.searchKey.toLowerCase().contains(
                query.toLowerCase(),
              );
            },
            itemBuilder: (context, creditNote, selected) =>
                CollectionUiHelper.of(context).documentTile(
                  selected,
                  true,
                  rowSts: creditNote.rowSts,
                  docCode: creditNote.docCode ?? 'N/A',
                  docNo: creditNote.docNo ?? 'N/A',
                  amount: creditNote.originalAmount.toDouble(),
                  balance: creditNote.balanceAmount.toDouble(),
                  txnDate: creditNote.txnDate ?? 'N/A',
                  locName: creditNote.locName,
                  // discount: invoice.discountPercentage.toDouble(),
                ),
            separatorBuilder: (context, i) => SizedBox(height: 12),
            canSelect: (creditNote) => creditNote.rowSts == .ENA,
            onMultiSelectChanged: onMultiSelectChanged,
          ),
        ),
      ],
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
        child: AppButton.of(context).filled(
          onPressed: onSave,
          enabled: canApply,
          label: _buttonLabel,
        ),
      ),
    );
  }

  String get _buttonLabel {
    if (applyingCredit == 0 || amountToApply == 0) {
      return 'Apply Credit';
    }

    return 'Apply [ ${NumberHelper.formatCurrency(amountToApply)} ]';
  }
}
