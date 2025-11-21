import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/vendor_bills_cubit/vendor_bills_cubit.dart';
import '../../../cubits/vendor_bills_cubit/vendor_bills_state.dart';
import '../../../data/model/all_invoice_for_customer.dart';
import '../../../data/model/product_model.dart';
import '../../customer/customer_details/print.dart';

class VendorBillByIdScreen extends StatelessWidget {
  final String billId;

  const VendorBillByIdScreen({super.key, required this.billId});

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "N/A";
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
    context.read<VendorBillCubit>().fetchBillsById(billId);

    return Scaffold(
      appBar: AppBar(
        title: Text("vendor_bill_details".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final state = context.read<VendorBillCubit>().state;
              if (state is VendorBillLoaded && state.bills.isNotEmpty) {
                final bill = state.bills.first;
                await Printing.layoutPdf(
                  onLayout: (format) => CustomerInvoicePDF.generateA4Invoice(bill),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<VendorBillCubit, VendorBillState>(
        builder: (context, state) {
          if (state is VendorBillLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (state is VendorBillError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is VendorBillLoaded) {
            if (state.bills.isEmpty) {
              return Center(
                child: Text(
                  "no_data_found".tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }

            final CustomerInvoiceModel bill = state.bills.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle("bill_info".tr()),
                  _buildBillHeaderCard(bill),
                  const SizedBox(height: 20),
                  _buildSectionTitle("products".tr()),
                  _buildProductTable(bill.items),
                  const SizedBox(height: 20),
                  _buildSectionTitle("financial_summary".tr()),
                  _buildFinancialSummaryCard(bill),
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
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade800,
        ),
      ),
    );
  }

  Widget _buildBillHeaderCard(CustomerInvoiceModel bill) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRowWithIcon(
              Icons.receipt_long,
              "bill_type".tr(),
              bill.invoiceType ?? "undefined".tr(),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.store,
              "vendor_name".tr(),
              bill.customerName ?? "unknown".tr(),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.calendar_today,
              "date".tr(),
              _formatDate(bill.dateTime),
            ),
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
          headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.deepPurple.shade50,
          ),
          columns: [
            DataColumn(label: Text("product".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("qty".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("price".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.productName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Center(child: Text("${product.qun ?? 0}"))),
                DataCell(Text("${product.salePrice?.toStringAsFixed(2) ?? 0.00} EGP")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(CustomerInvoiceModel bill) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow("total_before_discount".tr(), bill.totalBeforeDiscount, Colors.black87),
            _buildInfoRow("discount".tr(), bill.discount, Colors.red),
            const Divider(height: 15),
            _buildInfoRow("total_payable".tr(), bill.totalAfterDiscount, Colors.deepPurple.shade700, isTotal: true),
            const Divider(height: 20, thickness: 1.5),
            _buildInfoRow("previous_debt".tr(), bill.debtBefore, Colors.black54),
            _buildInfoRow("current_debt".tr(), bill.debtAfter, Colors.blue.shade700),
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
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ),
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
