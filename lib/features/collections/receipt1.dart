import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import '../../app/exceptions/app_exception.dart';
import '../../app/route_paths.dart';
import '../../helpers/list_helper.dart';
import '../../helpers/number_helper.dart';
import '../../models/credit_note_model.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../services/database/repositories/collection_db_repository.dart';
import '../../services/database/repositories/credit_note_db_repository.dart';
import '../../services/database/repositories/customer_db_repository.dart';
import '../../services/database/repositories/invoice_db_repository.dart';
import '../../services/database/repositories/sync_db_repository.dart';
import '../../services/database/repositories/system_file_db_repository.dart';
import '../../shared/components/app/app_alert.dart';
import '../../shared/components/app/app_dialog.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';
import '../../shared/components/form/async_search_picker.dart';
import '../../shared/components/form/banking_amount_field.dart';
import '../../shared/components/form/responsive_form_field.dart';
import '../../shared/widgets/pay_mode_selection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Receipt1 extends StatefulWidget {
  const Receipt1({super.key});

  @override
  State<Receipt1> createState() => _CollectionsViewNewState();
}

class _CollectionsViewNewState extends State<Receipt1> {
  /// Main
  final _mainScrollController = ScrollController();

  /// Keys
  final _payModeKey = GlobalKey<PayModeSelectionState>();
  final _payModeKey2 = GlobalKey<PayModeSelectionState>();

  /// Controllers
  final _receiptAmountController = TextEditingController();

  /// Focus nods
  final _customerFocus = FocusNode();
  final _receiptAmountFocus = FocusNode();
  final _payModeFocus = FocusNode();

  /// Variables
  double? _maxCashLimit;
  CustomerModel? _selectedCustomer;
  PaymentDetails _paymentDetails = PaymentDetails();
  bool _isStarting = false;
  String _error = '';

  /// Getters
  double get receiptAmount => NumberHelper.parseAmountFormatToDouble(
    _receiptAmountController.text,
  );
  double get maxCashLimit => _maxCashLimit ?? 0;
  bool get shouldApplyCashLimit => _paymentDetails.payMode == .cash;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMaxCashLimit();
      if (mounted) setState(() {});

