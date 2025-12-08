import 'package:el_doctor/cubits/buy_counter/buy_counter_cubit.dart';
import 'package:el_doctor/cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import 'package:el_doctor/cubits/vendor_bills_cubit/vendor_bills_cubit.dart';
import 'package:el_doctor/cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import 'package:el_doctor/cubits/vendors_cubit/vendor_cubit.dart';
import 'package:el_doctor/data/model/product_model.dart';
import 'package:el_doctor/data/model/vendor_model.dart';
import 'package:el_doctor/data/model/vendor_transaction_summary_model.dart';
import 'package:el_doctor/ui/vendors/all_vendor_invoice_transactions/widgets/invoice_header.dart';
import 'package:el_doctor/utils/invoice_items_table.dart';
import 'package:el_doctor/utils/product_dialog.dart';
import 'package:el_doctor/utils/totals_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_doctor/cubits/product_cubit/product__cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class AddVendorInvoicePage extends StatefulWidget {
  const AddVendorInvoicePage({super.key});

  @override
  State<AddVendorInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddVendorInvoicePage> {
  VendorModel? _selectedVendor;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoiceItems = [];
  double _discountPercent = 0.0;

  String _invoiceType = 'شراء';

  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorCubit>().getVendors();
      context.read<ProductCubit>().loadProducts();
    });
  }

  double get _subtotal =>
      _invoiceItems.fold(0.0, (sum, item) => sum + (item['total'] as double));

  double get _discountAmount => _subtotal * (_discountPercent / 100);

  double get _grandTotal => _subtotal - _discountAmount;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: context.locale,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _openAddProductDialog() {
    showAddProductDialog(
      context,
          (item) {
        setState(() => _invoiceItems.add(item));
      },
      isSale: false,  // ← هنا التعديل
    );
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

    final vendorName = _selectedVendor!.name ?? 'undefined'.tr();
    int currentCounter = await context.read<BuyCounterCubit>().getCounter();
    int invoiceId = currentCounter + 1;
    double debtBefore = _selectedVendor!.openingBalance ?? 0.0;

    double debtAfter = _invoiceType == 'شراء'
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

    await context.read<VendorBillCubit>().addVendorBill(
      id: invoiceId.toString(),
      vendorId: _selectedVendor!.id ?? '',
      vendorName: vendorName,
      invoiceType: _invoiceType,
      items: invoiceItemsForSaving,
      totalBeforeDiscount: _subtotal,
      totalAfterDiscount: _grandTotal,
      discount: _discountAmount,
      debtBefore: debtBefore,
      debtAfter: debtAfter,
      dateTime: _selectedDate,
    );

    await context.read<BuyCounterCubit>().updateCounter();

    await context.read<VendorCubit>().updateVendorBalance(
      vendorId: _selectedVendor!.id ?? '',
      newBalance: debtAfter,
    );

    bool increaseStock = _invoiceType == 'شراء';

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
        isCustomer: false,
        productId: productId,
        qun: _invoiceType == 'مرتجع' ? -quantity : quantity,
        name: _selectedVendor!.name!,
        transactionType: _invoiceType,
        transactionDate: _selectedDate,
      );
    }

    await context.read<VendorTransactionSummaryCubit>().addTransaction(
      VendorTransactionSummaryModel(
        transactionType: _invoiceType,
        invoiceId: invoiceId.toString(),
        vendorId: _selectedVendor!.id!,
        vendorName: vendorName,
        amount: _grandTotal,
        debtBefore: debtBefore,
        debtAfter: debtAfter,
        notes: notesController.text.isNotEmpty
            ? notesController.text
            : (_discountAmount > 0
            ? 'invoice_with_discount'
            .tr(args: [_invoiceType, _discountAmount.toStringAsFixed(2)])
            : 'invoice'.tr(args: [_invoiceType])),
        dateTime: _selectedDate,
      ),
    );

    setState(() {
      _invoiceItems.clear();
      _discountPercent = 0.0;
      _selectedVendor = null;
      notesController.clear();
      _invoiceType = 'شراء';
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('invoice_saved'
            .tr(args: [_invoiceType, vendorName])),
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
        backgroundColor: _invoiceType == 'شراء'
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
            DropdownMenuItem(value: 'شراء', child: Text('buy'.tr())),
            DropdownMenuItem(value: 'مرتجع', child: Text('return'.tr())),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _invoiceType = value.trim();
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vendor_invoice'.tr(),
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
              selectedVendor: _selectedVendor,
              selectedDate: _selectedDate,
              onVendorChanged: (vendor) =>
                  setState(() => _selectedVendor = vendor),
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
