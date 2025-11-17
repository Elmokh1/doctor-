import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';
import '../../data/model/receive_payment.dart';

class UniversalInvoiceListView<T> extends StatelessWidget {
  final T entity;
  final String Function(T) getName;

  const UniversalInvoiceListView({
    super.key,
    required this.entity,
    required this.getName,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("فواتير: ${getName(entity)}"),
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
              return const Center(
                child: Text(
                  "لا توجد فواتير بعد",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return Center(
              child: Container(
                width: 900,
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
                              "فاتورة رقم: ${invoice.id}",
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
                                "المبلغ: ${invoice.amount?.toStringAsFixed(2) ?? '0'} جنيه",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "التاريخ: ${invoice.dateTime != null ? dateFormat.format(invoice.dateTime!) : '--'}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => UniversalInvoiceDetailsCard(invoice: invoice),
                                //   ),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("عرض التفاصيل"),
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
