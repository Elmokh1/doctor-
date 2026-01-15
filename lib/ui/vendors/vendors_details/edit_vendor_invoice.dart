import 'package:el_doctor/cubits/vendor_bills_cubit/vendor_bills_cubit.dart';
import 'package:el_doctor/cubits/vendor_bills_cubit/vendor_bills_state.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/product_cubit/product__cubit.dart';
import '../../../cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_state.dart';
import '../../../cubits/vendors_cubit/vendor_cubit.dart';
import '../../../data/model/vendor_model.dart';
import '../../../data/model/product_model.dart';
import '../../../data/model/vendor_transaction_summary_model.dart';
import '../../../data/model/all_invoice_for_customer.dart';
import '../../../utils/totals_section.dart';
import '../all_vendor_invoice_transactions/widgets/invoice_header.dart';

class EditVendorInvoicePage extends StatefulWidget {
  final String invoiceId;

  const EditVendorInvoicePage({super.key, required this.invoiceId});

  @override
  State<EditVendorInvoicePage> createState() => _EditVendorInvoicePageState();
}

class _EditVendorInvoicePageState extends State<EditVendorInvoicePage> {
  VendorModel? _selectedVendor;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoiceItems = [];
  double _discountPercent = 0.0;
  String _invoiceType = 'شراء';
  final TextEditingController notesController = TextEditingController();

  bool _dataLoaded = false;
  double _originalInvoiceTotal = 0.0;
  double _grandTotal = 0.0;
  late CustomerInvoiceModel _oldInvoiceData;

