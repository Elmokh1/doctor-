import 'package:el_doctor/ui/customer/customer_details/payment_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_state.dart';
import '../../../data/model/customer_model.dart';
import 'invoice_preview.dart';

class CustomerTransactionSummaryView extends StatelessWidget {
  final CustomerModel customer;

  const CustomerTransactionSummaryView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocProvider(
      create: (_) =>
          CustomerTransactionSummaryCubit()..getTransactions(customer.id!),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(tr("customer_transactions", args: [?customer.name])),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body:
            BlocBuilder<
              CustomerTransactionSummaryCubit,
              CustomerTransactionSummaryState
            >(
              builder: (context, state) {
                if (state is CustomerTransactionSummaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerTransactionSummaryError) {
                  return Center(child: Text(state.message));
                }

                if (state is CustomerTransactionSummaryLoaded) {
                  final data = state.transactions;

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        tr("no_transactions"),
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          border: TableBorder.all(color: Colors.black12),
                          columns: [
                            DataColumn(label: Text(tr("type"))),
                            DataColumn(label: Text(tr("date"))),
                            DataColumn(label: Text(tr("number"))),
                            DataColumn(label: Text(tr("memo"))),
                            DataColumn(label: Text(tr("debt"))),
                            DataColumn(label: Text(tr("credit"))),
                            DataColumn(label: Text(tr("balance"))),
                          ],
                          rows: data.map((t) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    t.transactionType == 'مبيعات'
                                        ? tr("invoice")
                                        : t.transactionType == 'تحصيل'
                                        ? tr("payment")
                                        : t.transactionType == 'مرتجع'
                                        ? tr("credit_transaction")
                                        : "-",
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    t.dateTime != null
                                        ? dateFormat.format(t.dateTime!)
                                        : '--',
                                  ),
                                ),
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            if (t.transactionType == "تحصيل") {
                                              return ReceivePaymentByIdScreen(
                                                paymentId: t.invoiceId!,
                                                customerId: t.customerId!,
                                              );
                                            }
                                            return CustomerInvoiceByIdScreen(
                                              invoiceId: t.invoiceId!,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(t.invoiceId ?? "-"),
                                  ),
                                ),
                                DataCell(Text(t.notes ?? "-")),
                                t.transactionType == 'مبيعات'
                                    ? DataCell(
                                        Text(
                                          "${t.amount?.toStringAsFixed(2) ?? '0'}",
                                        ),
                                      )
                                    : DataCell(Text("")),
                                t.transactionType == 'مبيعات'
                                    ? DataCell(Text(""))
                                    : DataCell(
                                        Text(
                                          "${t.amount?.toStringAsFixed(2) ?? '0'}",
                                        ),
                                      ),
                                DataCell(
                                  Text(
                                    "${t.debtAfter?.toStringAsFixed(2) ?? '0'}",
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
      ),
    );
  }
}
