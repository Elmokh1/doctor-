import 'package:el_doctor/ui/vendors/vendors_details/bills_preview.dart';
import 'package:el_doctor/ui/vendors/vendors_details/payment_to_vendor_preview.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

// الإضافات اللازمة للتصدير إلى Excel
import 'dart:io';
import 'package:excel/excel.dart' as excel_format;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_state.dart';
import '../../../data/model/vendor_model.dart';

class VendorTransactionSummaryView extends StatelessWidget {
  final VendorModel vendor;

  const VendorTransactionSummaryView({super.key, required this.vendor});

  // **********************************************
  //           دالة التصدير إلى Excel
  // **********************************************
  void _exportSummaryToExcel(
      BuildContext context, List<dynamic> transactions, String vendorName) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("vendor_summary_report")];
    final int maxCols = 7;
    int rowIndex = 0;

    final dateFormat = DateFormat('dd/MM/yyyy');

    // 1. العنوان الرئيسي
    sheetObject.merge(
        excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue("${vendorName}")
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: excel_format.HorizontalAlign.Center,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFD3E8E5"),
      );
    rowIndex++;
    rowIndex++;

    // 2. رؤوس الأعمدة
    excel_format.CellStyle headerStyle = excel_format.CellStyle(
      bold: true,
      backgroundColorHex: excel_format.ExcelColor.fromHexString("FFD3E8E5"),
      horizontalAlign: excel_format.HorizontalAlign.Center,
      topBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
      bottomBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
    );

    List<String> headers = [
      tr('type'), tr('date'), tr('num'), tr('memo'), tr('debt'), tr('credit'), tr('balance'),
    ];
    sheetObject.appendRow(headers.map((h) => excel_format.TextCellValue(h)).toList());

    for (int col = 0; col < headers.length; col++) {
      sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex)).cellStyle = headerStyle;
    }

    rowIndex++;

    // 3. إضافة البيانات
    excel_format.CellStyle dataStyle = excel_format.CellStyle(
      horizontalAlign: excel_format.HorizontalAlign.Right,
      numberFormat: excel_format.NumFormat.custom(formatCode: '#,##0.00'),
      topBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
      bottomBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
    );

    excel_format.CellStyle textStyle = excel_format.CellStyle(
      horizontalAlign: excel_format.HorizontalAlign.Center,
      topBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
      bottomBorder: excel_format.Border(borderStyle: excel_format.BorderStyle.Thin),
    );

    for (var t in transactions) {
      String typeLabel = t.transactionType == 'شراء'
          ? tr('invoice')
          : t.transactionType == 'دفع'
          ? tr('payment')
          : t.transactionType == 'مرتجع'
          ? tr('credit')
          : '-';

      String dateStr = t.dateTime != null
          ? dateFormat.format(t.dateTime!)
          : '--';

      String debtAmount = t.transactionType == 'شراء'
          ? (t.amount?.toStringAsFixed(2) ?? '0.00')
          : '0.00';

      String creditAmount = t.transactionType != 'شراء'
          ? (t.amount?.toStringAsFixed(2) ?? '0.00')
          : '0.00';


      List<excel_format.CellValue> rowData = [
        excel_format.TextCellValue(typeLabel),
        excel_format.TextCellValue(dateStr),
        excel_format.TextCellValue(t.invoiceId ?? "-"),
        excel_format.TextCellValue(t.notes ?? "-"),
        excel_format.TextCellValue(debtAmount),
        excel_format.TextCellValue(creditAmount),
        excel_format.TextCellValue(t.debtAfter?.toStringAsFixed(2) ?? '0.00'),
      ];

      sheetObject.appendRow(rowData);

      // تطبيق التنسيق على الصف
      for (int col = 0; col < rowData.length; col++) {
        sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex)).cellStyle = (col < 4) ? textStyle : dataStyle;
        sheetObject.setColumnWidth(col, col == 3 ? 35.0 : 15.0); // المذكرة أعرض
      }
      rowIndex++;
    }


    // 4. الحفظ والمشاركة
    try {
      final fileName =
          'VendorSummary_${vendor.name ?? "Unknown"}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(label: 'Excel', extensions: ['xlsx']),
        ],
      );

      // لو المستخدم قفل نافذة اختيار المكان
      if (location == null) return;

      // حفظ البايتات
      var fileBytes = excel.save();

      if (fileBytes != null) {
        final savedFile = File(location.path);
        await savedFile.writeAsBytes(fileBytes);

        // رسالة تأكيد
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الملف في: ${savedFile.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception("Failed to generate Excel file bytes.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr("export_failed", args: [e.toString()])),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
      print("Export Error: $e");
    }

  }

  // **********************************
  //    دالة الزرار الخاص بالتصدير
  // **********************************
  Widget _buildExportButton(BuildContext context, String vendorName) {
    return BlocSelector<VendorTransactionSummaryCubit, VendorTransactionSummaryState, bool>(
      selector: (state) => state is VendorTransactionSummaryLoaded && state.transactions.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
            final state = context.read<VendorTransactionSummaryCubit>().state;
            if (state is VendorTransactionSummaryLoaded) {
              _exportSummaryToExcel(context, state.transactions, vendorName);
            }
          }
              : null, // تعطيل الزر إذا لم تتوفر بيانات
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocProvider(
      create: (_) =>
      VendorTransactionSummaryCubit()..getTransactions(vendor.id!),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("vendor_transactions".tr(args: [vendor.name ?? ""])),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          actions: [
            _buildExportButton(context, vendor.name ?? tr('vendor')), // 👈 زر التصدير
          ],
        ),
        body:
        BlocBuilder<
            VendorTransactionSummaryCubit,
            VendorTransactionSummaryState
        >(
          builder: (context, state) {
            if (state is VendorTransactionSummaryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (state is VendorTransactionSummaryError) {
              return Center(child: Text(state.message));
            }

            if (state is VendorTransactionSummaryLoaded) {
              final data = state.transactions;
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    "no_transactions".tr(),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }

              return Directionality(
                textDirection: Directionality.of(context),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.deepPurple.shade50,
                                ),
                                border: TableBorder.all(
                                  color: Colors.black12,
                                ),
                                columns: [
                                  DataColumn(label: Text('type'.tr())),
                                  DataColumn(label: Text('date'.tr())),
                                  DataColumn(label: Text('num'.tr())),
                                  DataColumn(label: Text('memo'.tr())),
                                  DataColumn(label: Text('debt'.tr())),
                                  DataColumn(label: Text('credit'.tr())),
                                  DataColumn(label: Text('balance'.tr())),
                                ],
                                rows: data.map((t) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          t.transactionType == 'شراء'
                                              ? 'invoice'.tr()
                                              : t.transactionType == 'دفع'
                                              ? 'payment'.tr()
                                              : t.transactionType == 'مرتجع'
                                              ? 'credit'.tr()
                                              : '-',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          t.dateTime != null
                                              ? dateFormat.format(
                                            t.dateTime!,
                                          )
                                              : '--',
                                        ),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            if (t.transactionType ==
                                                "دفع") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PaymentToVendor(
                                                        vendorId:
                                                        t.vendorId!,
                                                        paymentId:
                                                        t.invoiceId!,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VendorBillByIdScreen(
                                                        billId: t.invoiceId!,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            t.invoiceId ?? "-",
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                              TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(t.notes ?? "-")),
                                      DataCell(
                                        Text(
                                          t.transactionType == 'شراء'
                                              ? (t.amount?.toStringAsFixed(
                                            2,
                                          ) ??
                                              '0')
                                              : '',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          t.transactionType == 'شراء'
                                              ? ''
                                              : (t.amount?.toStringAsFixed(
                                            2,
                                          ) ??
                                              '0'),
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
                        ),
                      ],
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