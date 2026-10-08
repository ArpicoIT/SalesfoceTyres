import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:locafy/locafy.dart';
import 'package:provider/provider.dart';

import '../../helpers/date_time_helper.dart';
import '../../helpers/list_helper.dart';
import '../../helpers/number_helper.dart';
import '../../helpers/responsive.dart';
import '../../models/collection_model.dart';
import '../../models/credit_note_model.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../packages/async_flow/async_flow.dart';
import '../../repositories/api/invoice_api_repository.dart';
import '../../services/database/db_constants.dart';
import '../../services/database/repositories/collection_db_repository.dart';
import '../../services/database/repositories/credit_note_db_repository.dart';
import '../../services/database/repositories/invoice_db_repository.dart';
import '../../shared/components/app/app_dialog.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/app/app_sliver_scaffold.dart';
import '../../shared/components/button/app_button.dart';
import '../../shared/components/button/app_round_button.dart';
import '../../shared/components/form/text_input_field.dart';
import '../../shared/components/list/model_list_view.dart';
import '../../shared/enum.dart';
import '../../shared/widgets/pay_mode_selection.dart';
import '../../utils/formatters/text_input_formatters.dart';
import 'helpers/collection_ui_helper.dart';
import 'notifiers/invoice_setoff_notifier.dart';
import 'widgets/apply_invoice_credit_widget.dart';
import 'widgets/apply_invoice_discount_widget.dart';

class InvoiceSetOffView extends StatefulWidget {
  const InvoiceSetOffView({super.key});

  @override
  State<InvoiceSetOffView> createState() => _InvoiceSetOffViewState();
}

class _InvoiceSetOffViewState extends State<InvoiceSetOffView> {
  /// Scroll controllers
  final _scrollController = ScrollController();

  /// Keys
  final _invoicesKey = GlobalKey<ModelListViewState<InvoiceModel>>();
  final _collectionKey = GlobalKey<ModelListViewState<CollectionSetOffModel>>();
  final _remarkKey = GlobalKey();

  /// Controller
  final remarkController = TextEditingController();

  /// Editing controllers
  final TextEditingController _remarkController = TextEditingController();

  /// Focus nodes
  final _remarkFocus = FocusNode();

  /// Notifiers
  late InvoiceSetOffNotifier notifier;
  final _showFab = ValueNotifier(true);

  /// Variables
  late CustomerModel customer;
  late double receiptAmount;
  late PaymentDetails paymentDetails;

  double receiptBalanceAmount = 0.0;
  bool _isSubmitting = false;
  bool _isAutoScrolling = false;
  bool _hasAutoScrolledToRemarks = false;

  /// Getters
  List<InvoiceModel> get invoices => notifier.invoices;
  List<CreditNoteModel> get creditNotes => notifier.creditNotes;
  List<CollectionSetOffModel> get setOffs => notifier.setOffs;

  InvoiceModel get selectedInvoice => notifier.selectedInvoice;
  bool get hasSetOffs => notifier.setOffs.isNotEmpty;
  double get setOffProgress =>
      ((receiptAmount - receiptBalanceAmount) / receiptAmount) * 100;

  ModelListViewState<InvoiceModel>? get invoicesState =>
      _invoicesKey.currentState;
  ModelListViewState<CollectionSetOffModel>? get collectionState =>
      _collectionKey.currentState;

  /// Constants
  final int negative = -1;

  @override
  void initState() {
    super.initState();

    notifier = InvoiceSetOffNotifier();
    _scrollController.addListener(_onScroll);

    customer = CustomerModel.defaults();
    receiptAmount = 0.0;
    paymentDetails = PaymentDetails();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          debugPrint('Invoice Set-Off: Route arguments are missing');
          return;
        }

        customer = args['customer'] as CustomerModel? ?? customer;
        receiptAmount = args['receiptAmount'] as double? ?? receiptAmount;
        paymentDetails = args['paymentDetails'] as PaymentDetails? ?? paymentDetails;

        final invoices = args['invoices'] as List<InvoiceModel>? ?? [];
        final creditNotes = args['creditNotes'] as List<CreditNoteModel>? ?? [];

        notifier.setInvoices(invoices);
        notifier.setCreditNotes(creditNotes);

        _transformInitialInvoices();

        invoicesState?.refresh();

        receiptBalanceAmount = receiptAmount;

