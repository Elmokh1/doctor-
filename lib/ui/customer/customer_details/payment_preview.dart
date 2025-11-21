import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';
import '../../../data/model/receive_payment.dart';

class ReceivePaymentByIdScreen extends StatelessWidget {
  final String paymentId;
  final String customerId;

  const ReceivePaymentByIdScreen({
    super.key,
    required this.paymentId,
    required this.customerId,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return tr('n_a');
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  String _formatCurrency(double? value) {
    if (value == null) return '0.00';
    return '${value.toStringAsFixed(2)} EGP';
  }

  @override
  Widget build(BuildContext context) {
    context.read<ReceivedPaymentInvoiceCubit>().fetchReceivedPaymentById(
      customerId,
      paymentId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('payment_receipt_details')),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body:
      BlocBuilder<ReceivedPaymentInvoiceCubit, ReceivedPaymentInvoiceState>(
        builder: (context, state) {
          if (state is ReceivedPaymentInvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceivedPaymentInvoiceError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is ReceivedPaymentInvoiceLoaded) {
            if (state.transactions.isEmpty) {
              return Center(child: Text(tr('no_data_for_receipt')));
            }

            final ReceivePaymentModel payment = state.transactions.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(tr('receipt_info')),
                  _infoCard(children: [
                    _labeledRow(tr('receipt_id'), payment.id ?? '-'),
                    _labeledRow(tr('customer_name'), payment.customerName ?? '-'),
                    _labeledRow(tr('date'), _formatDate(payment.dateTime)),
                  ]),
                  const SizedBox(height: 16),

                  _sectionTitle(tr('payment_details')),
                  _infoCard(children: [
                    _labeledRow(tr('balance_before'), _formatCurrency(payment.oldBalance)),
                    _labeledRow(tr('received_amount'), _formatCurrency(payment.amount)),
                    const Divider(),
                    _labeledRow(tr('balance_after'), _formatCurrency(payment.newBalance)),
                  ]),
                  const SizedBox(height: 16),

                  _sectionTitle(tr('transaction_notes')),
                  _infoCard(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        payment.transactionDetails?.isNotEmpty == true
                            ? payment.transactionDetails!
                            : tr('no_notes'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(tr('back')),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
