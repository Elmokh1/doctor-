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

enum TransactionFilter { all, payment, sales, refund }

class CustomerTransactionSummaryView extends StatefulWidget {
  final CustomerModel customer;

  const CustomerTransactionSummaryView({super.key, required this.customer});

  @override
  State<CustomerTransactionSummaryView> createState() =>
      _CustomerTransactionSummaryViewState();
}

class _CustomerTransactionSummaryViewState
    extends State<CustomerTransactionSummaryView> {
  late final CustomerTransactionSummaryCubit _cubit;
  TransactionFilter _filter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    _cubit = CustomerTransactionSummaryCubit()
      ..getTransactions(widget.customer.id!);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ======================= Excel Export =======================
  void _exportToExcel(BuildContext context, List<dynamic> transactions) async {
    if (transactions.isEmpty) return;

    final sortedData = List.from(transactions)
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    double runningBalance = 0;

    final excel = Excel.createExcel();
    final sheet = excel[widget.customer.name ?? "Transactions"];

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
      } else {
        runningBalance -= t.amount ?? 0;
      }

      sheet.appendRow([
        TextCellValue(t.transactionType),
        TextCellValue(dateFormat.format(t.dateTime!)),
        TextCellValue(t.invoiceNum ?? '-'),
        TextCellValue(t.notes ?? '-'),
        TextCellValue(t.transactionType == 'مبيعات' ? t.amount.toString() : ''),
        TextCellValue(t.transactionType != 'مبيعات' ? t.amount.toString() : ''),
        TextCellValue(runningBalance.toString()),
      ]);
    }

    final location = await getSaveLocation(
      suggestedName:
      '${widget.customer.name}_transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      acceptedTypeGroups: [
        XTypeGroup(label: 'Excel', extensions: ['xlsx']),
      ],
    );

    if (location == null) return;

    final bytes = excel.save();
    if (bytes != null) {
      final file = File(location.path);
      await file.writeAsBytes(bytes);
    }
  }

  // ======================= Filter Logic =======================
  List<dynamic> _applyFilter(List<dynamic> data) {
    switch (_filter) {
      case TransactionFilter.payment:
        return data.where((e) => e.transactionType == 'تحصيل').toList();
      case TransactionFilter.sales:
        return data.where((e) => e.transactionType == 'مبيعات').toList();
      case TransactionFilter.refund:
        return data.where((e) => e.transactionType == 'مرتجع').toList();
      case TransactionFilter.all:
      default:
        return data;
    }
  }

  double _calculateTotal(List<dynamic> data) {
    return data.fold(0.0, (sum, item) => sum + (item.amount ?? 0));
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.customer.name ?? ""),
          centerTitle: true,
          actions: [
            BlocBuilder<CustomerTransactionSummaryCubit,
                CustomerTransactionSummaryState>(
              builder: (context, state) {
                if (state is CustomerTransactionSummaryLoaded) {
                  final filteredData = _applyFilter(state.transactions);
                  return IconButton(
                    icon: const Icon(Icons.file_download),
                    tooltip: tr("export_to_excel"),
                    onPressed: () => _exportToExcel(context, filteredData),
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

            if (state is CustomerTransactionSummaryLoaded) {
              final filteredData = _applyFilter(state.transactions);
              final totalAmount = _calculateTotal(filteredData);

              double runningBalance = 0;

              return Column(
                children: [
                  // ================= Filters =================
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 12,
                      children: [
                        _buildRadio(TransactionFilter.all, tr("all")),
                        _buildRadio(TransactionFilter.payment, tr("payment")),
                        _buildRadio(TransactionFilter.sales, tr("invoice")),
                        _buildRadio(
                            TransactionFilter.refund, tr("credit_transaction")),
                      ],
                    ),
                  ),

                  // ================= Table =================
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: DataTable(
                            border:
                            TableBorder.all(color: Colors.black12),
                            columns: [
                              DataColumn(label: Text(tr("type"))),
                              DataColumn(label: Text(tr("date"))),
                              DataColumn(label: Text(tr("number"))),
                              DataColumn(label: Text(tr("memo"))),
                              DataColumn(label: Text(tr("amount"))),
                              DataColumn(label: Text(tr("balance"))),
                            ],
                            rows: filteredData.map((t) {
                              if (t.transactionType == 'مبيعات') {
                                runningBalance += t.amount ?? 0;
                              } else {
                                runningBalance -= t.amount ?? 0;
                              }

                              return DataRow(
                                cells: [
                                  DataCell(Text(t.transactionType)),
                                  DataCell(Text(
                                    dateFormat.format(
                                        t.dateTime ?? DateTime.now()),
                                  )),
                                  DataCell(
                                    InkWell(
                                      child: Text(t.invoiceNum ?? "-"),
                                      onTap: () {
                                        if (t.transactionType == "تحصيل") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ReceivePaymentByIdScreen(
                                                    paymentNum: t.invoiceNum!,
                                                    customerId: t.customerId,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CustomerInvoiceByIdScreen(
                                                    invoiceId: t.invoiceNum!,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(Text(t.notes ?? "-")),
                                  DataCell(Text(
                                      t.amount?.toStringAsFixed(2) ?? "0")),
                                  DataCell(Text(
                                      runningBalance.toStringAsFixed(2))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ================= Total =================
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade200,
                    width: double.infinity,
                    child: Text(
                      "${tr("total")} : ${totalAmount.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildRadio(TransactionFilter value, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<TransactionFilter>(
          value: value,
          groupValue: _filter,
          onChanged: (v) {
            setState(() => _filter = v!);
          },
        ),
        Text(title),
      ],
    );
  }
}