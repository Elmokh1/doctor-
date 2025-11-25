import 'dart:io';

import 'package:excel/excel.dart' as excel_format; // 👈 إضافة الاسم المستعار
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';
import '../../../data/model/receive_payment.dart';

class ReceivePaymentByIdScreen extends StatelessWidget {
  final String paymentId;
  final String customerId;

  const ReceivePaymentByIdScreen({
    super.key,
    required this.paymentId,
    required this.customerId,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return tr('n_a');
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  String _formatCurrency(double? value) {
    if (value == null) return '0.00';
    return '${value.toStringAsFixed(2)} EGP';
  }

  // **********************************************
  //           دالة التصدير إلى Excel (كما تم تعريفها أعلاه)
  // **********************************************
  void _exportPaymentToExcel(BuildContext context, ReceivePaymentModel payment) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("payment_receipt")];
    final int maxCols = 4;
    int rowIndex = 0;

    // **********************************
    // 1. العنوان الرئيسي
    // **********************************
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr("تحصيل"))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: excel_format.HorizontalAlign.Center,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFD3E8E5"),
      );
    rowIndex++;
    rowIndex++;

    // **********************************
    // 2. تفاصيل الإيصال الأساسية
    // **********************************

    void addDetailRow(String label, String value, {bool boldValue = false}) {
      sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
      sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = excel_format.TextCellValue(label)
        ..cellStyle = excel_format.CellStyle(bold: true);

      sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
      sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = excel_format.TextCellValue(value)
        ..cellStyle = excel_format.CellStyle(bold: boldValue, horizontalAlign: excel_format.HorizontalAlign.Right);
      rowIndex++;
    }

    addDetailRow(tr('receipt_id'), payment.id ?? '-');
    addDetailRow(tr('customer_name'), payment.customerName ?? '-');
    addDetailRow(tr('date'), _formatDate(payment.dateTime));

    rowIndex++;

    // **********************************
    // 3. الملخص المالي
    // **********************************
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr("payment_details"))
      ..cellStyle = excel_format.CellStyle(bold: true, backgroundColorHex: excel_format.ExcelColor.fromHexString("FFE0E0E0"));
    rowIndex++;

    addDetailRow(tr('balance_before'), _formatCurrency(payment.oldBalance));
    addDetailRow(tr('received_amount'), _formatCurrency(payment.amount), boldValue: true);

    // تنسيق الرصيد بعد الدفع
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr('balance_after'))
      ..cellStyle = excel_format.CellStyle(bold: true, backgroundColorHex: excel_format.ExcelColor.fromHexString("FFC0E4FF"));

    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(_formatCurrency(payment.newBalance))
      ..cellStyle = excel_format.CellStyle(bold: true, horizontalAlign: excel_format.HorizontalAlign.Right, backgroundColorHex: excel_format.ExcelColor.fromHexString("FFC0E4FF"));
    rowIndex++;
    rowIndex++;

    // **********************************
    // 4. الملاحظات
    // **********************************
    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr("transaction_notes"))
      ..cellStyle = excel_format.CellStyle(bold: true, backgroundColorHex: excel_format.ExcelColor.fromHexString("FFE0E0E0"));
    rowIndex++;

    sheetObject.merge(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex));
    sheetObject.cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(
          payment.transactionDetails?.isNotEmpty == true ? payment.transactionDetails! : tr('no_notes'))
      ..cellStyle = excel_format.CellStyle(horizontalAlign: excel_format.HorizontalAlign.Right);
    rowIndex++;

    sheetObject.setColumnWidth(0, 18.0);
    sheetObject.setColumnWidth(2, 25.0);


    // **********************************
    // 5. الحفظ والمشاركة
    // **********************************
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'Receipt_${payment.id ?? 'Unknown'}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final path = '${directory.path}/$fileName';

      var fileBytes = excel.save();

      if (fileBytes != null) {
        final file = File(path);
        await file.writeAsBytes(fileBytes);

        await Share.shareXFiles(
          [XFile(path)],
          text: tr("share_receipt_message", args: [payment.id ?? '-']),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr("share_started")),
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

  // **********************************************

  @override
  Widget build(BuildContext context) {
    context.read<ReceivedPaymentInvoiceCubit>().fetchReceivedPaymentById(
      customerId,
      paymentId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('payment_receipt_details')),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          _buildExportButton(context), // 👈 زر التصدير في شريط التطبيق
        ],
      ),
      body:
      BlocBuilder<ReceivedPaymentInvoiceCubit, ReceivedPaymentInvoiceState>(
        builder: (context, state) {
          if (state is ReceivedPaymentInvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceivedPaymentInvoiceError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is ReceivedPaymentInvoiceLoaded) {
            if (state.transactions.isEmpty) {
              return Center(child: Text(tr('no_data_for_receipt')));
            }

            final ReceivePaymentModel payment = state.transactions.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(tr('receipt_info')),
                  _infoCard(children: [
                    _labeledRow(tr('receipt_id'), payment.id ?? '-'),
                    _labeledRow(tr('customer_name'), payment.customerName ?? '-'),
                    _labeledRow(tr('date'), _formatDate(payment.dateTime)),
                  ]),
                  const SizedBox(height: 16),

                  _sectionTitle(tr('payment_details')),
                  _infoCard(children: [
                    _labeledRow(tr('balance_before'), _formatCurrency(payment.oldBalance)),
                    _labeledRow(tr('received_amount'), _formatCurrency(payment.amount)),
                    const Divider(),
                    _labeledRow(tr('balance_after'), _formatCurrency(payment.newBalance)),
                  ]),
                  const SizedBox(height: 16),

                  _sectionTitle(tr('transaction_notes')),
                  _infoCard(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        payment.transactionDetails?.isNotEmpty == true
                            ? payment.transactionDetails!
                            : tr('no_notes'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // تم إزالة زر الرجوع واستبداله بزر التصدير في AppBar
                  // يمكنك إبقاء هذا الزر هنا إذا أردت زرين (تصدير ورجوع)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(tr('back')),
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ---------------- Helper Widgets and Export Button ----------------

  Widget _buildExportButton(BuildContext context) {
    return BlocSelector<ReceivedPaymentInvoiceCubit, ReceivedPaymentInvoiceState, bool>(
      selector: (state) => state is ReceivedPaymentInvoiceLoaded && state.transactions.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
            final state = context.read<ReceivedPaymentInvoiceCubit>().state;
            if (state is ReceivedPaymentInvoiceLoaded) {
              _exportPaymentToExcel(context, state.transactions.first);
            }
          }
              : null, // تعطيل الزر إذا لم تتوفر بيانات
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _labeledRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}