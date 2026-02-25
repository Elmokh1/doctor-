import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/money_transaction_cubit/money_transaction_cubit.dart';
import '../../data/model/money_transaction_model.dart';

class AllMoneyTransactionsPage extends StatefulWidget {
  const AllMoneyTransactionsPage({super.key});

  @override
  State<AllMoneyTransactionsPage> createState() =>
      _AllMoneyTransactionsPageState();
}

class _AllMoneyTransactionsPageState
    extends State<AllMoneyTransactionsPage> {
  DateTimeRange? _selectedRange;

  // ======================= Excel Export =======================
  void _exportToExcel(
      BuildContext context,
      List<MoneyTransactionModel> transactions,
      ) async {
    if (transactions.isEmpty) return;

    final sortedData = List.from(transactions)
      ..sort((a, b) =>
          (a.transactionDate ?? DateTime(2000))
              .compareTo(b.transactionDate ?? DateTime(2000)));

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    final headers = [
      tr("date"),
      tr("details"),
      tr("type"),
      tr("amount"),
      tr("direction"),
    ];

    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var t in sortedData) {
      sheet.appendRow([
        TextCellValue(
          t.transactionDate != null
              ? dateFormat.format(t.transactionDate!)
              : '--',
        ),
        TextCellValue(t.transactionDetails ?? '-'),
        TextCellValue(t.transactionType ?? '-'),
        TextCellValue((t.amount ?? 0).toStringAsFixed(2)),
        TextCellValue(
          t.isIncome == true ? tr("income") : tr("expense"),
        ),
      ]);
    }

    final fileName =
        'Money_Transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

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
        const SnackBar(content: Text('تم حفظ ملف الإكسيل بنجاح')),
      );
    }
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MoneyTransactionCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text("all_transactions".tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "filter_by_date".tr(),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
              );

              if (range != null) {
                setState(() {
                  _selectedRange = range;
                });
              }
            },
          ),
          if (_selectedRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: "clear_filter".tr(),
              onPressed: () {
                setState(() {
                  _selectedRange = null;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<List<MoneyTransactionModel>>(
        stream: cubit.getAllTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("error_fetching_data".tr()));
          }

          final transactions = snapshot.data ?? [];

          final filteredTransactions = _selectedRange == null
              ? transactions
              : transactions.where((t) {
            if (t.transactionDate == null) return false;

            return t.transactionDate!.isAfter(
                _selectedRange!.start
                    .subtract(const Duration(days: 1))) &&
                t.transactionDate!.isBefore(
                    _selectedRange!.end
                        .add(const Duration(days: 1)));
          }).toList();

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Text(
                _selectedRange == null
                    ? "no_transactions_yet".tr()
                    : "no_transactions_in_range".tr(),
              ),
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IconButton(
                    icon: const Icon(Icons.file_download),
                    tooltip: "export_excel".tr(),
                    onPressed: () =>
                        _exportToExcel(context, filteredTransactions),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // اسكرول رأسي
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      scrollDirection: Axis.horizontal, // اسكرول أفقي
                      child: DataTable(
                        headingRowColor:
                        MaterialStateProperty.all(Colors.black),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        dataRowColor:
                        MaterialStateProperty.all(Colors.white),
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        columns: [
                          DataColumn(label: Text("date".tr())),
                          DataColumn(label: Text("details".tr())),
                          DataColumn(label: Text("type".tr())),
                          DataColumn(label: Text("amount".tr())),
                          DataColumn(label: Text("direction".tr())),
                        ],
                        rows: filteredTransactions.map((t) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  t.transactionDate != null
                                      ? "${t.transactionDate!.day}/${t.transactionDate!.month}/${t.transactionDate!.year}"
                                      : "-",
                                ),
                              ),
                              DataCell(
                                Text(t.transactionDetails ?? ""),
                              ),
                              DataCell(
                                Text(t.transactionType ?? ""),
                              ),
                              DataCell(
                                Text(
                                  t.amount?.toStringAsFixed(2) ?? "0",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  t.isIncome == true
                                      ? "income".tr()
                                      : "expense".tr(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}