      // final currentUser = await IAMService.instance.currentUser();
      // await DBHelper.batchInsert(
      //   DBTables.COLLECTION_DETAILS,
      //     [CollectionDetailModel(
      //       sbuCode: currentUser.sbuCode,
      //       locCode: currentUser.locCode,
      //       docCode: 'TYR${DateTime.now().millisecond}',
      //       docNo: 'RCPD',
      //       seqNo: 1,
      //       recDoc: 'BULKDISC',
      //       recNo: 'BULKDISC',
      //       invDoc: 'NVAT',
      //       invNo: '758870',
      //       setOffAmount: -50000.0,
      //       discount: 3.9,
      //       txnDate: DateTimeHelper.getTxnDate(),
      //       createdBy: currentUser.userId,
      //       createdAt: DateTime.now(),
      //     ).toSqlJson()].toList()
      // );

    });
  }

  Future<List<CustomerModel>> _fetchCustomers() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      return await CustomerDbRepository.getAllCustomers(currentUser);
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  Future<List<InvoiceModel>> _loadCustomerInvoices(
      CustomerModel customer,
      ) async {
    final snackBar = AppSnackBar.instance;
    // final loader = AppLoader.instance;

    try {
      // loader.show();
      final currentUser = await IAMService.instance.currentUser();

      if (customer.csCode == null) {
        throw AppException.validationCustomerNotSelected();
      }

      List<InvoiceModel> dataSource =
      await InvoiceDbRepository.getCustomerInvoicesWithJoinedDiscounts(
        currentUser,
        csCode: customer.csCode!,
      );

      ListHelper.transformAll<InvoiceModel>(
        source: dataSource,
        updater: (item) => item.copyWith(
          balanceAmount: item.dueAmount.toDouble(),
          setOffAmount:
          item.originalAmount.toDouble() - item.dueAmount.toDouble(),
        ),
        setListCallback: (list) => dataSource = list,
      );

      ListHelper.sortByDate<InvoiceModel>(
        dataSource,
            (item) => DateTime.tryParse(item.txnDate ?? ''),
      );
      return dataSource;
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      // loader.hide();
    }

    return [];
  }

  Future<List<CreditNoteModel>> _loadCustomerCreditNotes(
      CustomerModel customer,
      ) async {
    final snackBar = AppSnackBar.instance;
    // final loader = AppLoader.instance;

    try {
      // loader.show();
      final currentUser = await IAMService.instance.currentUser();

      if (customer.csCode == null) {
        throw AppException.validationCustomerNotSelected();
      }

      List<CreditNoteModel> dataSource =
      await CreditNoteDbRepository.getCustomerCreditNotes(
        currentUser,
        csCode: customer.csCode!,
      );

      ListHelper.transformAll<CreditNoteModel>(
        source: dataSource,
        updater: (item) => item.copyWith(
          balanceAmount: item.dueAmount.toDouble(),
          setOffAmount:
          item.originalAmount.toDouble() - item.dueAmount.toDouble(),
        ),
        setListCallback: (list) => dataSource = list,
      );

      ListHelper.sortByDate<CreditNoteModel>(
        dataSource,
            (item) => DateTime.tryParse(item.txnDate ?? ''),
      );

      return dataSource;
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      // loader.hide();
    }

    return [];
  }

  Future<void> _loadMaxCashLimit() async {
    final limit = await SystemFileDbRepository.getMaxCashLimit();
    _maxCashLimit = null;

    if (limit == null) {
      _error = 'Maximum cash limit not available.';
      return;
    }

    _maxCashLimit = limit;
  }

  // Future<List<InvoiceModel>> _restoreInvoiceDiscounts(
  //   List<InvoiceModel> invoices,
  // ) async {
  //   if (invoices.isEmpty) {
  //     return [];
  //   }
  //
  //   try {
  //     final updatedInvoices = List<InvoiceModel>.of(invoices);
  //
  //     for (var i = 0; i < updatedInvoices.length; i++) {
  //       final invoice = updatedInvoices[i];
  //
  //       if(invoice.cashDiscount <= 0){
  //
  //       }
  //
  //       if(invoice.cashDiscount <= 0){
  //
  //       }
  //
  //       if (invoice.cashDiscount > 0) {
  //         continue;
  //       }
  //
  //       double value =
  //           await CollectionDbRepository.getInvoiceDiscountPercentage(
  //             invoice.docCode!,
  //             invoice.docNo!,
  //           );
  //
  //       if (value == 0) {
  //         continue;
  //       }
  //
  //       updatedInvoices[i] = invoice.copyWith(cashDiscount: value);
  //
  //       debugPrint(
  //         'Invoice ${invoice.id}: restored discount percentage '
  //         'to ${value.toDouble()}.',
  //       );
  //     }
  //
  //     return updatedInvoices;
  //   } catch (e) {
  //     debugPrint('Failed to restore invoice discounts: $e');
  //   }
  //
  //   return [];
  // }

  Future<bool> _canContinueStart() async {
    return switch (_paymentDetails.payMode) {
          .cheque => _validateDuplicateCheque(),
          .cash => _validateDuplicateCash(),
      _ => true,
    };
  }

  Future<bool> _validateDuplicateCheque() async {
    final chequeNo = _paymentDetails.chqNumber ?? '';
    final bankCode = _paymentDetails.bank?.bankCode ?? '';

    final duplicates =
    await CollectionDbRepository.getDuplicateChequeCollections(bankCode, chequeNo);

    if (duplicates.isEmpty) return true;

    const title = 'Duplicate Cheque Collection';
    final message =
        'Cheque No. $chequeNo has already been collected previously. Please verify the cheque number before continuing.';

    if (!mounted) {
      AppSnackBar.instance.error(
        title: title,
        message: message,
      );
      return false;
    }

    await context.showAlertDialog(
      type: .error,
      title: title,
      message: message,
    );

    return false;
  }

  Future<bool> _validateDuplicateCash() async {
    final duplicates =
    await CollectionDbRepository.getDuplicateCashCollections(
      csCode: _selectedCustomer!.csCode!,
      amount: receiptAmount,
    );

    if (duplicates.isEmpty) return true;

    const title = 'Duplicate Cash Collection';
    final message =
        'A cash collection of ${NumberHelper.formatCurrency(receiptAmount)} '
        'has already been recorded for this customer. '
        'Do you want to continue anyway?';

    if (!mounted) {
      AppSnackBar.instance.error(
        title: title,
        message: message,
      );
      return false;
    }

    final confirmed = await context.showConfirmDialog(
      type: .error,
      title: title,
      message: message,
      confirmText: 'Yes, Continue',
      cancelText: 'No',
    );

    return confirmed == true;
  }

  void onChangedCustomer(CustomerModel? value) async {
    _clearForm();
    _selectedCustomer = value;
    if (mounted) setState(() {});
  }

  void onChangedPayMode(PaymentDetails value) {
    _paymentDetails = value;
    _receiptAmountController.clear();
    if(mounted) setState(() {});
  }

  void onTapDownloadInAlert() async {
    await Navigator.of(context).pushNamed(RoutePaths.downloads);
    await _loadMaxCashLimit();
    _receiptAmountController.clear();
    // _updateCashDiscountController();
    if (mounted) setState(() {});
  }

  void onTapStart() async {
    final snackBar = AppSnackBar.instance;

    bool isValidate = _validateForm(
      customer: _selectedCustomer,
      receiptAmount: receiptAmount,
      receiptBalance: receiptAmount,
      payMode: _paymentDetails,
    );

    if (!isValidate) {
      return;
    }

    if (!await _canContinueStart()) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      final invoices = await _loadCustomerInvoices(_selectedCustomer!);
      // final restoredInvoices = await _restoreInvoiceDiscounts(invoices);

      final creditNotes = await _loadCustomerCreditNotes(_selectedCustomer!);

      if (!mounted) return;

      final completed = await Navigator.of(context).pushNamed(RoutePaths.receiptSetOff, arguments: {
        'customer': _selectedCustomer,
        'receiptAmount': receiptAmount,
        'paymentDetails': _paymentDetails,
        'invoices': invoices,
        'creditNotes': creditNotes,
      });

      if (completed == true) {
        _clearForm();
        SyncDbRepository.collectionHeaders();
        SyncDbRepository.collectionDetails();
      }
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      debugPrint("Receipt Set-Off end");
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  void onTapCancel() {
    unfocus();
    _clearForm();
    if (mounted) setState(() {});
  }

  void unfocus() {
    _customerFocus.unfocus();
    _receiptAmountFocus.unfocus();
    _payModeFocus.unfocus();
    _payModeKey.currentState?.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _clearForm() {
    _selectedCustomer = null;
    _receiptAmountController.clear();
    _paymentDetails = PaymentDetails();
    _payModeKey.currentState?.reset();
  }

  bool _validateForm({
    required CustomerModel? customer,
    required double? receiptAmount,
    required double? receiptBalance,
    required PaymentDetails payMode,
  }) {
    final snackBar = AppSnackBar.instance;

    if (customer == null) {
      snackBar.error(
        title: 'Customer Not Selected',
        message: 'Please select a customer to continue.',
      );
      return false;
    }

    if (payMode.payMode == .none) {
      snackBar.error(
        title: 'Payment Mode Required',
        message: 'Please select a payment mode to continue.',
      );
      return false;
    }

    if (payMode.payMode == .cheque) {
      if (payMode.chqNumber == null || payMode.chqNumber!.isEmpty) {
        snackBar.error(
          title: 'Cheque Number Required',
          message: 'Please enter the cheque number.',
        );
        return false;
      }
      if (payMode.chqDate == null || payMode.chqDate!.isEmpty) {
        snackBar.error(
          title: 'Cheque Date Required',
          message: 'Please select the cheque date.',
        );
        return false;
      }
      if (payMode.bank == null) {
        snackBar.error(
          title: 'Bank Required',
          message: 'Please select the cheque bank.',
        );
        return false;
      }
      if (payMode.branch == null) {
        snackBar.error(
          title: 'Branch Required',
          message: 'Please select the cheque bank branch.',
        );
        return false;
      }
    }

    if (payMode.payMode == .ddCash || payMode.payMode == .ddCheque) {
      if (payMode.ddRefNumber == null || payMode.ddRefNumber!.isEmpty) {
        snackBar.error(
          title: 'DD Reference Required',
          message: 'Please enter the DD reference number.',
        );
        return false;
      }
    }

    if (receiptAmount == null) {
      snackBar.error(
        title: 'Receipt Amount Required',
        message: 'Please enter a receipt amount to continue.',
      );
      return false;
    }

    if (receiptAmount <= 0) {
      snackBar.error(
        title: 'Invalid Receipt Amount',
        message: 'Please enter a receipt amount greater than 0.',
      );
      return false;
    }

    if (receiptBalance == null) {
      snackBar.error(
        title: 'Invalid Receipt Balance',
        message: 'Unable to determine the receipt balance.',
      );
      return false;
    }

    if (receiptBalance < 0) {
      snackBar.error(
        title: 'Invalid Receipt Balance',
        message: 'Receipt balance cannot be negative.',
      );
      return false;
    }

    if(shouldApplyCashLimit){
      if (receiptAmount > maxCashLimit) {
        snackBar.error(
          title: 'Invalid Receipt Amount',
          message: 'Receipt amount cannot exceed the maximum allowed cash amount.',
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppScaffold(
      defaultPadding: false,
      defaultResponsive: true,
      contentPadding: .all(24),
      scrollController: _mainScrollController,
      scrollableBody: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
          Text('Receive customer payments today', style: tt.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Select a customer, add the payment amount, and choose the payment method.',
            style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
          buildPaymentDetailsSection(),
          const SizedBox(height: 48),
          AppButton.of(context).filled(
            onPressed: onTapStart,
            label: 'Start Collection',
            loadingLabel: '', // Starting...
            icon: Icons.arrow_forward_rounded,
            iconAlignment: .end,
            loading: _isStarting,
          ),
          const SizedBox(height: 24),
          AppButton.of(context).text(
            onPressed: onTapCancel,
            label: 'Cancel',
            enabled: !_isStarting,
          ),
        ],
      ),
      onTapBackground: unfocus,
    );
  }

  Widget buildPaymentDetailsSection() {
    return Card(
      margin: .zero,
      shape: RoundedRectangleBorder(borderRadius: .circular(18)),
      child: Padding(
        padding: const .symmetric(vertical: 24, horizontal: 16),
        child: Column(
          spacing: 16,
          children: [
            ResponsiveFormField(
              title: 'Customer',
              child: AsyncSearchPicker<CustomerModel>(
                filled: false,
                selectedItem: _selectedCustomer,
                focusNode: _customerFocus,
                searchKey: (item) => item.searchKey,
                displayText: (item) => item.displayText,
                onChanged: onChangedCustomer,
                hint: 'Select customer',
                loadItems: _fetchCustomers,
              ),
            ),

            ResponsiveFormField(
              title: 'Payment Mode',
              child: PayModeSelection.bottomSheet(
                key: _payModeKey,
                focusNode: _payModeFocus,
                filled: false,
                onChanged: onChangedPayMode,
              ),
            ),

            ResponsiveFormField(
              title: 'Receipt Amount',
              child: BankingAmountField(
                filled: false,
                controller: _receiptAmountController,
                focusNode: _receiptAmountFocus,
                maxLength: 20,
                maxAmount: shouldApplyCashLimit ? maxCashLimit : null,
                // onChanged: (amount) {
                //   debugPrint(
                //     'Amount: $amount | Controller: ${_rcpdAmountCtrl.text}',
                //   );
                // },
              ),
            ),

            if(shouldApplyCashLimit) ...[
              if(_maxCashLimit == null)
                AppAlert.error(
                  title: 'Cash Limit Not Available',
                  message:
                  'Please download the latest cash limit before entering a receipt amount.',
                  note: 'Downloads → System Files',
                  actionText: 'Download',
                  onAction: onTapDownloadInAlert,
                )
              else
                AppAlert.info(message: 'The maximum allowed cash amount is **${NumberHelper.formatCurrency(maxCashLimit)}**'),
            ],
          ],
        ),
      ),
    );
  }
}
