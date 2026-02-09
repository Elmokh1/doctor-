import 'dart:io';
import 'dart:ui' as ui;

import 'package:el_doctor/ui/vendors/vendors_details/bills_preview.dart';
import 'package:el_doctor/ui/vendors/vendors_details/payment_to_vendor_preview.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart' as excel_format;

import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_state.dart';
import '../../../data/model/vendor_model.dart';

class VendorTransactionSummaryView extends StatelessWidget {
  final VendorModel vendor;

  const VendorTransactionSummaryView({super.key, required this.vendor});

  // ======================= Excel Export =======================
  void _exportSummaryToExcel(
    BuildContext context,
    List<dynamic> transactions,
    String vendorName,
  ) async {
    if (transactions.isEmpty) return;

    final sortedData = List.from(transactions)
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    double runningBalance = 0; // 🔴 من الصفر فقط

    final excel = excel_format.Excel.createExcel();
    final sheet = excel[tr("vendor_summary_report")];

    final headers = [
      tr('type'),
      tr('date'),
      tr('num'),
      tr('memo'),
      tr('debt'),
      tr('credit'),
      tr('balance'),
    ];

    sheet.appendRow(headers.map((e) => excel_format.TextCellValue(e)).toList());

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var t in sortedData) {
      if (t.transactionType == 'شراء') {
        runningBalance += t.amount ?? 0;
      } else if (t.transactionType == 'دفع' || t.transactionType == 'مرتجع') {
        runningBalance -= t.amount ?? 0;
      }

      sheet.appendRow([
        excel_format.TextCellValue(
          t.transactionType == 'شراء'
              ? tr('invoice')
              : t.transactionType == 'دفع'
              ? tr('payment')
              : tr('credit'),
        ),
        excel_format.TextCellValue(
          t.dateTime != null ? dateFormat.format(t.dateTime!) : '--',
        ),
        excel_format.TextCellValue(t.invoiceNum ?? '-'),
        excel_format.TextCellValue(t.notes ?? '-'),
        excel_format.TextCellValue(
          t.transactionType == 'شراء' ? (t.amount ?? 0).toStringAsFixed(2) : '',
        ),
        excel_format.TextCellValue(
          t.transactionType != 'شراء' ? (t.amount ?? 0).toStringAsFixed(2) : '',
        ),
        excel_format.TextCellValue(runningBalance.toStringAsFixed(2)),
      ]);
    }

    final fileName =
        'VendorSummary_${vendorName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الملف بنجاح')));
    }
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocProvider(
      create: (_) =>
          VendorTransactionSummaryCubit()..getTransactions(vendor.id!),
      child: Scaffold(
        appBar: AppBar(
          title: Text("vendor_transactions".tr(args: [vendor.name ?? ""])),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          actions: [
            BlocBuilder<
              VendorTransactionSummaryCubit,
              VendorTransactionSummaryState
            >(
              builder: (context, state) {
                if (state is VendorTransactionSummaryLoaded &&
                    state.transactions.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () => _exportSummaryToExcel(
                      context,
                      state.transactions,
                      vendor.name ?? '',
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body:
            BlocBuilder<
              VendorTransactionSummaryCubit,
              VendorTransactionSummaryState
            >(
              builder: (context, state) {
                if (state is VendorTransactionSummaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VendorTransactionSummaryError) {
                  return Center(child: Text(state.message));
                }

                if (state is VendorTransactionSummaryLoaded) {
                  final sortedData = List.from(state.transactions)
                    ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

                  double runningBalance = 0; // 🔴 من الصفر فقط

                  return Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.deepPurple.shade50,
                        ),
                        border: TableBorder.all(color: Colors.black12),
                        columns: [
                          DataColumn(label: Text('type'.tr())),
                          DataColumn(label: Text('date'.tr())),
                          DataColumn(label: Text('num'.tr())),
                          DataColumn(label: Text('memo'.tr())),
                          DataColumn(label: Text('debt'.tr())),
                          DataColumn(label: Text('credit'.tr())),
                          DataColumn(label: Text('balance'.tr())),
                        ],
                        rows: sortedData.map((t) {
                          if (t.transactionType == 'شراء') {
                            runningBalance += t.amount ?? 0;
                          } else if (t.transactionType == 'دفع' ||
                              t.transactionType == 'مرتجع') {
                            runningBalance -= t.amount ?? 0;
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  t.transactionType == 'شراء'
                                      ? 'invoice'.tr()
                                      : t.transactionType == 'دفع'
                                      ? 'payment'.tr()
                                      : 'credit'.tr(),
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
                                    if (t.transactionType == "دفع") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PaymentToVendor(
                                            vendorId: t.vendorId!,
                                            paymentId: t.invoiceId!,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VendorBillByIdScreen(
                                            billId: t.invoiceNum!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    t.invoiceNum ?? "-",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(t.notes ?? "-")),
                              DataCell(
                                t.transactionType == 'شراء'
                                    ? Text(t.amount?.toStringAsFixed(2) ?? '0')
                                    : const Text(""),
                              ),
                              DataCell(
                                t.transactionType != 'شراء'
                                    ? Text(t.amount?.toStringAsFixed(2) ?? '0')
                                    : const Text(""),
                              ),
                              DataCell(Text(runningBalance.toStringAsFixed(2))),
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
