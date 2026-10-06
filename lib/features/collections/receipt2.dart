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

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class Customer {
  final String id;
  final String name;
  final double outstanding;
  const Customer(this.id, this.name, this.outstanding);
}

enum PayMode {
  cash('Cash', Icons.payments_outlined),
  cheque('Cheque', Icons.edit_note_rounded),
  card('Card', Icons.credit_card_rounded),
  transfer('Transfer', Icons.account_balance_rounded);

  final String label;
  final IconData icon;
  const PayMode(this.label, this.icon);
}

class PaymentReceipt {
  final Customer customer;
  final PayMode mode;
  final double amount;
  final String? reference;
  final String? chequeNo;
  final DateTime? chequeDate;
  final String? bank;
  final String? branch;
  const PaymentReceipt({
    required this.customer,
    required this.mode,
    required this.amount,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.bank,
    this.branch,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String money(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
  );
  return '$whole.${parts[1]}';
}

String fmtDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ReceivePaymentScreen extends StatefulWidget {
  final List<Customer> customers;
  final Map<String, List<String>> banks; // bank -> branches
  final ValueChanged<PaymentReceipt>? onSubmit;

  const ReceivePaymentScreen({
    super.key,
    required this.customers,
    required this.banks,
    this.onSubmit,
  });

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  /// Main
  final _mainScrollController = ScrollController();

  /// Keys
  final _paymentDetailKey = GlobalKey<PayModeSelectionState>();
  final _formKey = GlobalKey<FormState>();

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

  /// Constants
  static const double _tabletBreakpoint = 720;

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

  void onChangedCustomer(CustomerModel? value) async {
    // _clearForm();
    _selectedCustomer = value;
    if (mounted) setState(() {});
  }






  final _amount = TextEditingController();
  final _chequeNo = TextEditingController();
  final _chequeDateCtrl = TextEditingController();
  final _reference = TextEditingController();

  Customer? _customer;
  PayMode _mode = PayMode.cash;
  DateTime? _chequeDate;
  String? _bank;
  String? _branch;

  double get _amountValue => double.tryParse(_amount.text) ?? 0;
  double get _balanceAfter =>
      ((_customer?.outstanding ?? 0) - _amountValue).clamp(0, double.infinity);

  @override
  void dispose() {
    _amount.dispose();
    _chequeNo.dispose();
    _chequeDateCtrl.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? now,
      firstDate: now.subtract(const Duration(days: 180)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _chequeDate = picked;
        _chequeDateCtrl.text = fmtDate(picked);
      });
    }
  }

