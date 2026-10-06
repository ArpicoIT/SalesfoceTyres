import 'package:flutter/material.dart';

import '../../../models/collection_model.dart';
import '../../../models/credit_note_model.dart';
import '../../../models/invoice_model.dart';
import '../../../services/database/db_constants.dart';

class InvoiceSetOffNotifier extends ChangeNotifier {
  InvoiceModel _selectedInvoice;
  List<InvoiceModel> _invoices;
  List<CreditNoteModel> _creditNotes;
  List<CollectionSetOffModel> _setOffs;

  InvoiceSetOffNotifier({
    InvoiceModel? invoice,
    List<InvoiceModel> invoices = const [],
    List<CreditNoteModel> creditNotes = const [],
    List<CollectionSetOffModel> setOffs = const [],
  }) : _selectedInvoice = invoice ?? InvoiceModel.defaults(),
       _invoices = List.of(invoices),
       _creditNotes = List.of(creditNotes),
       _setOffs = List.of(setOffs);

  InvoiceModel get selectedInvoice => _selectedInvoice;
  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);
  List<CreditNoteModel> get creditNotes => List.unmodifiable(_creditNotes);
  List<CollectionSetOffModel> get setOffs => List.unmodifiable(_setOffs);


  List<CollectionSetOffModel> get selectedInvoiceCreditCollections {
    return _setOffs
        .where(
          (e) =>
              e.recType == DBConstants.DOC_CREDIT_NOTE &&
              e.invDoc == _selectedInvoice.docCode &&
              e.invNo == _selectedInvoice.docNo,
        )
        .toList();
  }

  double get receiptSetOffTotalAmount {
    return _setOffs.where((e) => e.recType == DBConstants.DOC_INVOICE).fold(
      0.0,
      (previousValue, element) => previousValue + element.setOffAmount,
    );
  }

  /// Selected Invoice setters
  void setSelectedInvoice(InvoiceModel invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  void updateSelectedInvoice(
    InvoiceModel Function(InvoiceModel current) updater,
  ) {
    _selectedInvoice = updater(_selectedInvoice);
    notifyListeners();
  }

  void clearSelectedInvoice() {
    _selectedInvoice = InvoiceModel.defaults();
    notifyListeners();
  }

  /// Invoices setters
  void setInvoices(List<InvoiceModel> invoices) {
    _invoices = List.of(invoices);
    notifyListeners();
  }

  void updateInvoices(
    List<InvoiceModel> Function(List<InvoiceModel> current) updater,
  ) {
    _invoices = List.of(updater(_invoices));
    notifyListeners();
  }

  void updateInvoiceAt(
    int index,
    InvoiceModel Function(InvoiceModel invoice) updater,
  ) {
    if (index < 0 || index >= _invoices.length) return;

    _invoices[index] = updater(_invoices[index]);
    notifyListeners();
  }

  void updateInvoiceWhere({
    required bool Function(InvoiceModel item) matcher,
    required InvoiceModel Function(InvoiceModel invoice) updater
  }) {
    final index = _invoices.indexWhere(matcher);

    if (index == -1) return;

    _invoices[index] = updater(_invoices[index]);
    notifyListeners();
  }

  void clearInvoices() {
    _invoices = [];
    notifyListeners();
  }

  /// Credit Note setters
  void setCreditNotes(List<CreditNoteModel> creditNotes) {
    _creditNotes = List.of(creditNotes);
    notifyListeners();
  }

  void updateCreditNotes(
    List<CreditNoteModel> Function(List<CreditNoteModel> current) updater,
  ) {
    _creditNotes = List.of(updater(_creditNotes));
    notifyListeners();
  }

  void updateCreditNoteAt(
    int index,
    CreditNoteModel Function(CreditNoteModel creditNote) updater,
  ) {
    if (index < 0 || index >= _creditNotes.length) return;

    _creditNotes[index] = updater(_creditNotes[index]);
    notifyListeners();
  }

  void updateCreditNoteWhere({
    required bool Function(CreditNoteModel item) matcher,
    required CreditNoteModel Function(CreditNoteModel creditNote) updater,
  }) {
    final index = _creditNotes.indexWhere(matcher);

    if (index == -1) return;

    _creditNotes[index] = updater(_creditNotes[index]);
    notifyListeners();
  }

  void clearCreditNotes() {
    _creditNotes = [];
    notifyListeners();
  }

  /// Set Off setters
  void addSetOff(CollectionSetOffModel setOff) {
    updateSetOffs((current) => [...current, setOff]);
  }

  void setSetOffs(List<CollectionSetOffModel> setOffs) {
    _setOffs = List.of(setOffs);
    notifyListeners();
  }

  void updateSetOffs(
    List<CollectionSetOffModel> Function(List<CollectionSetOffModel> current)
    updater,
  ) {
    _setOffs = _resequenceSetOffs(updater(_setOffs));
    notifyListeners();
  }

  void clearSetOffs() {
    _setOffs = [];
    notifyListeners();
  }

  void removeSetOffWhere(bool Function(CollectionSetOffModel item) test) {
    updateSetOffs((current) => current.where((item) => !test(item)).toList());
  }

  List<CollectionSetOffModel> _resequenceSetOffs(
    List<CollectionSetOffModel> items,
  ) {
    return [
      for (int i = 0; i < items.length; i++) items[i].copyWith(seq: i + 1),
    ];
  }
}
