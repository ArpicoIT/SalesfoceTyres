import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/exceptions/app_exception.dart';
import '../../helpers/responsive.dart';
import '../../models/bank_model.dart';
import '../../services/database/repositories/bank_db_repository.dart';
import '../../utils/formatters/text_input_formatters.dart';
import '../components/form/async_search_picker.dart';
import '../components/form/date_picker_field.dart';
import '../components/form/text_input_field.dart';

class PaymentDetails {
  PayMode? payMode;
  String? chqNumber;
  String? chqBankingDate;
  String? chqDate;
  BankModel? bank;
  BankBranchModel? branch;
  String? ddRefNumber;

  PaymentDetails({
    this.payMode = PayMode.none,
    this.chqNumber,
    this.chqBankingDate,
    this.chqDate,
    this.bank,
    this.branch,
    this.ddRefNumber,
  });

  @override
  String toString() {
    return 'PaymentDetails('
        'payMode: $payMode, '
        'chqNumber: $chqNumber, '
        'chqBankingDate: $chqBankingDate, '
        'chqDate: $chqDate, '
        'chqBank: ${bank.toString()}, '
        'chqBranch: ${branch.toString()}, '
        'ddRefNumber: $ddRefNumber'
        ')';
  }
}

enum PayMode {
  none('Payment Mode', 'Payment Mode', Icons.payment_rounded, null), // PAYMENT_MODE
  cash('Cash', 'Cash', Icons.payments_outlined, Colors.green), // CASH
  cheque('Cheque', 'Cheque', Icons.edit_note_rounded, Colors.red), // CHEQUE
  ddCash('D D Cash', 'D D Cash', Icons.account_balance_wallet_rounded, Colors.blue), // D_D_CASH
  ddCheque('D D Cheque', 'D D Cheque', Icons.account_balance_rounded, Colors.orange); // D_D_CHEQUE

  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const PayMode(this.value, this.label, this.icon, this.color);
}

class PayModeSelectionNew extends StatefulWidget {
  final Function(PaymentDetails) onChanged;
  final bool filled;
  final FocusNode? focusNode;

  final _SelectionType _type;

  const PayModeSelectionNew({
    super.key,
    required this.onChanged,
    this.filled = true,
    this.focusNode,
  }) : _type = _SelectionType.dropdown;

  @override
  State<PayModeSelectionNew> createState() => _PayModeSelectionNewState();
}

class _PayModeSelectionNewState extends State<PayModeSelectionNew> {
  PaymentDetails _details = PaymentDetails();

  final _chqNumberCtrl = TextEditingController();
  final _chqDateCtrl = TextEditingController();
  final _chqBankingDateCtrl = TextEditingController();
  final _ddRefNumberCtrl = TextEditingController();

  final _chqNumberFocus = FocusNode();
  final _chqDateFocus = FocusNode();
  final _chqBankingDateFocus = FocusNode();
  final _ddRefNumberFocus = FocusNode();
  final _bankFocus = FocusNode();
  final _branchFocus = FocusNode();

  BankModel? _selectedBank;
  BankBranchModel? _selectedBranch;
  final bool _isDefaultBranch = false;