        if (mounted) {setState(() {});}
      } catch (e, stackTrace) {
        debugPrint('Invoice Set-Off: Initialise error: $e\n$stackTrace');
      }
    });
  }

  void _onScroll() {
    _updateFabVisibility();
  }

  void _updateFabVisibility() {
    final context = _remarkKey.currentContext;

    if (context == null) return;

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final position = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;

    final screenHeight = MediaQuery.sizeOf(context).height;

    final remarksTop = position.dy;
    final remarksBottom = remarksTop + size.height;

    final isRemarksVisible = remarksBottom > 0 && remarksTop < screenHeight;

    // Hide/show FAB based on Remarks visibility.
    final shouldShowFab = !isRemarksVisible;

    if (_showFab.value != shouldShowFab) {
      _showFab.value = shouldShowFab;
    }

    // Remarks is completely outside the viewport.
    // Allow auto-scroll again next time.
    if (!isRemarksVisible) {
      _hasAutoScrolledToRemarks = false;
      return;
    }

    // Don't auto-scroll while the user is scrolling UP.
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      return;
    }

    // Already auto-scrolled.
    if (_hasAutoScrolledToRemarks || _isAutoScrolling) {
      return;
    }

    _hasAutoScrolledToRemarks = true;
    _isAutoScrolling = true;

    _jumpToBottom();
  }

  void _jumpToBottom() {
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          _isAutoScrolling = false;
        });
  }

  void _transformInitialInvoices() {
    /// Set row status according conditions.
    ListHelper.transformAll(
      source: invoices,
      updater: (item) {
        if (item.balanceAmount <= 0) {
          return item.copyWith(rowSts: .DIS);
        } else if (item.cashDiscount > 0) {
          return item.copyWith(rowSts: .UNL);
        } else {
          return item.copyWith(rowSts: .LCK);
        }
      },
      setListCallback: notifier.setInvoices,
    );

    /// Unlock the first available invoice.
    final firstAvailableIndex = invoices.indexWhere(
      (invoice) => invoice.balanceAmount > 0,
    );

    if (firstAvailableIndex == -1) {
      debugPrint('No invoice available to unlock.');
      return;
    }

    if (invoices[firstAvailableIndex].rowSts == .LCK) {
      notifier.updateInvoiceAt(
        firstAvailableIndex,
        (item) => item.copyWith(rowSts: .UNL),
      );
    }

    /// For every discounted invoice, unlock the nearest next available invoice.
    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];

      if (invoice.cashDiscount <= 0) {
        continue;
      }

      final nextIndex = invoices.indexWhere(
        (item) => item.balanceAmount > 0,
        i + 1,
      );

      if (nextIndex == -1) {
        continue;
      }

      /// Already unlocked, so no action is needed.
      if (invoices[nextIndex].rowSts == .UNL) {
        continue;
      }

      /// Unlock the nearest available invoice.
      if (invoices[nextIndex].rowSts == .LCK) {
        notifier.updateInvoiceAt(
          nextIndex,
          (item) => item.copyWith(rowSts: .UNL),
        );
      }
    }
  }

  void _transformSelectedInvoice() {
    if (selectedInvoice.balanceAmount > 0) {
      return;
    }

    final currentIndex = invoices.indexWhere(
      (element) => element.id == selectedInvoice.id,
    );

    if (currentIndex == -1) {
      debugPrint('Current invoice was not found in the invoice list.');
      return;
    }

    notifier.updateSelectedInvoice((item) => item.copyWith(rowSts: .DIS));
    notifier.updateInvoiceAt(currentIndex, (item) => selectedInvoice);
  }

  Future<void> _unlockNextInvoiceAfterDiscount() async {
    if (selectedInvoice.currentCashDiscount <= 0 &&
        selectedInvoice.currentBulkDiscount <= 0) {
      debugPrint('Current invoice has no discount. No invoice to unlock.');
      return;
    }

    final currentIndex = invoices.indexWhere(
      (element) => element.id == selectedInvoice.id,
    );

    if (currentIndex == -1) {
      debugPrint('Current invoice was not found in the invoice list.');
      return;
    }

    final nextIndex = currentIndex + 1;

    if (nextIndex >= invoices.length) {
      debugPrint('No next invoice is available to unlock.');
      return;
    }

    final nextInvoice = invoices[nextIndex];

    if (nextInvoice.rowSts != .LCK) {
      debugPrint(
        'Next invoice is not in a lockable state. Current status: ${nextInvoice.rowSts}.',
      );
      return;
    }

    if (nextInvoice.balanceAmount <= 0) {
      debugPrint('Next invoice has no remaining balance. No invoice unlocked.');
      return;
    }

    notifier.updateInvoiceAt(nextIndex, (item) => item.copyWith(rowSts: .UNL));
    notifier.updateInvoiceAt(
      currentIndex,
      (item) => item.copyWith(nextInvoiceUnlockedByGivenDiscount: true),
    );
    debugPrint('Unlocked next invoice: ${nextInvoice.id}.');
  }

  void _unlockFirstNearestInvoice() async {
    if (selectedInvoice.rowSts != .DIS || selectedInvoice.balanceAmount > 0) {
      debugPrint('Current invoice is eligible yet. No invoice to unlock.');
      return;
    }

    final currentIndex = invoices.indexWhere(
      (element) => element.id == selectedInvoice.id,
    );

    if (currentIndex == -1) {
      debugPrint('Current invoice was not found in the invoice list.');
      return;
    }

    for (int i = currentIndex + 1; i < invoices.length; i++) {
      final invoice = invoices[i];

      // Skip disabled or fully settled invoices
      if (invoice.rowSts == RowStatus.DIS || invoice.balanceAmount <= 0) {
        continue;
      }

      // If nearest available invoice is already unlocked, stop
      if (invoice.rowSts == RowStatus.UNL) {
        break;
      }

      // Unlock nearest locked invoice
      if (invoice.rowSts == RowStatus.LCK) {
        notifier.updateInvoiceAt(i, (item) => item.copyWith(rowSts: .UNL));
        debugPrint('Unlocked next invoice: ${invoice.id}.');
      }

      break;
    }
  }

  void onPressedInvoice(BuildContext context, InvoiceModel invoice) async {
    final snackBar = AppSnackBar.instance;

    try {
      notifier.setSelectedInvoice(invoice);

      /// 1. check invoice has discount
      final bool hasDiscount =
          invoice.cashDiscount > 0 || invoice.currentCashDiscount > 0
          ? true
          : await CollectionDbRepository.hasInvoiceDiscountHistory(
              invoice.docCode,
              invoice.docNo,
            );

      /// 2. check customer has credit notes
      final bool hasCreditNotes =
          await CreditNoteDbRepository.hasCreditNotesForCustomer(
            customer!.csCode,
          );

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (context) => ChangeNotifierProvider.value(
          value: notifier,
          child: buildActionSheet(
            context,
            canApplyDiscount: true, //!hasDiscount,
            canApplyCredit: hasCreditNotes,
          ),
        ),
      );
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      _transformSelectedInvoice();
      await _unlockNextInvoiceAfterDiscount();
      _unlockFirstNearestInvoice();
      notifier.clearSelectedInvoice();
      invoicesState
        ?..clearSelection()
        ..refresh();
      if (context.mounted) setState(() {});
    }
  }

  void onLongPressedInvoice(BuildContext context, InvoiceModel invoice) async {
    final shouldUnlock = await context.showConfirmDialog(
      title: 'Unlock Invoice',
      message: 'Are you sure you want to unlock this invoice?',
      content: CollectionUiHelper.of(context).summaryTextRow(
        'Invoice Number',
        '',
        valueChild: Text('${invoice.docCode}${invoice.docNo}'),
      ),
      confirmText: 'Unlock',
    );

    if (shouldUnlock != true) return;

    final engine = AsyncFlowEngine(
      globalTimeout: const Duration(minutes: 10),
      steps: [
        FlowStep(
          id: 'submit',
          title: 'Submit Request',
          initialStage: FlowStage.WAITING,
          execute: () async {
            final currentUser = await IAMService.instance.currentUser();

            // final res = await Future.delayed(
            //   const Duration(seconds: 5),
            //       () => ApiResponse.success(statusCode: 200, data: {'': ''}),
            // );

            final res = await InvoiceApiRepository.requestApproval(
              currentUser,
              customer: customer!,
              invoice: invoice,
            );

            if (res.success) {
              return StepResult(stage: FlowStage.WAITING, payload: res.data);
            } else {
              return StepResult(stage: FlowStage.FAILED, payload: res.data);
            }
          },
        ),

        FlowStep(
          id: 'poll',
          title: 'Check Status',
          initialStage: FlowStage.WAITING,
          recallCount: 40,
          recallDelay: const Duration(seconds: 5),
          execute: () async {
            final res = await InvoiceApiRepository.checkApprovalState(
              invoice.docNo,
            );

            final String? status = res.data?['request_status'];
            if (status == 'APPROVED') {
              return StepResult(stage: FlowStage.SUCCESS, payload: res.data);
            } else if (status == 'REJECTED' || status == 'CANCELLED') {
              return StepResult(stage: FlowStage.FAILED, payload: res.data);
            } else {
              return StepResult(stage: FlowStage.WAITING, payload: res.data);
            }
          },
        ),
      ],
    );

    if (!context.mounted) return;

    final result = await AsyncFlowSheet.open(
      context: context,
      engine: engine,
      title: '${invoice.docCode}${invoice.docNo} Approval Process',
    );

    if (result?.stage == FlowStage.SUCCESS) {
      notifier.updateInvoiceWhere(
        matcher: (item) => item.id == invoice.id,
        updater: (item) => item.copyWith(rowSts: .UNL),
      );
      invoicesState
        ?..clearSelection()
        ..refresh();
      if (context.mounted) setState(() {});
    }
  }

  void onApplyDiscount(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      isDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: notifier,
        child: const ApplyInvoiceDiscountWidget(),
      ),
    );
  }

  void onApplyCredit(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      isDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: notifier,
        child: const ApplyInvoiceCreditWidget(),
      ),
    );
  }

  void onInvoiceSetOff(BuildContext context, {bool canPop = false}) async {
    final confirm = await context.showConfirmDialog(
      title: 'Invoice Set-Off',
      message: 'Do you want to set off selected invoice with receipt balance?',
      content: Column(
        spacing: 8,
        mainAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          CollectionUiHelper.of(context).summaryIconRow(
            'Receipt Balance',
            Icons.receipt_long_outlined,
            '',
            valueChild: Text(NumberHelper.formatCurrency(receiptBalanceAmount)),
          ),
          CollectionUiHelper.of(context).summaryIconRow(
            'Invoice Balance',
            Icons.inventory_outlined,
            '',
            valueChild: Text(
              NumberHelper.formatCurrency(selectedInvoice.balanceAmount),
            ),
          ),
        ],
      ),
      confirmText: 'Yes',
      cancelText: 'No',
    );

    if (confirm != true) {
      return;
    }

    final snackBar = AppSnackBar.instance;

    if (receiptBalanceAmount <= 0) {
      debugPrint('There is no receipt amount available to set off.');
      return;
    }

    final double invBalanceAmount = selectedInvoice.balanceAmount.toDouble();
    final double invSetOffAmount = selectedInvoice.setOffAmount.toDouble();
    late double finalSetOffAmount;

    if (receiptBalanceAmount >= invBalanceAmount) {
      final double invNewSetOffAmount = invBalanceAmount + invSetOffAmount;
      final double invNewBalanceAmount = 0.0;
      finalSetOffAmount = invBalanceAmount * negative;

      /// Update selectedInvoice;
      final updatedInvoice = ListHelper.update<InvoiceModel>(
        source: invoices,
        matcher: (item) => item.id == selectedInvoice.id,
        updater: (item) => item.copyWith(
          balanceAmount: invNewBalanceAmount,
          setOffAmount: invNewSetOffAmount,
          rowSts: .DIS,
        ),
        setListCallback: notifier.setInvoices,
      )!;

      notifier.updateSelectedInvoice((e) => updatedInvoice);

      /// Find and unlock nearest available invoice
      // _getNearestAvailableInvoiceWithUnlocking(updatedInvoice);

      /// Add to collection list
      notifier.addSetOff(
        CollectionSetOffModel(
          recType: DBConstants.DOC_INVOICE,
          recDoc: DBConstants.DOC_RCPD,
          recNo: DBConstants.DOC_RCPD,
          invDoc: selectedInvoice.docCode,
          invNo: selectedInvoice.docNo,
          setOffAmount: finalSetOffAmount,
          createdAt: DateTime.now(),
        ),
      );

      /// Calculate receipt balance
      receiptBalanceAmount -= invBalanceAmount;
    } else {
      final double invNewSetOffAmount = invSetOffAmount + receiptBalanceAmount;
      final double invNewBalanceAmount =
          invBalanceAmount - receiptBalanceAmount;
      finalSetOffAmount = receiptBalanceAmount * negative;

      /// Update selectedInvoice;
      final updatedInvoice = ListHelper.update<InvoiceModel>(
        source: invoices,
        matcher: (item) => item.id == selectedInvoice.id,
        updater: (item) => item.copyWith(
          balanceAmount: invNewBalanceAmount,
          setOffAmount: invNewSetOffAmount,
          // rowSts: .DIS /// keep current status
        ),
        setListCallback: notifier.setInvoices,
      )!;

      notifier.updateSelectedInvoice((e) => updatedInvoice);

      /// Add to collection list
      notifier.addSetOff(
        CollectionSetOffModel(
          recType: DBConstants.DOC_INVOICE,
          recDoc: DBConstants.DOC_RCPD,
          recNo: DBConstants.DOC_RCPD,
          invDoc: selectedInvoice.docCode,
          invNo: selectedInvoice.docNo,
          setOffAmount: finalSetOffAmount,
          createdAt: DateTime.now(),
        ),
      );

      /// Calculate receipt balance
      receiptBalanceAmount = 0.0;
    }

    if (context.mounted) setState(() {});

    if (canPop && context.mounted) {
      Navigator.of(context).pop();
      snackBar.success(
        title: 'Invoice Set-Off',
        message:
            'Invoice set-off of ${NumberHelper.formatCurrency(finalSetOffAmount)} was completed successfully.',
      );
    }
  }

  void onSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    unfocus();

    try {
      final confirm = await _confirmIncompleteSetOffs();

      if (!confirm) return;

      final submitted = await _submitting();

      if (!submitted) return;

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      _isSubmitting = false;
      if (mounted) setState(() {});
    }
  }

  Future<bool> _confirmIncompleteSetOffs() async {
    if (setOffs.isNotEmpty) return true;

    final confirmed = await context.showConfirmDialog(
      title: 'No Set-Offs Added',
      message:
          'No set-offs have been added to this collection. '
          'Do you want to continue without adding any set-offs?',
      confirmText: 'Yes, Continue',
      cancelText: 'No',
    );

    return confirmed == true;
  }

  Future<bool> _submitting() async {
    final snackBar = AppSnackBar.instance;
    final loader = AppLoader.instance;

    try {
      loader.show();

      final position = await Locafy.instance.requestWithConfirmation(context);

      final currentUser = await IAMService.instance.currentUser();

      final header = CollectionHeaderModel(
        sbuCode: currentUser.sbuCode ?? '',
        locCode: currentUser.locCode ?? '',
        docCode: DBConstants.DOC_RCPD,
        docNo: NumberHelper.getSerialNumber(currentUser.tabCode),
        txnDate: DateTimeHelper.getTxnDate(),
        synSts: SyncStatus.PEND,
        csCode: customer!.csCode,
        payMode: paymentDetails!.payMode!,
        totalAmount: receiptAmount,
        chqNo: paymentDetails!.chqNumber,
        chqDate: paymentDetails!.chqDate,
        bankCode: paymentDetails!.bank?.bankCode,
        branchCode: paymentDetails!.branch?.branchCode,
        ddRefNo: paymentDetails!.ddRefNumber,
        remark: _remarkController.text,
        gpsLat: position.latitude,
        gpsLng: position.longitude,
        createdBy: currentUser.userId ?? '',
        createdAt: DateTimeHelper.getDateTime(),
        tabCode: currentUser.tabCode,
      );

      final details = setOffs
          .map(
            (e) => CollectionDetailModel(
              sbuCode: header.sbuCode,
              locCode: header.locCode,
              docCode: header.docCode,
              docNo: header.docNo,
              seqNo: e.seq ?? -1,
              recDoc: e.recDoc,
              recNo: e.recNo,
              invDoc: e.invDoc,
              invNo: e.invNo,
              setOffAmount: e.setOffAmount.toDouble(),
              discount: e.discount.toDouble(),
              txnDate: header.txnDate,
              synSts: SyncStatus.PEND,
              createdBy: header.createdBy,
              createdAt: DateTimeHelper.getDateTime(),
            ),
          )
          .toList();

      final insertResult = await CollectionDbRepository.insertCollection(
        header,
        details,
      );

      await InvoiceDbRepository.updateSetOffs(invoices);

      await CreditNoteDbRepository.updateSetOffs(creditNotes);

      snackBar.success(
        title: 'Payment Collection Submitted',
        message:
            'Payment collection was successfully submitted. '
            'Document No: ${insertResult.header.docNo}',
      );

      return true;
    } catch (e) {
      snackBar.error(message: e.toString());
      debugPrint("ERROR: Collection Save: ${e.toString()}");
      return false;
    } finally {
      loader.hide();
      if (mounted) setState(() {});
    }
  }

  void unfocus() {
    _remarkFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ChangeNotifierProvider.value(
      value: notifier,
      builder: (context, child) {
        return PopScope(
          canPop: !hasSetOffs,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop || !hasSetOffs) {
              return;
            }

            final shouldLeave = await context.showConfirmDialog(
              title: 'Leave Set-Offs?',
              message:
                  'You have added set-offs to this collection. '
                  'Leaving this page will remove all unsaved set-offs. '
                  'Are you sure you want to leave?',
              confirmText: 'Leave',
              cancelText: 'Stay',
              confirmColor: Theme.of(context).colorScheme.error,
            );

            if (shouldLeave != true) return;

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: AppSliverScaffold(
            scrollController: _scrollController,
            title: 'Invoice Set-Off',
            slivers: [
              AppPinnedHeader(
                height: kToolbarHeight * 2.8,
                child: Container(
                  height: double.infinity,
                  padding: const .fromLTRB(24, 0, 24, 0),
                  color: cs.surfaceContainerLow,
                  child: CollectionUiHelper.of(context).receiptSummaryHeader(
                    customer: customer,
                    paymentDetails: paymentDetails,
                    receiptAmount: receiptAmount,
                    setOffAmount:
                        (receiptAmount - receiptBalanceAmount) * negative,
                  ),
                ),
              ),
              // AppSliverBox(
              //   padding: const .fromLTRB(24, 24, 24, 0),
              //   child: CollectionUiHelper.of(
              //     context,
              //   ).receiptProgressCard(setOffProgress.abs()),
              // ),
              AppSliverBox(
                padding: const .fromLTRB(24, 24, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: ModelListView<InvoiceModel>(
                    key: _invoicesKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    singleSelect: true,
                    uniqueKey: (invoice) => invoice.id,
                    items: invoices,
                    title: 'Invoices',
                    subtitle: 'Select an invoice to proceed with set-off.',
                    enablePagination: true,
                    enableSearch: true,
                    searchMatcher: (invoice, query) => invoice.searchKey
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                    itemBuilder: (context, invoice, selected) =>
                        CollectionUiHelper.of(context).documentTile(
                          selected,
                          false,
                          rowSts: invoice.rowSts,
                          docCode: invoice.docCode ?? 'N/A',
                          docNo: invoice.docNo ?? 'N/A',
                          amount: invoice.originalAmount.toDouble(),
                          balance: invoice.balanceAmount.toDouble(),
                          txnDate: invoice.txnDate ?? 'N/A',
                          locName: invoice.locName,
                          cashDiscount: invoice.cashDiscount.toDouble(),
                          currentCashDiscount: invoice.currentCashDiscount
                              .toDouble(),
                          bulkDiscount: invoice.bulkDiscount.toDouble(),
                          currentBulkDiscount: invoice.currentBulkDiscount
                              .toDouble(),
                        ),
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 12),
                    canSelect: (invoice) => invoice.rowSts == .UNL,
                    onTap: (invoice, selected) {
                      if (invoice.rowSts != .UNL) {
                        return;
                      }
                      onPressedInvoice(context, invoice);
                    },

                    onLongPress: (invoice, selected) {
                      if (invoice.rowSts != .LCK) {
                        return;
                      }
                      onLongPressedInvoice(context, invoice);
                    },
                  ),
                ),
              ),
              AppSliverBox(child: SizedBox(height: 36)),
              AppSliverBox(
                // padding: const .fromLTRB(24, 24, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const .all(24),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          spacing: 24,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.width * 0.5,
                              ),
                              child: ModelListView<CollectionSetOffModel>(
                                title: 'Collection Details',
                                subtitle:
                                    'Review credit note allocations, discounts, and receipt set-offs before submitting.',
                                key: _collectionKey,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                multiSelect: true,
                                uniqueKey: (setOff) => setOff.seq,
                                items: setOffs,
                                enablePagination: true,
                                enableSearch: true,
                                searchMatcher: (setOff, query) => setOff
                                    .searchKey
                                    .toLowerCase()
                                    .contains(query.toLowerCase()),
                                itemBuilder: (context, setOff, selected) {
                                  return CollectionUiHelper.of(
                                    context,
                                  ).setOffTile(setOff, true, onRemove: null);
                                },
                                separatorBuilder: (context, i) =>
                                    SizedBox(height: 12),
                                canSelect: (setOff) => false,
                                // onMultiSelectChanged: onMultiSelectChanged,
                              ),
                            ),
                            TextInputField(
                              key: _remarkKey,
                              controller: _remarkController,
                              focusNode: _remarkFocus,
                              hint: 'Add your remark here',
                              maxLines: 7,
                              minLines: 5,
                              maxLength: 250,
                              inputFormatters:
                                  TextInputFormatters.noteFormatter(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: .infinity,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          color: cs.surface,
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: .symmetric(vertical: 12, horizontal: 24),
                        child: AppButton.of(context).filled(
                          onPressed: onSubmit,
                          label: 'Submit Collection',
                          loading: _isSubmitting,
                          loadingLabel: 'Submitting...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () => onSubmitCollection(context),
            //   label: Row(
            //     children: [
            //       Text('Submit Collection'),
            //       Icon(Icons.navigate_next_rounded),
            //     ],
            //   ),
            //   shape: RoundedRectangleBorder(borderRadius: .circular(12)),
            //   backgroundColor: cs.primary,
            //   foregroundColor: cs.onPrimary,
            // ),
            // No setState required here.
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: _showFab,
              builder: (context, showFab, child) {
                if (!showFab) {
                  return const SizedBox.shrink();
                }

                return FloatingActionButton.extended(
                  onPressed: _jumpToBottom,
                  label: Row(
                    children: [
                      Text('Submit Collection'),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                  shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                );
              },
            ),
            // bottomNavigationBar: Container(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surface,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Theme.of(
            //           context,
            //         ).colorScheme.primary.withValues(alpha: 0.12),
            //         blurRadius: 8,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   padding: .symmetric(vertical: 12, horizontal: 24),
            //   child: AppButton.of(context).filled(
            //       onPressed: onSubmit,
            //       label: 'Submit Collection',
            //       loading: _isSubmitting,
            //       loadingLabel: 'Submitting...'
            //   ),
            // ),
          ),
        );
      },
    );
  }

  Widget buildActionSheet(
    BuildContext context, {
    required bool canApplyDiscount,
    required bool canApplyCredit,
  }) {
    return Builder(
      builder: (context) {
        notifier = context.watch<InvoiceSetOffNotifier>();

        /// check Invoice and receipt has available balance in every update
        final canSetOff =
            receiptBalanceAmount > 0 &&
            notifier.selectedInvoice.balanceAmount > 0;

        final isPhone = Responsive.of(context).isPhone;

        final actions = <Widget>[
          isPhone
              ? AppButton.of(context).tonal(
                  onPressed: () => onApplyDiscount(context),
                  label: 'Apply Discount',
                  icon: Icons.discount,
                  enabled: canApplyDiscount,
                )
              : AppRoundButton.of(context).tonal(
                  onPressed: () => onApplyDiscount(context),
                  label: 'Apply Discount',
                  icon: Icons.discount_rounded,
                  enabled: canApplyDiscount,
                ),

          isPhone
              ? AppButton.of(context).outlined(
                  onPressed: () => onApplyCredit(context),
                  label: 'Apply Credit',
                  icon: Icons.credit_card,
                  enabled: canApplyCredit,
                )
              : AppRoundButton.of(context).outlined(
                  onPressed: () => onApplyCredit(context),
                  label: 'Apply Credit',

                  icon: Icons.credit_card_rounded,
                  enabled: canApplyCredit,
                ),

          isPhone
              ? AppButton.of(context).filled(
                  onPressed: () => onInvoiceSetOff(context, canPop: true),
                  label: 'Invoice Set-Off',
                  icon: Icons.receipt_long,
                  enabled: canSetOff,
                )
              : AppRoundButton.of(context).filled(
                  onPressed: () => onInvoiceSetOff(context, canPop: true),
                  label: 'Invoice Set-Off',

                  icon: Icons.receipt_long_rounded,
                  enabled: canSetOff,
                ),
        ];

        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const .all(24),
            child: Column(
              mainAxisSize: .min,
              spacing: 24,
              children: [
                CollectionUiHelper.of(context).invoiceDetailHeader(
                  selectedInvoice,
                  showDiscount: true,
                  showCurrentBalance: true,
                  showAppliedDiscount: true,
                  showAppliedCreditAmount: true,
                ),

                Divider(height: 0),

                isPhone
                    ? Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .stretch,
                        spacing: 16,
                        children: actions,
                      )
                    : Row(
                        mainAxisSize: .max,
                        mainAxisAlignment: .spaceEvenly,
                        spacing: 28,
                        children: actions,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    notifier.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _remarkController.dispose();
    _showFab.dispose();
    super.dispose();
  }
}

// class InvoiceAction extends StatelessWidget {
//   const InvoiceAction({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) {
//         notifier = context.watch<InvoiceSetOffNotifier>();
//
//         /// check Invoice and receipt has available balance in every update
//         final canSetOff =
//             receiptBalanceAmount > 0 &&
//                 notifier.selectedInvoice.balanceAmount > 0;
//
//         final isPhone = Responsive.of(context).isPhone;
//
//         final actions = <Widget>[
//           isPhone
//               ? AppButton.of(context).tonal(
//             onPressed: () => onApplyDiscount(context),
//             label: 'Apply Discount',
//             icon: Icons.discount,
//             enabled: canApplyDiscount,
//           )
//               : AppRoundButton.of(context).tonal(
//             onPressed: () => onApplyDiscount(context),
//             label: 'Apply Discount',
//             icon: Icons.discount_rounded,
//             enabled: canApplyDiscount,
//           ),
//
//           isPhone
//               ? AppButton.of(context).outlined(
//             onPressed: () => onApplyCredit(context),
//             label: 'Apply Credit',
//             icon: Icons.credit_card,
//             enabled: canApplyCredit,
//           )
//               : AppRoundButton.of(context).outlined(
//             onPressed: () => onApplyCredit(context),
//             label: 'Apply Credit',
//
//             icon: Icons.credit_card_rounded,
//             enabled: canApplyCredit,
//           ),
//
//           isPhone
//               ? AppButton.of(context).filled(
//             onPressed: () => onInvoiceSetOff(context, canPop: true),
//             label: 'Invoice Set-Off',
//             icon: Icons.receipt_long,
//             enabled: canSetOff,
//           )
//               : AppRoundButton.of(context).filled(
//             onPressed: () => onInvoiceSetOff(context, canPop: true),
//             label: 'Invoice Set-Off',
//
//             icon: Icons.receipt_long_rounded,
//             enabled: canSetOff,
//           ),
//         ];
//
//         return Material(
//           color: Colors.transparent,
//           child: Padding(
//             padding: const .all(24),
//             child: Column(
//               mainAxisSize: .min,
//               spacing: 24,
//               children: [
//                 CollectionUiHelper.of(context).invoiceDetailHeader(
//                   selectedInvoice,
//                   showDiscount: true,
//                   showCurrentBalance: true,
//                   showAppliedDiscount: true,
//                   showAppliedCreditAmount: true,
//                 ),
//
//                 Divider(height: 0),
//
//                 isPhone
//                     ? Column(
//                   mainAxisSize: .min,
//                   crossAxisAlignment: .stretch,
//                   spacing: 16,
//                   children: actions,
//                 )
//                     : Row(
//                   mainAxisSize: .max,
//                   mainAxisAlignment: .spaceEvenly,
//                   spacing: 28,
//                   children: actions,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

///
// void onViewPayMode(BuildContext context) async {
//   await showModalBottomSheet(
//     context: context,
//     useSafeArea: true,
//     showDragHandle: true,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(24),
//       ),
//     ),
//     clipBehavior: Clip.antiAlias,
//     builder: (context) => buildPaymentDetailSheet(context, paymentDetails!),
//   );
// }
///
// Widget buildPaymentDetailSheet(
//   BuildContext context,
//   PayModeSelectionModel details,
// ) {
//   return Material(
//     color: Colors.transparent,
//     child: Container(
//       width: double.infinity,
//       padding: const .all(24),
//       child: ResponsiveGrid(
//         tabletColumns: 2,
//         desktopColumns: 3,
//         spacing: 12,
//         children: [
//           CollectionUiHelper.of(context).summaryBox(
//             'Payment Mode',
//             Icons.receipt_long_rounded,
//             details.payMode.label,
//             isFilled: true,
//           ),
//
//           if (details.payMode == .cheque) ...[
//             CollectionUiHelper.of(context).summaryBox(
//               'Cheque Number',
//               Icons.receipt_long_rounded,
//               details.chqNumber ?? 'N/A',
//             ),
//             CollectionUiHelper.of(context).summaryBox(
//               'Cheque Date',
//               Icons.calendar_today_rounded,
//               details.chqDate ?? 'N/A',
//             ),
//             CollectionUiHelper.of(context).summaryBox(
//               'Bank Name',
//               Icons.account_balance_rounded,
//               details.bank?.bankName ?? 'N/A',
//             ),
//             CollectionUiHelper.of(context).summaryBox(
//               'Branch Name',
//               Icons.account_balance_outlined,
//               details.branch?.branchName ?? 'N/A',
//             ),
//           ],
//
//           if (details.payMode == .ddCash || details.payMode == .ddCheque) ...[
//             CollectionUiHelper.of(context).summaryBox(
//               'Reference Number',
//               Icons.tag_rounded,
//               details.ddRefNumber ?? 'N/A',
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }
