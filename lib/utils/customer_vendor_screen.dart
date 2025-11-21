import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';

class UniversalInvoiceListView<T> extends StatelessWidget {
  final T entity;
  final String Function(T) getName;
  final double Function(dynamic invoice) invoiceAmount;
  final DateTime? Function(dynamic invoice) invoiceDate;
  final void Function(dynamic invoice)? onDetailsPressed;

  const UniversalInvoiceListView({
    super.key,
    required this.entity,
    required this.getName,
    required this.invoiceAmount,
    required this.invoiceDate,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(tr("invoices_for") + ": ${getName(entity)}"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<ReceivedPaymentInvoiceCubit, ReceivedPaymentInvoiceState>(
        builder: (context, state) {
          if (state is ReceivedPaymentInvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceivedPaymentInvoiceError) {
            return Center(child: Text(state.message));
          }

          if (state is ReceivedPaymentInvoiceLoaded) {
            final invoices = state.transactions;

            if (invoices.isEmpty) {
              return Center(
                child: Text(
                  tr("no_invoices_yet"),
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final amount = invoiceAmount(invoice).toStringAsFixed(2);
                    final date = invoiceDate(invoice) != null
                        ? dateFormat.format(invoiceDate(invoice)!)
                        : '--';

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${tr("invoice_number")}: ${invoice.id}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${tr("amount")}: $amount ${tr("egp")}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "${tr("date")}: $date",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (onDetailsPressed != null) {
                                  onDetailsPressed!(invoice);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(tr("show_details")),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
