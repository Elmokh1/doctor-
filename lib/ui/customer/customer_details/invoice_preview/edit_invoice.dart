import 'package:el_doctor/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../../cubits/customer_cubit/customer_state.dart';
import '../../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_state.dart';
import '../../../../cubits/product_cubit/product__cubit.dart';
import '../../../../cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import '../../../../cubits/product_tranaction_cubit/product_transaction_state.dart';
import '../../../../data/model/customer_model.dart';
import '../../../../data/model/all_invoice_for_customer.dart';
import '../../../../data/model/customer_transaction_summary_model.dart';
import '../../../../data/model/proudct_transaction_model.dart';
import '../../../../utils/invoice_items_table.dart';
import '../../../../utils/totals_section.dart';
import '../../all_customer_invoice_transaction/widgets/invoice_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import '../../../../cubits/customer_invoice_cubit/customer_invoice_state.dart';

class EditCustomerInvoicePage extends StatefulWidget {
  final String invoiceId;

  const EditCustomerInvoicePage({super.key, required this.invoiceId});

  @override
  State<EditCustomerInvoicePage> createState() =>
      _EditCustomerInvoicePageState();
}

class _EditCustomerInvoicePageState extends State<EditCustomerInvoicePage> {
  CustomerModel? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoiceItems = [];
  double _discountPercent = 0.0;
  String _invoiceType = 'مبيعات';
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
      final state = context.read<CustomerInvoicesCubit>().state;
      if (state is CustomerInvoiceLoaded) {
        final invoice = state.invoices.firstWhere(
              (inv) => inv.id == widget.invoiceId,
          orElse: () => state.invoices.first,
        );
        _loadInvoiceData(invoice);
        _oldInvoiceData = invoice; // احتفظ بنسخة من الفاتورة القديمة
      }
    });
  }

  void _loadInvoiceData(CustomerInvoiceModel invoice) {
    // قراءة بيانات العميل من cubit لضمان قراءة الرصيد الصحيح
    final customerCubit = context.read<CustomerCubit>().state;
    if (customerCubit is CustomerLoaded) {
      _selectedCustomer = customerCubit.customers.firstWhere(
            (c) => c.id == invoice.customerId,
        orElse: () =>
            CustomerModel(id: invoice.customerId, name: invoice.customerName),
      );
    } else {
      _selectedCustomer = CustomerModel(
        id: invoice.customerId,
        name: invoice.customerName,
      );
    }

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
    _invoiceType = invoice.invoiceType ?? "مبيعات";

    _originalInvoiceTotal = invoice.totalBeforeDiscount ?? 0.0;
    _grandTotal = invoice.totalAfterDiscount ?? _originalInvoiceTotal;

    _dataLoaded = true;
    setState(() {});
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
    if (_selectedCustomer == null || _invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedCustomer == null
                ? 'select_customer_first'.tr()
                : 'add_at_least_one_product'.tr(),
          ),
        ),
      );
      return;
    }

    double debtBefore = _selectedCustomer?.openingBalance ?? 0.0;
    double debtAfter;

    if (_invoiceType == "مبيعات") {
      debtAfter = debtBefore - _originalInvoiceTotal + _grandTotal;
    } else {
      debtAfter = debtBefore + _originalInvoiceTotal - _grandTotal;
    }

    // تحديث رصيد العميل
    await context.read<CustomerCubit>().updateCustomerBalance(
      customerId: _selectedCustomer!.id!,
      newBalance: debtAfter,
    );

    double newDebtAfterInvoice = _invoiceType == "مبيعات"
        ? (_oldInvoiceData.debtBefore ?? 0.0) - _grandTotal
        : (_oldInvoiceData.debtBefore ?? 0.0) + _grandTotal;

    final newInvoice = CustomerInvoiceModel(
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name ?? '',
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
      totalBeforeDiscount:
      _invoiceItems.fold<double>(0.0, (sum, item) => sum + (item['total'] ?? 0.0)),
      totalAfterDiscount: _grandTotal,
      discount: _discountPercent,
      debtBefore: _oldInvoiceData.debtBefore,
      debtAfter: newDebtAfterInvoice,
      dateTime: _selectedDate,
    );

    final productCubit = context.read<ProductCubit>();
    final oldItems = _oldInvoiceData.items;

    // تعديل المخزون فقط قبل حفظ الفاتورة الجديدة
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
        increase: diff < 0,
      );
    }

    // حفظ الفاتورة الجديدة واسترجاع الـ ID
    await context.read<CustomerInvoicesCubit>().replaceCustomerInvoice(
      oldInvoice: _oldInvoiceData,
      newInvoice: newInvoice,
    );
    final newInvoiceId = newInvoice.id;

    // تحديث حركة المنتجات بعد الحصول على newInvoiceId
    for (var newItem in _invoiceItems) {
      final String productId = newItem['id'];
      final int newQty = newItem['quantity'];

      await context.read<ProductTransactionCubit>().updateTransaction(
        productId: productId,
        oldInvoiceId: _oldInvoiceData.id!,
        newQuantity: -newQty,
        newDate: _selectedDate,
        newInvoiceId: newInvoiceId!,
      );
    }

    // تحديث حركة العميل المرتبطة بالفاتورة
    final transactionCubit = context.read<CustomerTransactionSummaryCubit>();
    final transaction = (transactionCubit.state is CustomerTransactionSummaryLoaded
        ? (transactionCubit.state as CustomerTransactionSummaryLoaded)
        .transactions
        .firstWhere(
          (t) => t.invoiceId == _oldInvoiceData.id,
      orElse: () => CustomerTransactionSummaryModel(),
    )
        : CustomerTransactionSummaryModel());

    if (transaction.id != null) {
      final updatedTransaction = CustomerTransactionSummaryModel(
        id: transaction.id,
        customerId: transaction.customerId,
        customerName: transaction.customerName,
        transactionType: transaction.transactionType,
        invoiceId: newInvoiceId,
        invoiceNum: transaction.invoiceNum,
        debtBefore: transaction.debtBefore,
        debtAfter: newDebtAfterInvoice,
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

  void _openAddProductDialog() {}

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
                // تعديل الكمية مباشرة
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
                      value: 'مبيعات',
                      child: Text('sales'.tr()),
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
              selectedCustomer: _selectedCustomer,
              selectedDate: _selectedDate,
              onCustomerChanged: (customer) =>
                  setState(() => _selectedCustomer = customer),
              onDateSelected: _selectDate,
            ),
            const SizedBox(height: 40),

            // هنا قائمة المنتجات مع إمكانية تعديل الكمية مباشرة
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