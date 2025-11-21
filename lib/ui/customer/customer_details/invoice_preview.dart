import 'package:el_doctor/ui/customer/customer_details/print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import '../../../../../cubits/customer_invoice_cubit/customer_invoice_state.dart';
import '../../../../../data/model/all_invoice_for_customer.dart';
import '../../../../../data/model/product_model.dart';

class CustomerInvoiceByIdScreen extends StatelessWidget {
  final String invoiceId;

  const CustomerInvoiceByIdScreen({super.key, required this.invoiceId});

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return tr('n_a');
    if (dateValue is DateTime) return DateFormat('yyyy-MM-dd').format(dateValue);
    if (dateValue is String) {
      try {
        return dateValue.split(" ")[0];
      } catch (_) {
        return dateValue;
      }
    }
    return dateValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    context.read<CustomerInvoicesCubit>().fetchInvoicesById(invoiceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('invoice_details'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final state = context.read<CustomerInvoicesCubit>().state;
              if (state is CustomerInvoiceLoaded && state.invoices.isNotEmpty) {
                final invoice = state.invoices.first;
                await Printing.layoutPdf(
                  onLayout: (format) => CustomerInvoicePDF.generateA4Invoice(invoice),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerInvoicesCubit, CustomerInvoiceState>(
        builder: (context, state) {
          if (state is CustomerInvoiceLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (state is CustomerInvoiceError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is CustomerInvoiceLoaded) {
            if (state.invoices.isEmpty) {
              return Center(
                child: Text(tr('no_data_for_invoice'), style: const TextStyle(fontSize: 18)),
              );
            }

            final CustomerInvoiceModel invoice = state.invoices.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(tr('invoice_info')),
                  _buildInvoiceHeaderCard(invoice),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('products')),
                  _buildProductTable(invoice.items),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('notes')),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(invoice.notes ?? tr('no_notes'), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('financial_summary')),
                  _buildFinancialSummaryCard(invoice),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
    );
  }

  Widget _buildInvoiceHeaderCard(CustomerInvoiceModel invoice) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRowWithIcon(Icons.receipt_long, tr('invoice_type'), invoice.invoiceType ?? tr('undefined')),
            const Divider(),
            _buildInfoRowWithIcon(Icons.person, tr('customer_name'), invoice.customerName ?? tr('unknown')),
            const Divider(),
            _buildInfoRowWithIcon(Icons.calendar_today, tr('date'), _formatDate(invoice.dateTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(List<ProductModel> products) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade50),
          columns: [
            DataColumn(label: Text(tr('product'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(tr('qty'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(tr('price'), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(cells: [
              DataCell(Text(product.productName ?? tr('n_a'), style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(Center(child: Text("${product.qun ?? 0}"))),
              DataCell(Text("${product.salePrice?.toStringAsFixed(2) ?? 0.00} EGP")),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(CustomerInvoiceModel invoice) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(tr('total_before_discount'), invoice.totalBeforeDiscount, Colors.black87),
            _buildInfoRow(tr('discount'), invoice.discount, Colors.red),
            const Divider(height: 15),
            _buildInfoRow(tr('total_payable'), invoice.totalAfterDiscount, Colors.teal.shade700, isTotal: true),
            const Divider(height: 20, thickness: 1.5),
            _buildInfoRow(tr('previous_debt'), invoice.debtBefore, Colors.black54),
            _buildInfoRow(tr('current_debt'), invoice.debtAfter, Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, double? value, Color valueColor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text("${value?.toStringAsFixed(2) ?? 0.00} EGP", style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