  bool get hasPayMode => _details.payMode != PayMode.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chqNumberCtrl.addListener(_listener);
      _chqDateCtrl.addListener(_listener);
      _chqBankingDateCtrl.addListener(_listener);
      _ddRefNumberCtrl.addListener(_listener);
    });
  }

  void unfocus() {
    _chqNumberFocus.unfocus();
    _chqDateFocus.unfocus();
    _chqBankingDateFocus.unfocus();
    _ddRefNumberFocus.unfocus();
    _bankFocus.unfocus();
    _branchFocus.unfocus();
  }

  void reset() => _onChangedPayMode(PayMode.none);

  void _listener() {
    _details.chqNumber = _chqNumberCtrl.text;
    _details.chqDate = _chqDateCtrl.text;
    _details.chqBankingDate = _chqBankingDateCtrl.text;
    _details.ddRefNumber = _ddRefNumberCtrl.text;
    widget.onChanged.call(_details);
  }

  void _onChangedPayMode(PayMode? value) {
    if(_details.payMode == value){
      _details = PaymentDetails();
    } else {
      _details = PaymentDetails(payMode: value);
    }

    _chqNumberCtrl.clear();
    _chqDateCtrl.clear();
    _chqBankingDateCtrl.clear();
    _ddRefNumberCtrl.clear();
    _selectedBank = null;
    _selectedBranch = null;
    widget.onChanged.call(_details);
    setState(() {});
  }

  /// Bank selection helper methods
  void _onChangedBank(BankModel? value) {
    _selectedBank = value;
    if (value != null && _isDefaultBranch) {
      _selectedBranch = BankBranchModel.defaults(value.bankCode);
    } else {
      _selectedBranch = null;
    }
    _details.bank = _selectedBank;
    _details.branch = _selectedBranch;
    widget.onChanged.call(_details);
    setState(() {});
  }

  Future<List<BankModel>> _fetchBanks() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      return await BankDbRepository.getAllBanks(currentUser);
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  /// Bank selection helper methods
  void _onChangedBranch(BankBranchModel? value) {
    _selectedBranch = value;
    _details.branch = _selectedBranch;
    widget.onChanged.call(_details);
    setState(() {});
  }

  Future<List<BankBranchModel>> _fetchBankBranches() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      if (_selectedBank?.bankCode == null || _selectedBank!.bankCode!.isEmpty) {
        throw AppException.validationBankNotSelected();
      }

      return await BankDbRepository.getBankBranches(
        currentUser,
        bankCode: _selectedBank!.bankCode!,
      );
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final m in PayMode.values) ...[
              if(m == PayMode.none) const SizedBox.shrink()
              else ...[
                Expanded(
                  child: _ModeTile(
                    mode: m,
                    selected: _details.payMode == m,
                    onTap: () => _onChangedPayMode(m),
                  ),
                ),
                if (m != PayMode.values.last) const SizedBox(width: 8),
              ]
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
              key: ValueKey(_details.payMode),
              child: _modeDetails(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeDetails() {
    switch (_details.payMode) {
      case null:
      case PayMode.none:
      case PayMode.cash:
        return const SizedBox(width: double.infinity);
      case PayMode.cheque:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              _twoCol(
                TextInputField(
                  controller: _chqNumberCtrl,
                  focusNode: _chqNumberFocus,
                  label: 'Cheque number',
                  hint: '123456',
                  prefixIcon: Icons.pin_outlined,
                  inputFormatters: TextInputFormatters.digitsOnly(),
                  maxLength: 6,
                  isNumeric: true,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                DatePickerField(
                  // controller: _chqDateCtrl,
                  focusNode: _chqDateFocus,
                  label: 'Cheque date',
                  hint: ' Cheque date',
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2076),
                  // onChanged: (date) {
                  //   debugPrint(date.toString());
                  // },
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              _twoCol(
                AsyncSearchPicker<BankModel>(
                  selectedItem: _selectedBank,
                  focusNode: _bankFocus,
                  searchKey: (item) => item.searchKey,
                  displayText: (item) => item.displayText,
                  onChanged: _onChangedBank,
                  label: 'Bank',
                  hint: 'Select bank',
                  prefixIcon: Icons.account_balance_rounded,
                  loadItems: _fetchBanks,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                AsyncSearchPicker<BankBranchModel>(
                  filled: false,
                  focusNode: _branchFocus,
                  selectedItem: _selectedBranch,
                  searchKey: (item) => item.searchKey,
                  displayText: (item) => item.displayText,
                  onChanged: _onChangedBranch,
                  label: 'Branch',
                  hint: 'Select branch',
                  prefixIcon: Icons.location_on_outlined,
                  loadItems: _fetchBankBranches,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
        );
      case PayMode.ddCash:
      case PayMode.ddCheque:
        return Padding(
          padding: .only(top: 16),
          child: TextInputField(
            filled: widget.filled,
            controller: _ddRefNumberCtrl,
            focusNode: _ddRefNumberFocus,
            hint: '0123ABC',
            label: 'Reference number',
            prefixIcon: Icons.tag_rounded,
            inputFormatters: TextInputFormatters.alphanumeric(),
            maxLength: 20,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Required' : null,
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

class _ModeTile extends StatelessWidget {
  final PayMode mode;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTile(
      {required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.6),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mode.icon,
                  size: 24,
                  color: selected ? cs.primary : mode.color ?? cs.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






enum _SelectionType { dropdown, bottomSheet, fittedBox }

class _Item {
  final PayMode payMode;
  final IconData icon;
  final Color? color;

  const _Item(this.payMode, this.icon, {this.color});
}

class PayModeSelection extends StatefulWidget {
  final Function(PaymentDetails) onChanged;
  final bool filled;
  final FocusNode? focusNode;

  final _SelectionType _selectionType;

  const PayModeSelection({
    super.key,
    required this.onChanged,
    this.filled = true,
    this.focusNode,
  }) : _selectionType = _SelectionType.dropdown;

  const PayModeSelection.dropdown({
    super.key,
    required this.onChanged,
    this.filled = true,
    this.focusNode,
  }) : _selectionType = _SelectionType.dropdown;

  const PayModeSelection.bottomSheet({
    super.key,
    required this.onChanged,
    this.filled = true,
    this.focusNode,
  }) : _selectionType = _SelectionType.bottomSheet;

  const PayModeSelection.fittedBox({
    super.key,
    required this.onChanged,
    this.filled = true,
    this.focusNode,
  }) : _selectionType = _SelectionType.fittedBox;

  @override
  State<PayModeSelection> createState() => PayModeSelectionState();
}

class PayModeSelectionState extends State<PayModeSelection> {
  PaymentDetails _model = PaymentDetails();

  final _chqNumberCtrl = TextEditingController();
  // final _chqDateCtrl = TextEditingController();
  // final _chqBankingDateCtrl = TextEditingController();
  final _ddRefNumberCtrl = TextEditingController();

  final _chqNumberFocus = FocusNode();
  final _chqDateFocus = FocusNode();
  final _chqBankingDateFocus = FocusNode();
  final _ddRefNumberFocus = FocusNode();
  final _bankFocus = FocusNode();
  final _branchFocus = FocusNode();

  // String? _chqDate;
  BankModel? _selectedBank;
  BankBranchModel? _selectedBranch;
  final bool _isDefaultBranch = false;

  bool get hasPayMode => _model.payMode != PayMode.none;

  List<_Item> get _items => [
    _Item(PayMode.none, Icons.payment_rounded),
    _Item(PayMode.cash, Icons.payments_rounded, color: Colors.green),
    _Item(PayMode.cheque, Icons.receipt_long_rounded, color: Colors.red),
    _Item(
      PayMode.ddCash,
      Icons.account_balance_wallet_rounded,
      color: Colors.blue,
    ),
    _Item(
      PayMode.ddCheque,
      Icons.account_balance_rounded,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chqNumberCtrl.addListener(_listener);
      // _chqDateCtrl.addListener(_listener);
      // _chqBankingDateCtrl.addListener(_listener);
      _ddRefNumberCtrl.addListener(_listener);
    });
  }

  void checkNumberFocus() => _chqNumberFocus.requestFocus();
  void checkDateFocus() => _chqDateFocus.requestFocus();
  void checkBankingDateFocus() => _chqBankingDateFocus.requestFocus();
  void ddRefNumberFocus() => _ddRefNumberFocus.requestFocus();
  void bankFocus() => _bankFocus.requestFocus();
  void branchFocus() => _branchFocus.requestFocus();

  void unfocus() {
    _chqNumberFocus.unfocus();
    _chqDateFocus.unfocus();
    _chqBankingDateFocus.unfocus();
    _ddRefNumberFocus.unfocus();
    _bankFocus.unfocus();
    _branchFocus.unfocus();
  }

  void reset() => _onChangedPayMode(PayMode.none);

  void _listener() {
    _model.chqNumber = _chqNumberCtrl.text;
    // _model.chqDate = _chqDateCtrl.text;
    // _model.chqBankingDate = _chqBankingDateCtrl.text;
    _model.ddRefNumber = _ddRefNumberCtrl.text;
    widget.onChanged.call(_model);
  }

  void _onChangedPayMode(PayMode? value) {
    _model = PaymentDetails(payMode: value!);
    _chqNumberCtrl.clear();
    // _chqDateCtrl.clear();
    // _chqBankingDateCtrl.clear();
    _ddRefNumberCtrl.clear();
    _selectedBank = null;
    _selectedBranch = null;
    setState(() {});
    widget.onChanged.call(_model);
  }

  void _onChangedChequeDate(DateTime? value) {
    _model.chqDate = value is DateTime ? DateFormat('yyyy-MM-dd').format(value) : null;
    widget.onChanged.call(_model);
  }

  /// Bank selection helper methods
  void _onChangedBank(BankModel? value) {
    _selectedBank = value;
    if (value != null && _isDefaultBranch) {
      _selectedBranch = BankBranchModel.defaults(value.bankCode);
    } else {
      _selectedBranch = null;
    }
    _model.bank = _selectedBank;
    _model.branch = _selectedBranch;
    setState(() {});
    widget.onChanged.call(_model);
  }

  Future<List<BankModel>> _fetchBanks() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      return await BankDbRepository.getAllBanks(currentUser);
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  /// Bank selection helper methods
  void _onChangedBranch(BankBranchModel? value) {
    _selectedBranch = value;
    _model.branch = _selectedBranch;
    setState(() {});
    widget.onChanged.call(_model);
  }

  Future<List<BankBranchModel>> _fetchBankBranches() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      if (_selectedBank?.bankCode == null || _selectedBank!.bankCode!.isEmpty) {
        throw AppException.validationBankNotSelected();
      }

      return await BankDbRepository.getBankBranches(
        currentUser,
        bankCode: _selectedBank!.bankCode!,
      );
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        if (widget._selectionType == _SelectionType.dropdown)
          buildSelectionDropdown()
        else
          buildSelectionModelBottom(),
        if (_model.payMode == PayMode.cheque) ...[
          TextInputField(
            filled: widget.filled,
            controller: _chqNumberCtrl,
            focusNode: _chqNumberFocus,
            title: 'Cheque Number',
            hint: 'eg:, 123456',
            inputFormatters: TextInputFormatters.digitsOnly(),
            maxLength: 6,
            isNumeric: true,
          ),
          DatePickerField(
            filled: widget.filled,
            focusNode: _chqDateFocus,
            title: 'Cheque Date',
            hint: 'Select cheque date',
            firstDate: DateTime.now(),
            lastDate: DateTime(2076),
            onChanged: _onChangedChequeDate,
          ),

          // DatePickerField(
          //   filled: widget.filled,
          //   controller: _chqBankingDateCtrl,
          //   focusNode: _chqBankingDateFocus,
          //   title: 'Banking Date'
          //   hintText: 'Select banking date',
          //   initialDate: DateTime.now(),
          //   firstDate: DateTime.now(),
          //   lastDate: DateTime(2076),
          //   onChanged: (date) {
          //     debugPrint(date.toString());
          //   },
          // ),
          AsyncSearchPicker<BankModel>(
            filled: widget.filled,
            focusNode: _bankFocus,
            selectedItem: _selectedBank,
            searchKey: (item) => item.searchKey,
            displayText: (item) => item.displayText,
            onChanged: _onChangedBank,
            title: 'Cheque Bank',
            hint: 'Select cheque Bank',
            loadItems: _fetchBanks,
          ),
          AsyncSearchPicker<BankBranchModel>(
            filled: widget.filled,
            focusNode: _branchFocus,
            selectedItem: _selectedBranch,
            searchKey: (item) => item.searchKey,
            displayText: (item) => item.displayText,
            onChanged: _onChangedBranch,
            title: 'Bank Branch',
            hint: 'Select bank branch',
            loadItems: _fetchBankBranches,
          ),
        ],
        if ([
          PayMode.ddCash,
          PayMode.ddCheque,
        ].any((e) => e == _model.payMode)) ...[
          TextInputField(
            filled: widget.filled,
            controller: _ddRefNumberCtrl,
            focusNode: _ddRefNumberFocus,
            title: 'Reference Number',
            hint: 'Enter reference number',
            inputFormatters: TextInputFormatters.alphanumeric(),
            maxLength: 20,
            // isNumeric: false,
          ),
        ],
      ],
    );
  }

  Widget buildSelectionDropdown() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
        color: widget.filled ? cs.surfaceContainerLow : cs.surface,
      ),
      height: kMinInteractiveDimension * 1.2,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PayMode>(
          value: _model.payMode,
          focusNode: widget.focusNode,
          items: _items
              .map(
                (e) => DropdownMenuItem(
                  value: e.payMode,
                  child: Text(e.payMode.label),
                ),
              )
              .toList(),
          onChanged: _onChangedPayMode,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          padding: .fromLTRB(16, 0, hasPayMode ? 4 : 8, 0),
          // alignment: AlignmentDirectional.bottomStart
          // hint: Text('Select payment mode')
          icon: hasPayMode
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _onChangedPayMode(PayMode.none);
                  },
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.grey.shade700,
                  ),
                )
              : const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  Widget buildSelectionModelBottom() {
    final tm = Theme.of(context);
    final cs = tm.colorScheme;
    final tt = tm.textTheme;

    final isMobile = Responsive.of(context).isPhone;

    const maxColumns = 4;

    Widget mobileItem(_Item item, bool isSelected, VoidCallback onSelect) {
      final color = item.color ?? cs.primary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(item.icon, size: 22, color: color),
              ),
              title: Text(
                item.payMode.label,
                style: tt.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : cs.onSurface,
                ),
              ),
              trailing: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: isSelected ? color : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    Widget desktopItem(_Item item, bool isSelected, VoidCallback onSelect) {
      final color = item.color ?? cs.primary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.10)
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : cs.outlineVariant.withValues(alpha: 0.7),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : color.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 26,
                    color: isSelected ? cs.onPrimary : color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.payMode.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> sheet() async {
      final selected = await showModalBottomSheet<PayMode>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (context) {
          final items = _items
              .where((item) => item.payMode != PayMode.none)
              .toList();

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: isMobile
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((item) {
                      final isSelected = _model.payMode == item.payMode;

                      return mobileItem(
                        item,
                        isSelected,
                        () => Navigator.pop(context, item.payMode),
                      );
                    }).toList(),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: items.length < maxColumns
                          ? items.length
                          : maxColumns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = _model.payMode == item.payMode;

                      return desktopItem(
                        item,
                        isSelected,
                        () => Navigator.pop(context, item.payMode),
                      );
                    },
                  ),
          );
        },
      );

      if (selected != null && mounted) {
        _onChangedPayMode(selected);
      }
    }

    return InkWell(
      onTap: sheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: kMinInteractiveDimension * 1.2,
        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
          color: widget.filled ? cs.surfaceContainerLow : cs.surface,
        ),
        child: Row(
          children: [
            Expanded(child: Text(_model.payMode?.label??'N/A', style: tt.bodyLarge)),
            hasPayMode
                ? IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      _onChangedPayMode(PayMode.none);
                    },
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      foregroundColor: cs.onSurfaceVariant,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.arrow_drop_down),
                  ),
          ],
        ),
      ),
    );
  }
}
