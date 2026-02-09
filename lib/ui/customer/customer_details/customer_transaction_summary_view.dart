import 'dart:io';
import 'dart:ui' as ui;

import 'package:el_doctor/ui/customer/customer_details/payment_preview.dart';
import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_state.dart';
import '../../../data/model/customer_model.dart';
import 'invoice_preview/invoice_preview.dart';

class CustomerTransactionSummaryView extends StatelessWidget {
  final CustomerModel customer;

  const CustomerTransactionSummaryView({
    super.key,
    required this.customer,
  });

  // ======================= Excel Export =======================
  void _exportToExcel(BuildContext context, List<dynamic> transactions) async {
    if (transactions.isEmpty) return;

    // ترتيب من الأقدم للأحدث
    final sortedData = List.from(transactions)
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    double runningBalance = 0; // 🔴 من الصفر فقط

    final excel = Excel.createExcel();
    final sheet = excel[customer.name ?? "Transactions"];

    final headers = [
      tr("type"),
      tr("date"),
      tr("number"),
      tr("memo"),
      tr("debt"),
      tr("credit"),
      tr("balance"),
    ];

    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var t in sortedData) {
      if (t.transactionType == 'مبيعات') {
        runningBalance += t.amount ?? 0;
      } else if (t.transactionType == 'تحصيل' ||
          t.transactionType == 'مرتجع') {
        runningBalance -= t.amount ?? 0;
      }

      sheet.appendRow([
        TextCellValue(
          t.transactionType == 'مبيعات'
              ? tr("invoice")
              : t.transactionType == 'تحصيل'
              ? tr("payment")
              : tr("credit_transaction"),
        ),
        TextCellValue(
            t.dateTime != null ? dateFormat.format(t.dateTime!) : '--'),
        TextCellValue(t.invoiceNum ?? '-'),
        TextCellValue(t.notes ?? '-'),
        TextCellValue(
            t.transactionType == 'مبيعات'
                ? (t.amount ?? 0).toStringAsFixed(2)
                : ''),
        TextCellValue(
            t.transactionType != 'مبيعات'
                ? (t.amount ?? 0).toStringAsFixed(2)
                : ''),
        TextCellValue(runningBalance.toStringAsFixed(2)),
      ]);
    }

    final fileName =
        '${customer.name}_Transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'Excel', extensions: ['xlsx']),
      ],
    );

    if (location == null) return;

    final bytes = excel.save();
    if (bytes != null) {
      final file = File(location.path);
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الملف بنجاح')),
      );
    }
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocProvider(
      create: (_) =>
      CustomerTransactionSummaryCubit()..getTransactions(customer.id!),
      child: Scaffold(
        appBar: AppBar(
          title: Text(customer.name ?? ""),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          actions: [
            BlocBuilder<CustomerTransactionSummaryCubit,
                CustomerTransactionSummaryState>(
              builder: (context, state) {
                if (state is CustomerTransactionSummaryLoaded &&
                    state.transactions.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () =>
                        _exportToExcel(context, state.transactions),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body: BlocBuilder<CustomerTransactionSummaryCubit,
            CustomerTransactionSummaryState>(
          builder: (context, state) {
            if (state is CustomerTransactionSummaryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerTransactionSummaryError) {
              return Center(child: Text(state.message));
            }

            if (state is CustomerTransactionSummaryLoaded) {
              if (state.transactions.isEmpty) {
                return Center(child: Text(tr("no_transactions")));
              }

              final sortedData = List.from(state.transactions)
                ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

              double runningBalance = 0; // 🔴 من الصفر فقط

              return Directionality(
                textDirection: ui.TextDirection.ltr,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                    MaterialStateProperty.all(Colors.blue.shade50),
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
                    rows: sortedData.map((t) {
                      if (t.transactionType == 'مبيعات') {
                        runningBalance += t.amount ?? 0;
                      } else if (t.transactionType == 'تحصيل' ||
                          t.transactionType == 'مرتجع') {
                        runningBalance -= t.amount ?? 0;
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            t.transactionType == 'مبيعات'
                                ? tr("invoice")
                                : t.transactionType == 'تحصيل'
                                ? tr("payment")
                                : tr("credit_transaction"),
                          )),
                          DataCell(Text(
                            t.dateTime != null
                                ? dateFormat.format(t.dateTime!)
                                : '--',
                          )),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      if (t.transactionType == "تحصيل") {
                                        return ReceivePaymentByIdScreen(
                                          paymentId: t.invoiceNum!,
                                          customerId: t.customerId!,
                                        );
                                      }
                                      return CustomerInvoiceByIdScreen(
                                        invoiceId: t.invoiceNum!,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Text(t.invoiceNum ?? "-"),
                            ),
                          ),
                          DataCell(Text(t.notes ?? "-")),
                          DataCell(
                            t.transactionType == 'مبيعات'
                                ? Text(
                                t.amount?.toStringAsFixed(2) ?? '0')
                                : const Text(""),
                          ),
                          DataCell(
                            t.transactionType != 'مبيعات'
                                ? Text(
                                t.amount?.toStringAsFixed(2) ?? '0')
                                : const Text(""),
                          ),
                          DataCell(
                            Text(runningBalance.toStringAsFixed(2)),
                          ),
                        ],
                      );
                    }).toList(),
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
