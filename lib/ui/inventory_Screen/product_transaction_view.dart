import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import '../../cubits/product_tranaction_cubit/product_transaction_state.dart';
import '../../data/model/proudct_transaction_model.dart';
import '../customer/customer_details/invoice_preview/invoice_preview.dart';
import '../vendors/vendors_details/bills_preview.dart';

enum TransactionFilter { all, sales, purchases }

class ProductTransactionsPage extends StatefulWidget {
  final String productId;
  final String productName;
  final String qun;

  const ProductTransactionsPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.qun,
  });

  @override
  State<ProductTransactionsPage> createState() =>
      _ProductTransactionsPageState();
}

class _ProductTransactionsPageState extends State<ProductTransactionsPage> {
  DateTimeRange? _selectedRange;
  TransactionFilter _filter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    context.read<ProductTransactionCubit>().loadTransactions(widget.productId);
  }

  // ================== FILTER ==================
  List<ProductTransactionModel> _applyFilters(
      List<ProductTransactionModel> transactions,
      ) {
    var filtered = transactions;

    // date filter
    if (_selectedRange != null) {
      filtered = filtered.where((t) {
        if (t.transactionDate == null) return false;
        return t.transactionDate!.isAfter(
          _selectedRange!.start.subtract(const Duration(days: 1)),
        ) &&
            t.transactionDate!.isBefore(
              _selectedRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    // type filter
    if (_filter == TransactionFilter.sales) {
      filtered = filtered.where((t) => t.isCustomer == true).toList();
    } else if (_filter == TransactionFilter.purchases) {
      filtered = filtered.where((t) => t.isCustomer == false).toList();
    }

    return filtered;
  }

  int _totalQuantity(List<ProductTransactionModel> items) {
    return items.fold(0, (sum, t) => sum + (t.qun ?? 0));
  }

  // ================== EXPORT ==================
  void _exportToExcel(List<ProductTransactionModel> transactions) async {
    if (transactions.isEmpty) return;

    final sortedData = List.from(transactions)
      ..sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));

    final excel = Excel.createExcel();
    final sheet = excel[widget.productName];

    final headers = ["Name", "Invoice No", "Type", "Date", "Quantity"];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var t in sortedData) {
      sheet.appendRow([
        TextCellValue(t.name ?? "-"),
        TextCellValue(t.transactionNum ?? "-"),
        TextCellValue(t.transactionType ?? "-"),
        TextCellValue(
          t.transactionDate != null
              ? dateFormat.format(t.transactionDate!)
              : "-",
        ),
        TextCellValue((t.qun ?? 0).toString()),
      ]);
    }

    final fileName =
        '${widget.productName}_Transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text("product_movements".tr() + " — ${widget.productName}"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
              );
              if (range != null) {
                setState(() => _selectedRange = range);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              final state = context.read<ProductTransactionCubit>().state;
              if (state is ProductTransactionLoaded) {
                final filtered = _applyFilters(state.transactions);
                _exportToExcel(filtered);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductTransactionCubit, ProductTransactionState>(
        builder: (context, state) {
          if (state is ProductTransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductTransactionError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (state is ProductTransactionLoaded) {
            final items = _applyFilters(state.transactions);
            final totalQun = _totalQuantity(items);

            if (items.isEmpty) {
              return Center(
                child: Text(
                  "no_movements_found".tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return Column(
              children: [
                // product info
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: Colors.black12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${"product".tr()}: ${widget.productName}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${"quantity".tr()}: ${widget.qun}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // ================= RADIO BUTTONS =================
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<TransactionFilter>(
                        value: TransactionFilter.all,
                        groupValue: _filter,
                        onChanged: (v) => setState(() => _filter = v!),
                      ),
                      const Text("الكل"),

                      Radio<TransactionFilter>(
                        value: TransactionFilter.sales,
                        groupValue: _filter,
                        onChanged: (v) => setState(() => _filter = v!),
                      ),
                      const Text("مبيعات"),

                      Radio<TransactionFilter>(
                        value: TransactionFilter.purchases,
                        groupValue: _filter,
                        onChanged: (v) => setState(() => _filter = v!),
                      ),
                      const Text("مشتريات"),
                    ],
                  ),
                ),

                // ================= DATE FILTER CHIP =================
                if (_selectedRange != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Chip(
                      label: Text(
                        "${dateFormat.format(_selectedRange!.start)}"
                            "  →  "
                            "${dateFormat.format(_selectedRange!.end)}",
                      ),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() => _selectedRange = null);
                      },
                    ),
                  ),

                // ================= TABLE =================
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 48,
                        dataRowHeight: 44,
                        columnSpacing: 50,
                        border: TableBorder.all(color: Colors.black),
                        headingRowColor:
                        MaterialStateProperty.all(Colors.black12),
                        columns: [
                          DataColumn(
                            label: Text("name".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text("invoice_no".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text("type".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text("date".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text("quantity".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: items.map((t) {
                          return DataRow(cells: [
                            DataCell(Text(t.name ?? "unknown".tr())),
                            DataCell(
                              InkWell(
                                child: Text(
                                  t.transactionNum ?? "-",
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                ),
                                onTap: () {
                                  if (t.isCustomer == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CustomerInvoiceByIdScreen(
                                              invoiceId: t.transactionNum ?? "",
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VendorBillByIdScreen(
                                          billId: t.transactionNum ?? "",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            DataCell(Text(t.transactionType ?? "")),
                            DataCell(Text(
                              t.transactionDate != null
                                  ? dateFormat
                                  .format(t.transactionDate!)
                                  : "-",
                            )),
                            DataCell(Text(
                              "${t.qun ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // ================= TOTAL =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  color: Colors.black12,
                  child: Text(
                    "إجمالي الكمية: $totalQun",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
