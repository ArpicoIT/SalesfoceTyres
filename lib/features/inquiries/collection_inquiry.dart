import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helpers/date_time_helper.dart';
import '../../helpers/number_helper.dart';
import '../../models/collection_model.dart';
import '../../models/customer_model.dart';
import '../../repositories/api/collection_api_repository.dart';
import '../../services/database/repositories/customer_db_repository.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';
import '../../shared/components/form/async_search_picker.dart';
import '../../shared/components/form/banking_amount_field.dart';
import '../../shared/components/form/date_picker_field.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/section_header.dart';

class CollectionInquiryView extends StatefulWidget {
  const CollectionInquiryView({super.key});

  @override
  State<CollectionInquiryView> createState() => _CollectionInquiryViewState();
}

class _CollectionInquiryViewState extends State<CollectionInquiryView> {
  final TextEditingController _rcpdAmountCtrl = TextEditingController();

  /// Focus nods
  final _customerFocus = FocusNode();
  final _rcpdAmountFocus = FocusNode();
  final _fromDateFocus = FocusNode();
  final _toDateFocus = FocusNode();

  String? _fromDate;
  String? _toDate;
  CustomerModel? _selectedCustomer;

  List<CollectionHeaderModel> _headers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
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

  void _clearData() {
    _selectedCustomer = null;
    _rcpdAmountCtrl.clear();
    _fromDate = null;
    _toDate = null;
    _headers.clear();
    _isSearching = false;
  }

  void _onChangedFromDate(DateTime? value) {
    _fromDate = value is DateTime ? DateFormat('yyyy-MM-dd').format(value) : null;
  }

  void _onChangedToDate(DateTime? value) {
    _toDate = value is DateTime ? DateFormat('yyyy-MM-dd').format(value) : null;
  }

  void _onChangedCustomer(CustomerModel? value) {
    setState(() {
      _clearData();
      _selectedCustomer = value;
    });
  }

  void _unfocus() {
    _customerFocus.unfocus();
    _rcpdAmountFocus.unfocus();
    _fromDateFocus.unfocus();
    _toDateFocus.unfocus();
  }

  bool _validateFilters() {
    final snackBar = AppSnackBar.instance;

    if (_selectedCustomer == null) {
      snackBar.info(message: 'Please select a customer');
      return false;
    }

    // if(_fromDateCtrl.text.isEmpty || _toDateCtrl.text.isEmpty) {
    //   snackBar.info(message: 'Please select both start and end dates');
    //   return false;
    // }

    return true;
  }

  void _onClear() {
    _unfocus();
    setState(_clearData);
  }