  void _setAmount(double v) {
    _amount.text = v.toStringAsFixed(2);
    setState(() {});
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit?.call(PaymentReceipt(
      customer: _customer!,
      mode: _mode,
      amount: _amountValue,
      reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
      chequeNo: _mode == PayMode.cheque ? _chequeNo.text.trim() : null,
      chequeDate: _mode == PayMode.cheque ? _chequeDate : null,
      bank: _mode == PayMode.cheque ? _bank : null,
      branch: _mode == PayMode.cheque ? _branch : null,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Receipt saved · LKR ${money(_amountValue)}'),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receive payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              'Today, ${fmtDate(DateTime.now())}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= _tabletBreakpoint;
          final form = Form(key: _formKey, child: _buildFormSections());

          if (!wide) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: form,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: form,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 340,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: _SummaryPanel(
                    customer: _customer,
                    mode: _mode,
                    amount: _amountValue,
                    balanceAfter: _balanceAfter,
                    onSave: _save,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: LayoutBuilder(builder: (context, _) {
        final wide = MediaQuery.sizeOf(context).width >= _tabletBreakpoint;
        if (wide) return const SizedBox.shrink();
        return _MobileActionBar(total: _amountValue, onSave: _save);
      }),
    );
  }

  // ── Sections ───────────────────────────────────────────────────────────────

  Widget _buildFormSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        _SectionCard(
          icon: Icons.storefront_rounded,
          title: 'Customer',
          child: AsyncSearchPicker<CustomerModel>(
            filled: false,
            selectedItem: _selectedCustomer,
            focusNode: _customerFocus,
            searchKey: (item) => item.searchKey,
            displayText: (item) => item.displayText,
            onChanged: onChangedCustomer,
            hint: 'Select customer',
            prefixIcon: Icons.person_search_rounded,
            loadItems: _fetchCustomers,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Payment mode',
          child: PayModeSelectionNew(
            onChanged: (PaymentDetails p1) {  },
          ),
        ),
        const SizedBox(height: 16),
        Text('New'),


        _SectionCard(
          icon: Icons.storefront_rounded,
          title: 'Customer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Customer>(
                value: _customer,
                isExpanded: true,
                decoration: _decoration(
                  context,
                  hint: 'Select customer',
                  icon: Icons.person_search_rounded,
                ),
                items: widget.customers
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                validator: (v) => v == null ? 'Select a customer' : null,
                onChanged: (v) => setState(() => _customer = v),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _customer == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _OutstandingBadge(value: _customer!.outstanding),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.attach_money_rounded,
          title: 'Receipt amount',
          child: Column(
            children: [
              TextFormField(
                controller: _amount,
                textAlign: TextAlign.center,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                decoration: _decoration(context, hint: '0.00')
                    .copyWith(prefixText: 'LKR  '),
                validator: (v) {
                  final n = double.tryParse(v ?? '') ?? 0;
                  return n <= 0 ? 'Enter a receipt amount' : null;
                },
                onChanged: (_) => setState(() {}),
              ),
              if ((_customer?.outstanding ?? 0) > 0) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.done_all_rounded, size: 18),
                      label: Text('Full ${money(_customer!.outstanding)}'),
                      onPressed: () => _setAmount(_customer!.outstanding),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.adjust_rounded, size: 18),
                      label: Text('Half ${money(_customer!.outstanding / 2)}'),
                      onPressed: () => _setAmount(_customer!.outstanding / 2),
                    ),
                  ],
                ),
              ],
              if (_customer != null &&
                  _amountValue > _customer!.outstanding &&
                  _customer!.outstanding > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: Colors.orange.shade800),
                      const SizedBox(width: 6),
                      Text(
                        'Exceeds outstanding by '
                            '${money(_amountValue - _customer!.outstanding)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _SectionCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Payment mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (final m in PayMode.values) ...[
                    Expanded(
                      child: _ModeTile(
                        mode: m,
                        selected: _mode == m,
                        onTap: () => setState(() => _mode = m),
                      ),
                    ),
                    if (m != PayMode.values.last) const SizedBox(width: 8),
                  ],
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_mode),
                    child: _modeDetails(),
                  ),
                ),
              ),
            ],
          ),
        ),




      ],
    );
  }

  Widget _modeDetails() {
    switch (_mode) {
      case PayMode.cash:
        return const SizedBox(width: double.infinity);

      case PayMode.card:
      case PayMode.transfer:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextFormField(
            controller: _reference,
            decoration: _decoration(
              context,
              label: 'Reference (optional)',
              hint: _mode == PayMode.card ? 'Slip number' : 'Transaction ID',
              icon: Icons.tag_rounded,
            ),
          ),
        );

      case PayMode.cheque:
        final branches = _bank == null ? <String>[] : widget.banks[_bank]!;
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              _twoCol(
                TextFormField(
                  controller: _chequeNo,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _decoration(context,
                      label: 'Cheque number',
                      hint: '123456',
                      icon: Icons.pin_outlined),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _chequeDateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _decoration(context,
                      label: 'Cheque date',
                      hint: 'Select date',
                      icon: Icons.calendar_month_rounded),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              _twoCol(
                DropdownButtonFormField<String>(
                  value: _bank,
                  isExpanded: true,
                  decoration: _decoration(context,
                      label: 'Bank',
                      hint: 'Select bank',
                      icon: Icons.account_balance_rounded),
                  items: widget.banks.keys
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => setState(() {
                    _bank = v;
                    _branch = null;
                  }),
                ),
                DropdownButtonFormField<String>(
                  value: _branch,
                  isExpanded: true,
                  decoration: _decoration(context,
                      label: 'Branch',
                      hint: 'Select branch',
                      icon: Icons.location_on_outlined),
                  items: branches
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => setState(() => _branch = v),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _twoCol(Widget a, Widget b) => LayoutBuilder(builder: (context, c) {
    if (c.maxWidth < 300) {
      return Column(children: [a, const SizedBox(height: 12), b]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable UI pieces
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _decoration(
    BuildContext context, {
      String? label,
      String? hint,
      IconData? icon,
    }) {
  final s = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: TextStyle(color: s.onSurfaceVariant.withOpacity(0.6)),
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    filled: true,
    fillColor: s.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(Colors.transparent),
    enabledBorder: border(s.outlineVariant.withValues(alpha: 0.6)),
    focusedBorder: border(s.primary, 1.8),
    errorBorder: border(s.error),
    focusedErrorBorder: border(s.error, 1.8),
  );
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OutstandingBadge extends StatelessWidget {
  final double value;
  const _OutstandingBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final clear = value <= 0;
    final fg = clear ? Colors.green.shade800 : Colors.orange.shade900;
    final bg = clear ? Colors.green.shade50 : Colors.orange.shade50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(clear ? Icons.check_circle_outline : Icons.schedule_rounded,
              size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              clear ? 'No outstanding balance' : 'Outstanding',
              style: TextStyle(fontSize: 13, color: fg),
            ),
          ),
          if (!clear)
            Text('LKR ${money(value)}',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final PayMode mode;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTile(
      {required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: mode.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? s.primaryContainer : s.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? s.primary : s.outlineVariant.withOpacity(0.6),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mode.icon,
                  size: 24,
                  color: selected ? s.primary : s.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? s.onPrimaryContainer : s.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileActionBar extends StatelessWidget {
  final double total;
  final VoidCallback onSave;
  const _MobileActionBar({required this.total, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: s.surface,
        border: Border(top: BorderSide(color: s.outlineVariant.withOpacity(0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total',
                      style:
                      TextStyle(fontSize: 12, color: s.onSurfaceVariant)),
                  Text('LKR ${money(total)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Save receipt',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final Customer? customer;
  final PayMode mode;
  final double amount;
  final double balanceAfter;
  final VoidCallback onSave;

  const _SummaryPanel({
    required this.customer,
    required this.mode,
    required this.amount,
    required this.balanceAfter,
    required this.onSave,
  });

  Widget _row(BuildContext context, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(v,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: s.primary),
              const SizedBox(width: 8),
              const Text('Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, 'Customer', customer?.name ?? '—'),
          _row(context, 'Mode', mode.label),
          _row(context, 'Outstanding',
              customer == null ? '—' : money(customer!.outstanding)),
          _row(context, 'Balance after',
              customer == null ? '—' : money(balanceAfter)),
          const Divider(height: 28),
          Text('Total receipt',
              style: TextStyle(fontSize: 12, color: s.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text('LKR ${money(amount)}',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: s.primary)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Save receipt',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

