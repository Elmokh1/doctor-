import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_state.dart';
import '../../../data/model/pay_vendor.dart';

class PaymentToVendor extends StatelessWidget {
  final String paymentId;
  final String vendorId;

  const PaymentToVendor({
    super.key,
    required this.paymentId,
    required this.vendorId,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  String _formatCurrency(double? value) {
    if (value == null) return '0.00';
    return '${value.toStringAsFixed(2)} EGP';
  }

  @override
  Widget build(BuildContext context) {
    context.read<PayVendorInvoiceCubit>().fetchPaymentById(
      vendorId,
      paymentId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('payment_receipt_details'.tr()),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<PayVendorInvoiceCubit, PayVendorInvoiceState>(
        builder: (context, state) {
          if (state is PayVendorInvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PayVendorInvoiceError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is PayVendorInvoiceLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Text('no_data_found_for_receipt'.tr()),
              );
            }

            final PayVendorModel payment = state.transactions.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('receipt_information'.tr()),
                  _infoCard(
                    children: [
                      _labeledRow('receipt_id'.tr(), payment.id ?? '-'),
                      _labeledRow('vendor_name'.tr(), payment.customerName ?? '-'),
                      _labeledRow('date'.tr(), _formatDate(payment.dateTime)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('payment_details'.tr()),
                  _infoCard(
                    children: [
                      _labeledRow('balance_before'.tr(), _formatCurrency(payment.oldBalance)),
                      _labeledRow('received_amount'.tr(), _formatCurrency(payment.amount)),
                      const Divider(),
                      _labeledRow('balance_after'.tr(), _formatCurrency(payment.newBalance)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('transaction_notes'.tr()),
                  _infoCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          payment.transactionDetails?.isNotEmpty == true
                              ? payment.transactionDetails!
                              : 'no_notes_available'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text('back'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _labeledRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
