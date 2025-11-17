import 'package:el_doctor/ui/all_invoice_transaction_page/widgets/invoice_header.dart';
import 'package:el_doctor/ui/all_invoice_transaction_page/widgets/product_dialog.dart';
import 'package:el_doctor/ui/all_invoice_transaction_page/widgets/totals_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_doctor/cubits/customer_cubit/customer_cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product_cubit.dart';
import '../../cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import '../../cubits/sale_counter/sale_counter_cubit.dart';
import '../../data/model/customer_model.dart';
import '../../data/model/product_model.dart';
import 'widgets/invoice_items_table.dart';

class AddSaleInvoicePage extends StatefulWidget {
  const AddSaleInvoicePage({super.key});

  @override
  State<AddSaleInvoicePage> createState() => _AddSaleInvoicePageState();
}

class _AddSaleInvoicePageState extends State<AddSaleInvoicePage> {
  CustomerModel? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoiceItems = [];
  double _discountPercent = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerCubit>().getCustomers();
      context.read<ProductCubit>().loadProducts();
    });
  }

  // 💡 الحسابات (Getters)
  double get _subtotal => _invoiceItems.fold(0.0, (sum, item) => sum + (item['total'] as double));
  double get _discountAmount => _subtotal * (_discountPercent / 100);
  double get _grandTotal => _subtotal - _discountAmount;

  // 💡 دوال مساعدة
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

  // 💡 دالة حفظ الفاتورة (لا يوجد تغيير في المنطق)
  Future<void> _saveInvoice() async {
    if (_selectedCustomer == null || _invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedCustomer == null ? 'اختر العميل أولاً' : 'أضف منتجًا واحدًا على الأقل')),
      );
      return;
    }

    final customerName = _selectedCustomer!.name ?? 'غير محدد';
    int currentCounter = await context.read<SaleCounterCubit>().getCounter();
    int invoiceId = currentCounter + 1;
    double debtBefore = _selectedCustomer!.openingBalance ?? 0.0;
    double debtAfter = debtBefore + _grandTotal;

    List<ProductModel> invoiceItemsForSaving = _invoiceItems.map((item) {
      return ProductModel(
        productName: item['name'],
        salePrice: item['price'],
        qun: item['quantity'],
        total: item['total'],
      );
    }).toList();

    await context.read<CustomerInvoicesCubit>().addCustomerInvoice(
      id: invoiceId.toString(),
      customerId: _selectedCustomer!.id ?? '',
      customerName: customerName,
      invoiceType: 'sale',
      items: invoiceItemsForSaving,
      totalBeforeDiscount: _subtotal,
      totalAfterDiscount: _grandTotal,
      discount: _discountAmount,
      debtBefore: debtBefore,
      debtAfter: debtAfter,
      dateTime: _selectedDate,
    );

    await context.read<SaleCounterCubit>().updateCounter();

    await context.read<CustomerCubit>().updateCustomerBalance(
      customerId: _selectedCustomer!.id ?? '',
      newBalance: debtAfter,
    );

    for (var item in _invoiceItems) {
      if (item['id'] != null && item['quantity'] != null) {
        await context.read<ProductCubit>().changeProductQuantity(
          productId: item['id'],
          amount: item['quantity'],
          increase: false,
        );
      }
    }

    setState(() {
      _invoiceItems.clear();
      _discountPercent = 0.0;
      _selectedCustomer = null;
    });

    context.read<CustomerCubit>().getCustomers();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الفاتورة بنجاح للعميل $customerName'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildAddProductButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_shopping_cart, size: 24),
      label: const Text('إضافة منتج', style: TextStyle(fontSize: 18)),
      onPressed: _openAddProductDialog,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal.shade500,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة مبيعات جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
            // 1. الرأس (مستخرج سابقاً)
            InvoiceHeader(
              selectedCustomer: _selectedCustomer,
              selectedDate: _selectedDate,
              onCustomerChanged: (customer) => setState(() => _selectedCustomer = customer),
              onDateSelected: _selectDate,
            ),

            const SizedBox(height: 40),

            // 2. زر إضافة المنتج
            _buildAddProductButton(),

            const SizedBox(height: 30),

            // 3. جدول المنتجات (مستخرج الآن)
            InvoiceItemsTable(
              invoiceItems: _invoiceItems,
              onItemRemoved: (index) => setState(() => _invoiceItems.removeAt(index)),
            ),

            const SizedBox(height: 40),

            // 4. الإجماليات (مستخرج سابقاً)
            TotalsAndDiscountSection(
              subtotal: _subtotal,
              discountAmount: _discountAmount,
              grandTotal: _grandTotal,
              initialDiscount: _discountPercent,
              onDiscountChanged: (value) => setState(() => _discountPercent = value),
              onSavePressed: _saveInvoice,
            ),
          ],
        ),
      ),
    );
  }
}