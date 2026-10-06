import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:locafy/locafy.dart';
import 'package:provider/provider.dart';

import '../../../app/styles/app_text_style.dart';
import '../../../models/collection_model.dart';
import '../../../models/credit_note_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/invoice_model.dart';
import '../../../services/database/repositories/collection_db_repository.dart';
import '../../../services/database/repositories/credit_note_db_repository.dart';
import '../../../services/database/repositories/invoice_db_repository.dart';
import '../../../shared/components/app/app_dialog.dart';
import '../../../shared/components/app/app_scaffold.dart';
import '../../../shared/components/button/app_button.dart';
import '../../../shared/components/form/text_input_field.dart';
import '../../../shared/components/list/model_list_view.dart';
import '../../../shared/widgets/pay_mode_selection.dart';
import '../../../utils/formatters/text_input_formatters.dart';
import '../helpers/collection_ui_helper.dart';
import '../notifiers/invoice_setoff_notifier.dart';

class SubmitCollectionWidget extends StatefulWidget {
  final CustomerModel customer;
  final double receiptAmount;
  final PaymentDetails paymentDetails;
  final TextEditingController remarkController;

  const SubmitCollectionWidget({
    super.key,
    required this.customer,
    required this.receiptAmount,
    required this.paymentDetails,
    required this.remarkController,
  });

  @override
  State<SubmitCollectionWidget> createState() => _SubmitCollectionWidgetState();
}

class _SubmitCollectionWidgetState extends State<SubmitCollectionWidget> {
  /// Scroll controllers
  final _mainScrollController = ScrollController();

  /// Keys
  final _collectionKey =
      GlobalKey<ModelListViewState<CollectionSetOffModel>>();

  /// Notifiers
  late InvoiceSetOffNotifier notifier;

  /// Editing controllers
  late TextEditingController _remarkController;

  /// Focus nodes
  final _remarkFocus = FocusNode();

  /// Constants

  /// variables
  bool _isSubmitting = false;
  bool _canPop = false;

  /// Getters
  List<CollectionSetOffModel> get setOffs => notifier.setOffs;
  List<InvoiceModel> get invoices => notifier.invoices;
  List<CreditNoteModel> get creditNotes => notifier.creditNotes;
  double get receiptSetOffTotalAmount => notifier.receiptSetOffTotalAmount;
  double get setOffProgress => (receiptSetOffTotalAmount / widget.receiptAmount) * 100;
  ModelListViewState<CollectionSetOffModel>? get collectionState =>
      _collectionKey.currentState;


  @override
  void initState() {
    super.initState();
    _remarkController = widget.remarkController;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // if (mounted) setState(() {});
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = context.watch<InvoiceSetOffNotifier>();
  }

  void unfocus() {
    _remarkFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  void onCancel() async {
    Navigator.of(context).pop();
  }

  void onSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    unfocus();

    try {
      if (await _confirmIncompleteSetOffs()) {
        await _submitting();
      }

      if(_canPop && mounted){
        Navigator.of(context).pop(_canPop);
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

  Future<void> _submitting() async {
    final snackBar = AppSnackBar.instance;
    final loader = AppLoader.instance;

    try {
      loader.show();

      final position = await Locafy.instance.requestWithConfirmation(context);

      final currentUser = await IAMService.instance.currentUser();

      final header = CollectionHeaderModel(
        csCode: widget.customer.csCode,
        payMode: widget.paymentDetails.payMode,
        totalAmount: widget.receiptAmount,
        chqNo: widget.paymentDetails.chqNumber,
        chqDate: widget.paymentDetails.chqDate,
        bankCode: widget.paymentDetails.bank?.bankCode,
        branchCode: widget.paymentDetails.branch?.branchCode,
        ddRefNo: widget.paymentDetails.ddRefNumber,
        remark: _remarkController.text,
        gpsLat: position.latitude,
        gpsLng: position.longitude,
      );

      final details = setOffs
          .map(
            (e) => CollectionDetailModel(
              seqNo: e.seq,
              recDoc: e.recDoc,
              recNo: e.recNo,
              invDoc: e.invDoc,
              invNo: e.invNo,
              setOffAmount: e.setOffAmount.toDouble(),
              discount: e.discount.toDouble(),
            ),
          )
          .toList();

      final insertResult = await CollectionDbRepository.insertCollection(
        currentUser,
        header,
        details,
      );

      await InvoiceDbRepository.updateSetOffs(invoices);

      await CreditNoteDbRepository.updateSetOffs(creditNotes);

      snackBar.success(
        title: 'Payment Collection Submitted',
        message:
        'Payment collection was successfully submitted. '
            'Document No: ${insertResult.header?.docNo}',
      );

      _canPop = true;
    } catch (e) {
      snackBar.error(message: e.toString());
      debugPrint("ERROR: Collection Save: ${e.toString()}");
    } finally {
      loader.hide();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // final tt = Theme.of(context).textTheme;

    return AppScaffold(
      scrollController: _mainScrollController,
      appBar: AppBar(
        title: Text('Submit Collection'),
        titleTextStyle: AppTextStyle.of(context).smallAppBar,
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      enableScrollDownButton: true,
      scrollableBody: Column(children: [
        Container(
          height: kToolbarHeight * 2.8,
          padding: const .fromLTRB(24, 0, 24, 0),
          color: cs.surfaceContainerLow,
          child: CollectionUiHelper.of(context).receiptSummaryHeader(
            customer: widget.customer,
            paymentDetails: widget.paymentDetails,
            receiptAmount: widget.receiptAmount,
            setOffAmount: receiptSetOffTotalAmount,
          ),
        ),
        // Container(
        //   padding: const .fromLTRB(24, 24, 24, 0),
        //   child: CollectionUiHelper.of(
        //     context,
        //   ).receiptProgressCard(setOffProgress.abs()),
        // ),
        Container(
          padding: const .fromLTRB(24, 24, 24, 0),
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.width * 0.9),
          child: ModelListView<CollectionSetOffModel>(
            title: 'Set-off Records',
            subtitle: 'Review credit note allocations, discounts, and receipt set-offs before submitting.',
            key: _collectionKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            multiSelect: true,
            uniqueKey: (setOff) => setOff.seq,
            items: setOffs,
            enablePagination: true,
            enableSearch: true,
            searchMatcher: (setOff, query) =>
                setOff.searchKey.toLowerCase().contains(query.toLowerCase()),
            itemBuilder: (context, setOff, selected) {
              return CollectionUiHelper.of(
                context,
              ).setOffTile(setOff, true, onRemove: null);
            },
            separatorBuilder: (context, i) => SizedBox(height: 12),
            canSelect: (setOff) => false,
            // onMultiSelectChanged: onMultiSelectChanged,
          ),
        ),
        Container(
          padding: const .fromLTRB(24, 24, 24, 24),
          child: TextInputField(
            controller: _remarkController,
            focusNode: _remarkFocus,
            hint: 'Add your remark here',
            maxLines: 5,
            maxLength: 250,
            inputFormatters: TextInputFormatters.noteFormatter()
          ),
        ),
      ]),
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
        child: AppButton.of(context).filled(
          onPressed: onSubmit,
          label: 'Submit Collection',
          loading: _isSubmitting,
          loadingLabel: 'Submitting...'
        ),
      ),
    );
  }
}
