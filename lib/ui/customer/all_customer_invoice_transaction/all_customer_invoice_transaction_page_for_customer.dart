import 'package:el_doctor/ui/customer/all_customer_invoice_transaction/widgets/invoice_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:el_doctor/cubits/customer_cubit/customer_cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product__cubit.dart';

import '../../../cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import '../../../cubits/sale_counter/sale_counter_cubit.dart';
import '../../../data/model/customer_model.dart';
import '../../../data/model/customer_transaction_summary_model.dart';
import '../../../data/model/product_model.dart';
import '../../../utils/invoice_items_table.dart';
import '../../../utils/product_dialog.dart';
import '../../../utils/totals_section.dart';

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  CustomerModel? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoiceItems = [];
  double _discountPercent = 0.0;
  String _invoiceType = 'مبيعات'; // يبقى عربي عند الحفظ
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerCubit>().getCustomers();
      context.read<ProductCubit>().loadProducts();
    });
  }

  double get _subtotal =>
      _invoiceItems.fold(0.0, (sum, item) => sum + (item['total'] as double));

  double get _discountAmount => _subtotal * (_discountPercent / 100);

  double get _grandTotal => _subtotal - _discountAmount;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _openAddProductDialog() {
    showAddProductDialog(context, (item) {
      setState(() => _invoiceItems.add(item));
    });
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

    final customerName = _selectedCustomer!.name ?? 'غير محدد';
    int currentCounter = await context.read<SaleCounterCubit>().getCounter();
    int invoiceId = currentCounter + 1;
    double debtBefore = _selectedCustomer!.openingBalance ?? 0.0;

    double debtAfter = _invoiceType == 'مبيعات'
        ? debtBefore + _grandTotal
        : debtBefore - _grandTotal;

    List<ProductModel> invoiceItemsForSaving = _invoiceItems.map((item) {
      return ProductModel(
        productName: item['name'],
        salePrice: item['price'],
        qun: item['quantity'],
        total: item['total'],
      );
    }).toList();

    final String invoiceTypeForSaving = _invoiceType; // يبقى عربي عند الحفظ

    // حفظ الفاتورة
    await context.read<CustomerInvoicesCubit>().addCustomerInvoice(
      id: invoiceId.toString(),
      customerId: _selectedCustomer!.id ?? '',
      customerName: customerName,
      invoiceType: invoiceTypeForSaving,
      items: invoiceItemsForSaving,
      totalBeforeDiscount: _subtotal,
      totalAfterDiscount: _grandTotal,
      discount: _discountAmount,
      debtBefore: debtBefore,
      debtAfter: debtAfter,
      dateTime: _selectedDate,
      notes: notesController.text.isNotEmpty
          ? notesController.text
          : (_discountAmount > 0
          ? "فاتورة $_invoiceType مع خصم $_discountAmount"
          : "فاتورة $_invoiceType"),
    );

    await context.read<SaleCounterCubit>().updateCounter();

    await context.read<CustomerCubit>().updateCustomerBalance(
      customerId: _selectedCustomer!.id ?? '',
      newBalance: debtAfter,
    );

    // تعديل كميات المنتجات
    bool increaseStock = _invoiceType == 'مرتجع';
    for (var item in _invoiceItems) {
      if (item['id'] != null && item['quantity'] != null) {
        await context.read<ProductCubit>().changeProductQuantity(
          productId: item['id'],
          amount: item['quantity'],
          increase: increaseStock,
        );
      }
    }

    final productTransactionCubit = context.read<ProductTransactionCubit>();

    for (var item in _invoiceItems) {
      final String productId = item['id'];
      final int quantity = item['quantity'];

      await productTransactionCubit.addTransaction(
        transactionNum: invoiceId.toString(),
        isCustomer: true,
        productId: productId,
        qun: _invoiceType == 'مبيعات' ? -quantity : quantity,
        name: _selectedCustomer!.name!,
        transactionType: _invoiceType,
        transactionDate: _selectedDate,
      );
    }

    // حركة العميل
    final transactionCubit = context.read<CustomerTransactionSummaryCubit>();
    await transactionCubit.addTransaction(
      CustomerTransactionSummaryModel(
        transactionType: _invoiceType,
        invoiceId: invoiceId.toString(),
        customerId: _selectedCustomer!.id!,
        customerName: customerName,
        amount: _grandTotal,
        debtBefore: debtBefore,
        debtAfter: debtAfter,
        notes: notesController.text.isNotEmpty
            ? notesController.text
            : (_discountAmount > 0
            ? "فاتورة $_invoiceType مع خصم $_discountAmount"
            : "فاتورة $_invoiceType"),
        dateTime: _selectedDate,
      ),
    );

    setState(() {
      _invoiceItems.clear();
      _discountPercent = 0.0;
      _selectedCustomer = null;
      _invoiceType = 'مبيعات';
      notesController.clear();
    });

    context.read<CustomerCubit>().getCustomers();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'تم حفظ الفاتورة $_invoiceType للعميل $customerName'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildAddProductButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_shopping_cart, size: 24),
      label: Text('add_product'.tr(), style: const TextStyle(fontSize: 18)),
      onPressed: _openAddProductDialog,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _invoiceType == 'مبيعات'
            ? Colors.teal.shade500
            : Colors.orange.shade700,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }

  Widget _buildInvoiceTypeSelector() {
    return Row(
      children: [
        Text('invoice_type'.tr(), style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: _invoiceType,
          items: [
            DropdownMenuItem(value: 'مبيعات', child: Text('sales'.tr())),
            DropdownMenuItem(value: 'مرتجع', child: Text('return'.tr())),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _invoiceType = value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('invoice_header'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
        elevation: 5,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildInvoiceTypeSelector(),
            const SizedBox(height: 20),
            InvoiceHeader(
              selectedCustomer: _selectedCustomer,
              selectedDate: _selectedDate,
              onCustomerChanged: (customer) =>
                  setState(() => _selectedCustomer = customer),
              onDateSelected: _selectDate,
            ),
            const SizedBox(height: 40),
            _buildAddProductButton(),
            const SizedBox(height: 30),
            InvoiceItemsTable(
              invoiceItems: _invoiceItems,
              onItemRemoved: (index) =>
                  setState(() => _invoiceItems.removeAt(index)),
            ),
            const SizedBox(height: 16),
            // ======== TextField for Notes ========
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
              subtotal: _subtotal,
              discountAmount: _discountAmount,
              grandTotal: _grandTotal,
              initialDiscount: _discountPercent,
              onDiscountChanged: (value) =>
                  setState(() => _discountPercent = value),
              onSavePressed: _saveInvoice,
            ),
          ],
        ),
      ),
    );
  }
}