  @override
  void initState() {
    super.initState();
    // تحميل بيانات الفاتورة بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<VendorBillCubit>().state;
      if (state is VendorBillLoaded) {
        final invoice = state.bills.firstWhere(
          (inv) => inv.id == widget.invoiceId,
          orElse: () => state.bills.first,
        );
        _loadInvoiceData(invoice);
        _oldInvoiceData = invoice; // نسخة الفاتورة القديمة
      }
    });
  }

  void _loadInvoiceData(CustomerInvoiceModel invoice) {
    _selectedVendor = VendorModel(
      id: invoice.customerId,
      name: invoice.customerName,
    );

    _selectedDate = invoice.dateTime ?? DateTime.now();
    _invoiceItems = invoice.items.map((p) {
      double total = (p.qun ?? 0) * (p.salePrice ?? 0.0);
      return {
        'id': p.id,
        'name': p.productName ?? '',
        'quantity': p.qun ?? 0,
        'price': p.salePrice ?? 0.0,
        'total': total,
      };
    }).toList();

    _discountPercent = invoice.discount ?? 0.0;
    notesController.text = invoice.notes ?? "";
    _invoiceType = invoice.invoiceType ?? "شراء";

    _originalInvoiceTotal = invoice.totalBeforeDiscount ?? 0.0;
    _grandTotal = invoice.totalAfterDiscount ?? _originalInvoiceTotal;

    _dataLoaded = true;
    setState(() {});
    print(_selectedVendor!.openingBalance);
  }

  void _recalculateTotals() {
    _grandTotal = _invoiceItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] ?? 0.0),
    );
    _grandTotal -= _discountPercent;
    setState(() {});
  }

  Future<void> _saveInvoice() async {
    if (_selectedVendor == null || _invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedVendor == null
                ? 'select_vendor_first'.tr()
                : 'add_at_least_one_product'.tr(),
          ),
        ),
      );
      return;
    }

    // الحصول على رصيد المورد قبل التعديل
    double debtBefore =
        context
            .read<VendorCubit>()
            .getVendorById(_selectedVendor!.id!)
            ?.openingBalance ??
        0.0;

    // الفرق بين الفاتورة الجديدة والقديمة
    double debtDiff = _grandTotal - _originalInvoiceTotal;

    // حساب الرصيد بعد التعديل
    double debtAfter = debtBefore + debtDiff;

    // تحديث رصيد المورد في الكيوبت
    await context.read<VendorCubit>().updateVendorBalance(
      vendorId: _selectedVendor!.id!,
      newBalance: debtAfter,
    );

    // إنشاء نسخة الفاتورة الجديدة مع الحفاظ على invoiceNum
    final newInvoice = CustomerInvoiceModel(
      customerId: _selectedVendor!.id!,
      customerName: _selectedVendor!.name ?? '',
      invoiceType: _invoiceType,
      notes: notesController.text,
      items: _invoiceItems
          .map(
            (item) => ProductModel(
              id: item['id'],
              productName: item['name'],
              qun: item['quantity'],
              salePrice: item['price'],
              total: item['total'],
            ),
          )
          .toList(),
      totalBeforeDiscount: _invoiceItems.fold<double>(
        0.0,
        (sum, item) => sum + (item['total'] ?? 0.0),
      ),
      totalAfterDiscount: _grandTotal,
      discount: _discountPercent,
      debtBefore: _oldInvoiceData.debtBefore,
      debtAfter: debtAfter,
      dateTime: _selectedDate,
      invoiceNum: _oldInvoiceData.invoiceNum, // <<< المحافظة على الرقم
    );

    final productCubit = context.read<ProductCubit>();
    final oldItems = _oldInvoiceData.items;

    // تعديل المخزون حسب الفرق
    for (var newItem in _invoiceItems) {
      final String productId = newItem['id'];
      final int newQty = newItem['quantity'];

      final oldItem = oldItems.firstWhere(
        (e) => e.id == productId,
        orElse: () => ProductModel(id: productId, qun: 0),
      );

      final int oldQty = oldItem.qun ?? 0;
      final int diff = newQty - oldQty;

      await productCubit.changeProductQuantity(
        productId: productId,
        amount: diff.abs(),
        increase: diff > 0,
      );
    }

    // استبدال الفاتورة القديمة بالجديدة في VendorBillCubit
    await context.read<VendorBillCubit>().replaceVendorBill(
      oldBill: _oldInvoiceData,
      newBill: newInvoice,
    );

    final newInvoiceId = newInvoice.id;

    // تحديث حركة المنتجات بعد الحصول على newInvoiceId
    final productTransactionCubit = context.read<ProductTransactionCubit>();
    for (var newItem in _invoiceItems) {
      final String productId = newItem['id'];
      final int newQty = newItem['quantity'];

      await productTransactionCubit.updateTransaction(
        productId: productId,
        oldInvoiceId: _oldInvoiceData.id!,
        newQuantity: _invoiceType == 'شراء' ? newQty : -newQty,
        newDate: _selectedDate,
        newInvoiceId: newInvoiceId!,
      );
    }

    // تحديث حركة المورد المرتبطة بالفاتورة
    final transactionCubit = context.read<VendorTransactionSummaryCubit>();
    final transaction =
        (transactionCubit.state is VendorTransactionSummaryLoaded
        ? (transactionCubit.state as VendorTransactionSummaryLoaded)
              .transactions
              .firstWhere(
                (t) => t.invoiceId == _oldInvoiceData.id,
                orElse: () => VendorTransactionSummaryModel(),
              )
        : VendorTransactionSummaryModel());

    if (transaction.id != null) {
      final updatedTransaction = VendorTransactionSummaryModel(
        id: transaction.id,
        vendorId: transaction.vendorId,
        vendorName: transaction.vendorName,
        transactionType: transaction.transactionType,
        invoiceId: newInvoiceId,
        invoiceNum: transaction.invoiceNum,
        // الحفاظ على رقم الفاتورة
        debtBefore: transaction.debtBefore,
        debtAfter: debtAfter,
        amount: _grandTotal,
        dateTime: transaction.dateTime,
        notes: transaction.notes,
      );

      await transactionCubit.updateTransaction(updatedTransaction);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("invoice_updated_successfully".tr())),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildInvoiceItemsList() {
    return Column(
      children: _invoiceItems.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Text(item['name'])),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: item['quantity'].toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      int newQty = int.tryParse(val) ?? 0;
                      setState(() {
                        item['quantity'] = newQty;
                        item['total'] = newQty * (item['price'] ?? 0.0);
                        _recalculateTotals();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'qty'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text((item['total'] ?? 0.0).toStringAsFixed(2)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'edit_invoice'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
        elevation: 5,
        toolbarHeight: 80,
      ),
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'invoice_type'.tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<String>(
                        value: _invoiceType,
                        items: [
                          DropdownMenuItem(
                            value: 'شراء',
                            child: Text('buy'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'مرتجع',
                            child: Text('return'.tr()),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _invoiceType = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InvoiceHeader(
                    selectedVendor: _selectedVendor,
                    selectedDate: _selectedDate,
                    onVendorChanged: (vendor) =>
                        setState(() => _selectedVendor = vendor),
                    onDateSelected: _selectDate,
                  ),
                  const SizedBox(height: 40),
                  _buildInvoiceItemsList(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'notes'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TotalsAndDiscountSection(
                    subtotal: _invoiceItems.fold<double>(
                      0.0,
                      (sum, item) => sum + (item['total'] ?? 0.0),
                    ),
                    discountAmount: _discountPercent,
                    grandTotal: _grandTotal,
                    initialDiscount: _discountPercent,
                    onDiscountChanged: (value) {
                      setState(() => _discountPercent = value);
                      _recalculateTotals();
                    },
                    onSavePressed: _saveInvoice,
                  ),
                ],
              ),
            ),
    );
  }
}