  void _onSearch() async {
    final snackBar = AppSnackBar.instance;
    final loader = AppLoader.instance;

    try {
      if (!_validateFilters()) {
        return;
      }

      _unfocus();

      setState(() {
        _isSearching = true;
      });

      loader.show();

      final currentUser = await IAMService.instance.currentUser();

      final res = await CollectionApiRepository.getCollectionHeaders(
        currentUser,
        csCode: _selectedCustomer?.csCode ?? '',
        amount: NumberHelper.parseAmountFormatToDouble(_rcpdAmountCtrl.text),
        fromDate: _fromDate ?? '',
        toDate: _toDate ?? '',
      );

      if (res.success) {
        // snackBar.success(message: res.message);
        _headers = res.data ?? [];
      } else {
        snackBar.error(message: res.message);
      }
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      loader.hide();
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> openCollectionDetailsSheet(CollectionHeaderModel header) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: .antiAlias,
      useRootNavigator: true,
      routeSettings: RouteSettings(name: '/header-details-model-bottom-sheet'),
      builder: (context) => CollectionDetails(header),
    );

    // if (!context.mounted || result == null) return;
    //
    // final itemIndex = items.indexWhere(
    //       (element) => element.collection?.id == item.collection?.id,
    // );
    //
    // if (itemIndex == -1) return;
    //
    // setState(() {
    //   items[itemIndex] = result;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Collection Inquiry',
      defaultPadding: true,
      scrollableBody: Column(
        spacing: 16,
        children: [
          buildSearchCard(),
          const SizedBox(height: 20),
          buildResults(),
        ],
      ),
    );
  }

  Widget buildSearchCard() {
    return SectionCard(
      title: "Search Filters",
      child: Column(
        spacing: 12,
        children: [
          AsyncSearchPicker<CustomerModel>(
            filled: false,
            selectedItem: _selectedCustomer,
            focusNode: _customerFocus,
            searchKey: (item) => item.searchKey,
            displayText: (item) => item.displayText,
            onChanged: _onChangedCustomer,
            hint: 'Customer',
            loadItems: _fetchCustomers,
          ),

          // TextInputField.amount(
          //   filled: false,
          //   controller: _rcpdAmountCtrl,
          //   focusNode: _rcpdAmountFocus,
          //   hintText: 'Receipt amount',
          //   inputFormatters: TextInputFormatters.amountOnly(),
          // ),
          BankingAmountField(
            filled: false,
            controller: _rcpdAmountCtrl,
            focusNode: _rcpdAmountFocus,
            maxLength: 20,
            // onChanged: (amount) {
            //   debugPrint('Amount: $amount | Controller: ${_rcpdAmountCtrl.text}');
            // },
          ),

          Row(
            crossAxisAlignment: .center,
            spacing: 12,
            children: [
              Expanded(
                child: DatePickerField(
                  filled: false,
                  focusNode: _fromDateFocus,
                  hint: 'From date',
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2076),
                  onChanged: _onChangedFromDate,
                ),
              ),
              Expanded(
                child: DatePickerField(
                  filled: false,
                  focusNode: _toDateFocus,
                  hint: 'To date',
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2076),
                  onChanged: _onChangedToDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 12,
            crossAxisAlignment: .center,
            children: [
              Expanded(
                child: AppButton.of(context).cancel(
                  onPressed: _onClear,
                  label: 'Clear',
                  enabled: !_isSearching,
                ),
              ),
              Expanded(
                child: AppButton.of(context).search(
                  onPressed: _onSearch,
                  enabled: !_isSearching,
                  loading: _isSearching,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResults() {
    final cs = Theme.of(context).colorScheme;

    if (_headers.isEmpty) {
      return AppEmptyView(
        icon: Icons.receipt_long,
        title: 'No Records Found',
        message: 'Use different filters above to search collections',
        buttonText: 'Refresh',
        // onPressed: loadCollections,
      );
    }

    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        SectionHeader(
          title: 'Recent Collections',
          subtitle: '${_headers.length} record(s)',
          showRefresh: true,
          onRefresh: _onSearch,
        ),
        ListView.separated(
          itemCount: _headers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final r = _headers[index];
            final docNo = r.docNo?.toString() ?? '';
            final csCode =
                _selectedCustomer?.csCode?.toString() ?? r.csCode ?? '';
            final csName = _selectedCustomer?.csName?.toString() ?? '';
            final txnDate = r.txnDate?.toString() ?? '';
            final payMode = r.payMode?.label.toString() ?? '';
            final total = (r.totalAmount as num?) ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: .antiAlias,
              child: ListTile(
                // leading: CircleAvatar(
                //   backgroundColor: cs.primaryContainer,
                //   child: Text(
                //     docNo.length > 2 ? docNo.substring(0, 2) : docNo,
                //     style: TextStyle(
                //       color: cs.primary,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
                title: Text(
                  '$csCode - $csName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doc: $docNo | Pay: $payMode'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          txnDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          NumberHelper.formatCurrency(total),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(Icons.cloud_done, size: 18, color: Colors.green),
                isThreeLine: true,
                onTap: () => openCollectionDetailsSheet(r),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CollectionDetails extends StatefulWidget {
  final CollectionHeaderModel header;
  const CollectionDetails(this.header, {super.key});

  @override
  State<CollectionDetails> createState() => _CollectionDetailsState();
}

class _CollectionDetailsState extends State<CollectionDetails> {
  late CollectionHeaderModel _header;
  List<CollectionDetailModel> _details = [];
  bool _isLoading = true;

  @override
  void initState() {
    _header = widget.header;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
    super.initState();
  }

  Future<void> _loadDetails() async {
    if (mounted && !_isLoading) setState(() => _isLoading = true);

    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();
      final res = await CollectionApiRepository.getCollectionDetails(
        currentUser,
        docNo: _header.docNo ?? '',
      );

      if (res.success) {
        _details = res.data ?? [];
      } else {
        snackBar.error(message: res.message);
      }
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Details', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .all(16),
          child: Column(
            spacing: 16,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 20),
              _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return SizedBox(
      width: .infinity,
      child: Column(
        spacing: 8,
        crossAxisAlignment: .stretch,
        children: [
          _buildInfoRow(
            Icons.numbers_rounded,
            'Document No.',
            _header.docNo ?? 'N/A',
          ),
          _buildInfoRow(
            Icons.person_rounded,
            'Customer',
            _header.csCode ?? 'N/A',
          ),
          _buildInfoRow(
            Icons.payments_rounded,
            'Payment Mode',
            _header.payMode?.label ?? 'N/A',
          ),
          _buildInfoRow(
            Icons.payments_outlined,
            'Amount',
            NumberHelper.formatCurrency(_header.totalAmount),
          ),
          _buildInfoRow(
            Icons.date_range_rounded,
            'Date',
            DateTimeHelper.getDisplayDateTime(_header.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_details.isEmpty) {
      return AppEmptyView(
        icon: Icons.receipt_long,
        title: 'No Records Found',
        message: 'Pull down or tap refresh to load the latest details.',
        buttonText: 'Refresh',
        onPressed: _loadDetails,
      );
    }

    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        SectionHeader(
          title: 'Collection Details',
          subtitle: '${_details.length} record(s)',
          showRefresh: true,
          onRefresh: _loadDetails,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, idx) {
            final d = _details[idx];
            final recDoc = d.recDoc?.toString() ?? '';
            final recNo = d.recNo?.toString() ?? '';
            final invDoc = d.invDoc?.toString() ?? '';
            final invNo = d.invNo?.toString() ?? '';
            final setOffAmount = d.setOffAmount ?? 0;
            final txnDate = d.txnDate?.toString() ?? '';

            // final int seqNo = d.seqNo ?? 0;
            // final docCode = d.docCode?.toString() ?? '';
            // final docNo = d.docNo?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: .antiAlias,
              child: ListTile(
                title: Text(
                  'Invoice: $invDoc - $invNo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rec Doc: $recDoc - $recNo'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          txnDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          NumberHelper.formatCurrency(setOffAmount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(Icons.cloud_done, size: 18, color: Colors.green),
                isThreeLine: true,
                // onTap: () => openCollectionDetailsSheet(d),
              ),
            );
          },
          separatorBuilder: (ctx, idx) => SizedBox(height: 8),
          itemCount: _details.length,
        ),
      ],
    );
  }
}

// class CollectionInquiryView extends StatefulWidget {
//   const CollectionInquiryView({super.key});
//
//   @override
//   State<CollectionInquiryView> createState() => _CollectionInquiryViewState();
// }
//
// class _CollectionInquiryViewState extends State<CollectionInquiryView> {
//   final TextEditingController _startDateController = TextEditingController();
//   final TextEditingController _endDateController = TextEditingController();
//
//   List<CustomerModel> _customers = [];
//   CustomerModel? _selectedCustomer;
//   List<Map<String, dynamic>> _headers = [];
//   bool _isLoading = false;
//   bool _hasSearched = false;
//   UserModel? _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   @override
//   void dispose() {
//     _startDateController.dispose();
//     _endDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _init() async {
//     _currentUser = await AIAMStorage.instance.getUser();
//     if (_currentUser != null) {
//       final customers = await CustomerDbRepository.getAllCustomers(_currentUser!);
//       if (mounted) setState(() => _customers = customers);
//     }
//   }

//
//   Future<void> _pickDate(TextEditingController controller) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       controller.text = DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }
//
//   Future<void> _search() async {
//     if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
//       _showMessage('Please select both start and end dates');
//       return;
//     }
//     if (_currentUser == null) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       String where =
//           '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
//           'AND ${DBColumns.TXN_DATE} >= ? AND ${DBColumns.TXN_DATE} <= ?';
//       List<dynamic> args = [
//         _currentUser!.sbuCode,
//         _currentUser!.locCode,
//         _startDateController.text,
//         _endDateController.text,
//       ];
//
//       if (_selectedCustomer != null) {
//         where += ' AND ${DBColumns.CS_CODE} = ?';
//         args.add(_selectedCustomer!.csCode);
//       }
//
//       final results = await DBHelper.query(
//         DBTables.COLLECTION_HEADERS,
//         where: where,
//         whereArgs: args,
//         orderBy: '${DBColumns.TXN_DATE} DESC, ${DBColumns.CREATED_AT} DESC',
//       );
//
//       if (mounted) {
//         setState(() {
//           _headers = results;
//           _hasSearched = true;
//         });
//         if (results.isEmpty) _showMessage('No collection records found');
//       }
//     } catch (e) {
//       if (mounted) _showMessage('Error: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   void _clear() {
//     setState(() {
//       _selectedCustomer = null;
//       _startDateController.clear();
//       _endDateController.clear();
//       _headers.clear();
//       _hasSearched = false;
//     });
//   }
//
//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Theme.of(context).colorScheme.error,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return AppScaffold(
//       title: 'Collection Inquiry',
//       body: Column(
//         children: [
//           // _buildSearchCard(colorScheme),
//           // Expanded(child: _buildResults(colorScheme)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchCard(ColorScheme colorScheme) {
//     return Card(
//       margin: const EdgeInsets.all(12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Search Filters',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.onSurface)),
//             const SizedBox(height: 12),
//             Autocomplete<CustomerModel>(
//               displayStringForOption: (c) => c.displayText,
//               optionsBuilder: (textEditingValue) {
//                 if (textEditingValue.text.isEmpty) {
//                   return const Iterable<CustomerModel>.empty();
//                 }
//                 final q = textEditingValue.text.toLowerCase();
//                 return _customers
//                     .where((c) => c.searchKey.toLowerCase().contains(q));
//               },
//               onSelected: (c) =>
//                   setState(() => _selectedCustomer = c),
//               fieldViewBuilder:
//                   (context, fieldCtrl, fieldFocus, onSubmitted) {
//                 return TextField(
//                   controller: fieldCtrl,
//                   focusNode: fieldFocus,
//                   decoration: InputDecoration(
//                     labelText: 'Customer (optional)',
//                     hintText: 'Search customer...',
//                     prefixIcon: const Icon(Icons.person_search),
//                     border: const OutlineInputBorder(),
//                     isDense: true,
//                   ),
//                   onChanged: (v) {
//                     if (_selectedCustomer != null &&
//                         v != _selectedCustomer!.displayText) {
//                       setState(() => _selectedCustomer = null);
//                     }
//                   },
//                 );
//               },
//               optionsViewBuilder: (context, onSelected, options) {
//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     elevation: 4,
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxHeight: 200),
//                       child: ListView.builder(
//                         padding: EdgeInsets.zero,
//                         itemCount: options.length,
//                         itemBuilder: (ctx, i) {
//                           final opt = options.elementAt(i);
//                           return ListTile(
//                             dense: true,
//                             title: Text(opt.csCode ?? ''),
//                             subtitle: Text(opt.csName ?? ''),
//                             onTap: () => onSelected(opt),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _startDateController,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       labelText: 'Start Date',
//                       hintText: 'YYYY-MM-DD',
//                       suffixIcon: const Icon(Icons.calendar_today),
//                       border: const OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     onTap: () => _pickDate(_startDateController),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: _endDateController,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       labelText: 'End Date',
//                       hintText: 'YYYY-MM-DD',
//                       suffixIcon: const Icon(Icons.calendar_today),
//                       border: const OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     onTap: () => _pickDate(_endDateController),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: FilledButton.icon(
//                     onPressed: _isLoading ? null : _search,
//                     icon: const Icon(Icons.search),
//                     label: Text(_isLoading ? 'Searching...' : 'Search'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 OutlinedButton.icon(
//                   onPressed: _clear,
//                   icon: const Icon(Icons.clear),
//                   label: const Text('Clear'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResults(ColorScheme colorScheme) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (!_hasSearched) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.receipt_long,
//                 size: 64, color: colorScheme.onSurfaceVariant),
//             const SizedBox(height: 8),
//             Text('Use filters above to search collections',
//                 style: TextStyle(color: colorScheme.onSurfaceVariant)),
//           ],
//         ),
//       );
//     }
//     if (_headers.isEmpty) {
//       return Center(
//         child: Text('No records found',
//             style: TextStyle(color: colorScheme.onSurfaceVariant)),
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
//           child: Text('${_headers.length} record(s) found',
//               style: TextStyle(
//                   fontSize: 13, color: colorScheme.onSurfaceVariant)),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             itemCount: _headers.length,
//             itemBuilder: (context, index) {
//               final r = _headers[index];
//               final docNo = r[DBColumns.DOC_NO]?.toString() ?? '';
//               final csCode = r[DBColumns.CS_CODE]?.toString() ?? '';
//               final csName = r[DBColumns.CS_NAME]?.toString() ?? '';
//               final txnDate = r[DBColumns.TXN_DATE]?.toString() ?? '';
//               final payMode = r[DBColumns.PAY_MODE]?.toString() ?? '';
//               final total = (r[DBColumns.TOTAL_AMOUNT] as num?) ?? 0;
//               final syncSts = r[DBColumns.SYNSTS]?.toString() ?? '';
//
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: colorScheme.primaryContainer,
//                     child: Text(docNo.length > 2 ? docNo.substring(0, 2) : docNo,
//                         style: TextStyle(
//                             color: colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12)),
//                   ),
//                   title: Text('$csCode - $csName',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w600, fontSize: 13)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Doc: $docNo | Pay: $payMode'),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(txnDate,
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   color: colorScheme.onSurfaceVariant)),
//                           Text(
//                             NumberHelper.formatCurrency(total),
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: Icon(
//                     syncSts == 'SYNC'
//                         ? Icons.cloud_done
//                         : Icons.cloud_queue,
//                     size: 18,
//                     color: syncSts == 'SYNC' ? Colors.green : Colors.orange,
//                   ),
//                   isThreeLine: true,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
