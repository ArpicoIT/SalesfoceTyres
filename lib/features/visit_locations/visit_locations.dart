import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:locafy/locafy.dart';

import '../../models/customer_model.dart';
import '../../models/visit_model.dart';
import '../../services/database/db_columns.dart';
import '../../services/database/db_helper.dart';
import '../../services/database/db_tables.dart';
import '../../services/database/repositories/customer_db_repository.dart';
import '../../services/database/repositories/sync_db_repository.dart';
import '../../services/database/repositories/visit_location_db_repository.dart';
import '../../shared/components/app/app_scaffold.dart';
import '../../shared/components/button/app_button.dart';
import '../../shared/components/form/async_search_picker.dart';
import '../../shared/components/form/text_input_field.dart';
import '../../shared/components/form/responsive_form_field.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../utils/formatters/text_input_formatters.dart';

class VisitLocationsView extends StatefulWidget {
  const VisitLocationsView({super.key});

  @override
  State<VisitLocationsView> createState() => _VisitLocationsViewState();
}

class _VisitLocationsViewState extends State<VisitLocationsView> {
  final _mainScroll = ScrollController();

  final _remarkCtrl = TextEditingController();

  final _customerFocus = FocusNode();
  final _remarkFocus = FocusNode();

  CustomerModel? _selectedCustomer;
  List<VisitItem> items = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayVisits();
    });

    super.initState();
  }

  Future<void> _loadTodayVisits() async {
    if (mounted && !_isLoading) setState(() => _isLoading = true);

    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();
      final visitList = await VisitLocationDbRepository.getTodayVisits(
        currentUser,
      );

      final items = await Future.wait(
        visitList.map((visit) async {
          final customer = await DBHelper.querySingle(
            DBTables.CUSTOMERS,
            where: '${DBColumns.CS_CODE} = ?',
            whereArgs: [visit.csCode],
          ).then((res) => res != null ? CustomerModel.fromJson(res) : null);

          return VisitItem(visit: visit, customer: customer);
        }),
      );

      this.items
        ..clear()
        ..addAll(items);
    } catch (e) {
      snackBar.error(message: e.toString());
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  Future<List<CustomerModel>> fetchCustomers() async {
    final snackBar = AppSnackBar.instance;
    try {
      final currentUser = await IAMService.instance.currentUser();

      return await CustomerDbRepository.getAllCustomers(currentUser);
    } catch (e) {
      snackBar.error(message: e.toString());
    }

    return [];
  }

  bool _validateForm() {
    final snackBar = AppSnackBar.instance;

    if (_selectedCustomer == null) {
      snackBar.info(message: 'Please select a customer');
      return false;
    }

    if (_remarkCtrl.text.isEmpty) {
      snackBar.info(message: 'Please enter remark');
      return false;
    }

    return true;
  }

  void _clearForm() {
    _selectedCustomer = null;
    _remarkCtrl.clear();
  }

  void _unfocus() {
    _customerFocus.unfocus();
    _remarkFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  void onSave() async {
    if (_isSaving) {
      return;
    }
    _isSaving = true;

    final snackBar = AppSnackBar.instance;
    final loader = AppLoader.instance;

    if (!_validateForm()) {
      _isSaving = false;
      return;
    }

    _unfocus();

    try {
      loader.show();

      final position = await Locafy.instance.requestWithConfirmation(context);

      final currentUser = await IAMService.instance.currentUser();

      final visit = VisitModel(
        csCode: _selectedCustomer?.csCode,
        remark: _remarkCtrl.text,
        gpsLat: position.latitude,
        gpsLng: position.longitude,
      );

      final insertResult = await VisitLocationDbRepository.insert(
        currentUser,
        visit,
      );

      snackBar.success(
        title: "Visit ID: ${insertResult.id}",
        message: "Your visit has been saved successfully.",
      );

      _clearForm();

      await _mainScroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      SyncDbRepository.visitLocations().then((value) {
        _loadTodayVisits();
      });

    } catch (e) {
      snackBar.error(message: e.toString());
      debugPrint("ERROR: Visit Save: ${e.toString()}");
    } finally {
      loader.hide();
      _isSaving = false;
      if (mounted) setState(() {});
    }
  }

  void onClear() {
    _unfocus();
    _clearForm();
    if (mounted) setState(() {});
  }

  void onChangedCustomer(CustomerModel? value) async {
    _clearForm();

    if (value != null) {
      _selectedCustomer = value;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Visit Locations',
      defaultPadding: true,
      scrollController: _mainScroll,
      scrollableBody: Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [
          buildRecordVisit(),
          const SizedBox(height: 20),
          buildRecentVisits(),
        ],
      ),
    );
  }

  Widget buildRecordVisit() {
    return SectionCard(
      title: "Record Visit",
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
              loadItems: fetchCustomers,
            ),
          ),
          ResponsiveFormField(
            title: 'Remark',
            child: TextInputField(
              filled: false,
              controller: _remarkCtrl,
              focusNode: _remarkFocus,
              hint: 'Add your remark here',
              maxLines: 5,
              maxLength: 250,
              inputFormatters: TextInputFormatters.noteFormatter()
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 16,
            crossAxisAlignment: .center,
            children: [
              Expanded(
                child: AppButton.of(context).cancel(
                  onPressed: onClear,
                  label: 'Clear',
                ),
              ),
              Expanded(child: AppButton.of(context).save(onPressed: onSave)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRecentVisits() {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return AppEmptyView(
        icon: Icons.location_history_rounded,
        title: 'No visits recorded yet',
        message:
            'Record your visit to using above form.\nIf not pull down or tap refresh to load the latest visits.',
        buttonText: 'Refresh',
        onPressed: _loadTodayVisits,
      );
    }

    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        SectionHeader(
          title: 'Recent Visits',
          subtitle: '${items.length} record(s)',
          showRefresh: true,
          onRefresh: _loadTodayVisits,
        ),

        ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final v = items[index];
            final csCode = v.customer?.csCode ?? '';
            final csName = v.customer?.csName ?? '';
            final txnDate = v.visit?.txnDate?.toString() ?? '';
            final remark = v.visit?.remark ?? '';
            final syncStatus = v.visit?.synSts;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: .antiAlias,
              child: ListTile(
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
                    Text(remark, maxLines: 2, overflow: .ellipsis),
                    Text(
                      txnDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: syncStatus == .PEND
                    ? Icon(Icons.sync, size: 18, color: Colors.grey)
                    : syncStatus == .SUCC
                    ? Icon(
                        Icons.cloud_sync_rounded,
                        size: 18,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.sync_problem_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                isThreeLine: true,
                // onTap: () => openCollectionDetailsSheet(v),
              ),
            );
          },
        ),
      ],
    );
  }
}
