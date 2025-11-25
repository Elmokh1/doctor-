import 'dart:io';

import 'package:excel/excel.dart' as excel_format; // 👈 إضافة
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// تم إزالة: import 'package:printing/printing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart'; // 👈 إضافة
import 'package:share_plus/share_plus.dart'; // 👈 إضافة

import '../../../cubits/vendor_bills_cubit/vendor_bills_cubit.dart';
import '../../../cubits/vendor_bills_cubit/vendor_bills_state.dart';
import '../../../data/model/all_invoice_for_customer.dart';
import '../../../data/model/product_model.dart';
// تم إزالة: import '../../customer/customer_details/print.dart';

class VendorBillByIdScreen extends StatelessWidget {
  final String billId;

  const VendorBillByIdScreen({super.key, required this.billId});

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "N/A";
    if (dateValue is DateTime) return DateFormat('yyyy-MM-dd').format(dateValue);
    if (dateValue is String) {
      try {
        return dateValue.split(" ")[0];
      } catch (_) {
        return dateValue;
      }
    }
    return dateValue.toString();
  }

  // **********************************************
  //           دالة التصدير إلى Excel
  // **********************************************
  void _exportBillToExcel(BuildContext context, CustomerInvoiceModel bill) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("vendor_bill")];
    final int maxCols = 6;
    int rowIndex = 0;

    // **********************************
    // 1. العنوان الرئيسي
    // **********************************
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(
            columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr('${bill.invoiceType}'))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: excel_format.HorizontalAlign.Center,
      );
    rowIndex++;
    rowIndex++;

    // **********************************
    // 2. تفاصيل الفاتورة
    // **********************************
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(
            columnIndex: 2, rowIndex: rowIndex));
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
        "${tr('vendor_name')}: ${bill.customerName ?? tr('unknown')}");

    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 3, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(
            columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(
        columnIndex: 3, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
        "${tr('date')}: ${_formatDate(bill.dateTime)}");

    rowIndex++;
    rowIndex++; // فراغ قبل الجدول

    // **********************************
    // 3. جدول المنتجات
    // **********************************

    excel_format.CellStyle headerStyle = excel_format.CellStyle(
      bold: true,
      backgroundColorHex: excel_format.ExcelColor.fromHexString("FFD3E8E5"),
      horizontalAlign: excel_format.HorizontalAlign.Center,
      topBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      bottomBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      leftBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      rightBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
    );

    List<String> productHeaders = [
      tr('product'), tr('qty'), tr('price'), tr('total'),
    ];
    sheetObject.appendRow(
        productHeaders.map((h) => excel_format.TextCellValue(h)).toList());

    for (int col = 0; col < productHeaders.length; col++) {
      sheetObject
          .cell(excel_format.CellIndex.indexByColumnRow(
          columnIndex: col, rowIndex: rowIndex))
          .cellStyle = headerStyle;
    }

    rowIndex++;

    excel_format.CellStyle dataStyle = excel_format.CellStyle(
      horizontalAlign: excel_format.HorizontalAlign.Right,
      numberFormat: excel_format.NumFormat.custom(formatCode: '#,##0.00'),
      topBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      bottomBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      leftBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
      rightBorder: excel_format.Border(
          borderStyle: excel_format.BorderStyle.Thin),
    );

    for (var p in bill.items) {
      double total = (p.qun ?? 0) * (p.salePrice ?? 0.0);

      List<excel_format.CellValue> rowData = [
        excel_format.TextCellValue(p.productName ?? tr('n_a')),
        excel_format.TextCellValue((p.qun ?? 0).toString()),
        excel_format.TextCellValue((p.salePrice ?? 0.00).toStringAsFixed(2)),
        excel_format.TextCellValue(total.toStringAsFixed(2)),
      ];

      sheetObject.appendRow(rowData);

      for (int col = 0; col < rowData.length; col++) {
        sheetObject
            .cell(excel_format.CellIndex.indexByColumnRow(
            columnIndex: col, rowIndex: rowIndex))
            .cellStyle = dataStyle;
        sheetObject.setColumnWidth(col, col == 0 ? 30.0 : 15.0);
      }
      rowIndex++;
    }
    rowIndex++;

    // **********************************
    // 4. الملخص المالي
    // **********************************
    excel_format.CellStyle summaryLabelStyle = excel_format.CellStyle(
        bold: true);
    excel_format.CellStyle summaryValueStyle = excel_format.CellStyle(
      bold: true,
      numberFormat: excel_format.NumFormat.custom(formatCode: '#,##0.00'),
      backgroundColorHex: excel_format.ExcelColor.fromHexString("FFC0E4FF"),
    );

    void addSummaryRow(String label, double? value, {bool isTotal = false}) {
      sheetObject.merge(excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0, rowIndex: rowIndex),
          excel_format.CellIndex.indexByColumnRow(
              columnIndex: 3, rowIndex: rowIndex));
      sheetObject.cell(excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0, rowIndex: rowIndex))
        ..value = excel_format.TextCellValue(label)
        ..cellStyle = summaryLabelStyle;

      sheetObject.merge(excel_format.CellIndex.indexByColumnRow(
          columnIndex: 4, rowIndex: rowIndex),
          excel_format.CellIndex.indexByColumnRow(
              columnIndex: maxCols - 1, rowIndex: rowIndex));
      sheetObject.cell(excel_format.CellIndex.indexByColumnRow(
          columnIndex: 4, rowIndex: rowIndex))
        ..value = excel_format.TextCellValue(
            "${value?.toStringAsFixed(2) ?? 0.00} EGP")
        ..cellStyle = (isTotal ? summaryValueStyle : excel_format.CellStyle(
            bold: true, horizontalAlign: excel_format.HorizontalAlign.Right));

      rowIndex++;
    }

    addSummaryRow(tr('total_before_discount'), bill.totalBeforeDiscount);
    addSummaryRow(tr('discount'), bill.discount);
    addSummaryRow(tr('total_payable'), bill.totalAfterDiscount, isTotal: true);
    rowIndex++;
    addSummaryRow(tr('previous_debt'), bill.debtBefore);
    addSummaryRow(tr('current_debt'), bill.debtAfter);


    // **********************************
    // 5. الحفظ والمشاركة
    // **********************************
    try {
      final fileName =
          'VendorBill_${bill.id ?? "Unknown"}_${DateFormat('yyyyMMdd').format(
          DateTime.now())}.xlsx';

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

        // مشاركة الملف بعد الحفظ
        await Share.shareXFiles(
          [XFile(savedFile.path)],
          text: tr("share_vendor_bill_message", args: [bill.id ?? '-']),
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


    @override
  Widget build(BuildContext context) {
    context.read<VendorBillCubit>().fetchBillsById(billId);

    return Scaffold(
      appBar: AppBar(
        title: Text("vendor_bill_details".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          _buildExportButton(context), // 👈 زر التصدير
        ],
      ),
      body: BlocBuilder<VendorBillCubit, VendorBillState>(
        builder: (context, state) {
          if (state is VendorBillLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (state is VendorBillError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is VendorBillLoaded) {
            if (state.bills.isEmpty) {
              return Center(
                child: Text(
                  "no_data_found".tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }

            final CustomerInvoiceModel bill = state.bills.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle("bill_info".tr()),
                  _buildBillHeaderCard(bill),
                  const SizedBox(height: 20),
                  _buildSectionTitle("products".tr()),
                  _buildProductTable(bill.items),
                  const SizedBox(height: 20),
                  _buildSectionTitle("financial_summary".tr()),
                  _buildFinancialSummaryCard(bill),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // **********************************
  //    دالة الزرار الخاص بالتصدير
  // **********************************
  Widget _buildExportButton(BuildContext context) {
    return BlocSelector<VendorBillCubit, VendorBillState, bool>(
      selector: (state) => state is VendorBillLoaded && state.bills.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
            final state = context.read<VendorBillCubit>().state;
            if (state is VendorBillLoaded) {
              _exportBillToExcel(context, state.bills.first);
            }
          }
              : null, // تعطيل الزر إذا لم تتوفر بيانات
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade800,
        ),
      ),
    );
  }

  Widget _buildBillHeaderCard(CustomerInvoiceModel bill) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRowWithIcon(
              Icons.receipt_long,
              "bill_type".tr(),
              bill.invoiceType ?? "undefined".tr(),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.store,
              "vendor_name".tr(),
              bill.customerName ?? "unknown".tr(),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.calendar_today,
              "date".tr(),
              _formatDate(bill.dateTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(List<ProductModel> products) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.deepPurple.shade50,
          ),
          columns: [
            DataColumn(label: Text("product".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("qty".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("price".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.productName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Center(child: Text("${product.qun ?? 0}"))),
                DataCell(Text("${product.salePrice?.toStringAsFixed(2) ?? 0.00} EGP")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(CustomerInvoiceModel bill) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow("total_before_discount".tr(), bill.totalBeforeDiscount, Colors.black87),
            _buildInfoRow("discount".tr(), bill.discount, Colors.red),
            const Divider(height: 15),
            _buildInfoRow("total_payable".tr(), bill.totalAfterDiscount, Colors.deepPurple.shade700, isTotal: true),
            const Divider(height: 20, thickness: 1.5),
            _buildInfoRow("previous_debt".tr(), bill.debtBefore, Colors.black54),
            _buildInfoRow("current_debt".tr(), bill.debtAfter, Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, double? value, Color valueColor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text("${value?.toStringAsFixed(2) ?? 0.00} EGP", style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}