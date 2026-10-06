import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helpers/number_helper.dart';
import '../../models/customer_model.dart';
import '../../services/database/db_columns.dart';
import '../../services/database/db_helper.dart';
import '../../services/database/db_tables.dart';
import '../../services/database/repositories/customer_db_repository.dart';
import '../../shared/components/app/app_scaffold.dart';

class InvoiceInquiryView extends StatefulWidget {
  const InvoiceInquiryView({super.key});

  @override
  State<InvoiceInquiryView> createState() => _InvoiceInquiryViewState();
}

class _InvoiceInquiryViewState extends State<InvoiceInquiryView> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final snackBar = AppSnackBar.instance;
    try {
      _currentUser = await IAMService.instance.currentUser();
      _customers = await CustomerDbRepository.getAllCustomers(_currentUser!);
    } catch (e) {
      snackBar.error(title: 'Failed to Initialize Invoice Inquiry', message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _search() async {
    if (_selectedCustomer == null) {
      _showMessage('Please select a customer');
      return;
    }
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String where =
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
          'AND ${DBColumns.CS_CODE} = ?';
      List<dynamic> args = [
        _currentUser!.sbuCode,
        _currentUser!.locCode,
        _selectedCustomer!.csCode,
      ];

      if (_startDateController.text.isNotEmpty &&
          _endDateController.text.isNotEmpty) {
        where +=
            ' AND ${DBColumns.TXN_DATE} >= ? AND ${DBColumns.TXN_DATE} <= ?';
        args.add(_startDateController.text);
        args.add(_endDateController.text);
      }

      final results = await DBHelper.query(
        DBTables.INVOICES,
        where: where,
        whereArgs: args,
        orderBy: '${DBColumns.TXN_DATE} DESC',
      );

      if (mounted) {
        setState(() {
          _results = results;
          _hasSearched = true;
        });
        if (results.isEmpty) _showMessage('No invoice records found');
      }
    } catch (e) {
      if (mounted) _showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clear() {
    setState(() {
      _selectedCustomer = null;
      _startDateController.clear();
      _endDateController.clear();
      _results.clear();
      _hasSearched = false;
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Invoice Inquiry',
      defaultPadding: true,
      scrollableBody: Column(
        children: [
          _buildSearchCard(colorScheme),
          Expanded(child: _buildResults(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildSearchCard(ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Search Filters',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface)),
            const SizedBox(height: 12),
            Autocomplete<CustomerModel>(
              displayStringForOption: (c) => c.displayText,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<CustomerModel>.empty();
                }
                final q = textEditingValue.text.toLowerCase();
                return _customers
                    .where((c) => c.searchKey.toLowerCase().contains(q));
              },
              onSelected: (c) =>
                  setState(() => _selectedCustomer = c),
              fieldViewBuilder:
                  (context, fieldCtrl, fieldFocus, onSubmitted) {
                return TextField(
                  controller: fieldCtrl,
                  focusNode: fieldFocus,
                  decoration: InputDecoration(
                    labelText: 'Customer',
                    hintText: 'Search customer...',
                    prefixIcon: const Icon(Icons.person_search),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    if (_selectedCustomer != null &&
                        v != _selectedCustomer!.displayText) {
                      setState(() => _selectedCustomer = null);
                    }
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (ctx, i) {
                          final opt = options.elementAt(i);
                          return ListTile(
                            dense: true,
                            title: Text(opt.csCode ?? ''),
                            subtitle: Text(opt.csName ?? ''),
                            onTap: () => onSelected(opt),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date (optional)',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onTap: () => _pickDate(_startDateController),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date (optional)',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onTap: () => _pickDate(_endDateController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _search,
                    icon: const Icon(Icons.search),
                    label: Text(_isLoading ? 'Searching...' : 'Search'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on,
                size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('Select a customer and search invoices',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text('No records found',
            style: TextStyle(color: colorScheme.onSurfaceVariant)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('${_results.length} record(s) found',
              style: TextStyle(
                  fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final r = _results[index];
              final docNo = r[DBColumns.DOC_NO]?.toString() ?? '';
              final docCode = r[DBColumns.DOC_CODE]?.toString() ?? '';
              final txnDate = r[DBColumns.TXN_DATE]?.toString() ?? '';
              final originalAmt = (r[DBColumns.ORIGINAL_AMOUNT] as num?) ?? 0;
              final dueAmt = (r[DBColumns.DUE_AMOUNT] as num?) ?? 0;
              final balanceAmt = (r[DBColumns.BALANCE_AMOUNT] as num?) ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$docCode - $docNo',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(txnDate,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildAmountChip(
                              'Original', originalAmt, colorScheme, Colors.grey),
                          const SizedBox(width: 8),
                          _buildAmountChip(
                              'Due', dueAmt, colorScheme, Colors.orange),
                          const SizedBox(width: 8),
                          _buildAmountChip('Balance', balanceAmt, colorScheme,
                              balanceAmt > 0 ? Colors.red : Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(
      String label, num amount, ColorScheme colorScheme, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            Text(NumberHelper.formatCurrency(amount),
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
