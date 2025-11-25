import 'dart:io';

import 'package:excel/excel.dart'
    as excel_format; // 👈 تم إضافة الاسم المستعار هنا
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import '../../../../../cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import '../../../../../cubits/customer_invoice_cubit/customer_invoice_state.dart';
import '../../../../../data/model/all_invoice_for_customer.dart';
import '../../../../../data/model/product_model.dart';

class CustomerInvoiceByIdScreen extends StatelessWidget {
  // افترضنا أن الخاصية الصحيحة هي 'id' بدلاً من 'invoiceId'
  final String invoiceId;

  const CustomerInvoiceByIdScreen({super.key, required this.invoiceId});

  // **********************************************
  //           دالة التصدير إلى Excel
  // **********************************************
  void _exportInvoiceToExcel(
      BuildContext context,
      CustomerInvoiceModel invoice,
      ) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("invoice")];

    final int maxCols = 6;
    int rowIndex = 0;

    // **********************************
    // 1. العنوان الرئيسي
    // **********************************
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex),
    );
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = excel_format.TextCellValue(tr("${invoice.invoiceType}"))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: excel_format.HorizontalAlign.Center,
      );
    rowIndex += 2;

    // **********************************
    // 2. تفاصيل الفاتورة
    // **********************************
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
    );
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
      "${tr('customer_name')}: ${invoice.customerName ?? tr('unknown')}",
    );

    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
      excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex),
    );
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
      "${tr('date')}: ${_formatDate(invoice.dateTime)}",
    );

    rowIndex++;

    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      excel_format.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
    );
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
      "${tr('invoice_type')}: ${invoice.invoiceType ?? tr('undefined')}",
    );

    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
      excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex),
    );
    sheetObject
        .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = excel_format.TextCellValue(
      "${tr('notes')}: ${invoice.notes ?? tr('no_notes')}",
    );

    rowIndex += 2;

    // **********************************
    // 3. جدول المنتجات
    // **********************************

    excel_format.CellStyle headerStyle = excel_format.CellStyle(
      bold: true,
      backgroundColorHex: excel_format.ExcelColor.fromHexString("FFD3E8E5"),
      horizontalAlign: excel_format.HorizontalAlign.Center,
    );

    List<String> productHeaders = [
      tr('product'),
      tr('qty'),
      tr('price'),
      tr('total'),
    ];

    sheetObject.appendRow(productHeaders.map((h) => excel_format.TextCellValue(h)).toList());

    for (int col = 0; col < productHeaders.length; col++) {
      sheetObject
          .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
          .cellStyle = headerStyle;
    }

    rowIndex++;

    excel_format.CellStyle dataStyle = excel_format.CellStyle(
      horizontalAlign: excel_format.HorizontalAlign.Right,
      numberFormat: excel_format.NumFormat.custom(formatCode: '#,##0.00'),
    );

    for (var p in invoice.items) {
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
            .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
            .cellStyle = dataStyle;
        sheetObject.setColumnWidth(col, col == 0 ? 30.0 : 15.0);
      }
      rowIndex++;
    }

    rowIndex++;

    // **********************************
    // 4. الملخص المالي
    // **********************************

    void addSummaryRow(String label, double? value) {
      sheetObject.merge(
        excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
      );
      sheetObject
          .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = excel_format.TextCellValue(label);

      sheetObject.merge(
        excel_format.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        excel_format.CellIndex.indexByColumnRow(columnIndex: maxCols - 1, rowIndex: rowIndex),
      );
      sheetObject
          .cell(excel_format.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = excel_format.TextCellValue(
        "${value?.toStringAsFixed(2) ?? "0.00"} EGP",
      );

      rowIndex++;
    }

    addSummaryRow(tr('total_before_discount'), invoice.totalBeforeDiscount);
    addSummaryRow(tr('discount'), invoice.discount);
    addSummaryRow(tr('total_payable'), invoice.totalAfterDiscount);
    addSummaryRow(tr('previous_debt'), invoice.debtBefore);
    addSummaryRow(tr('current_debt'), invoice.debtAfter);

    // **********************************
    // 5. الحفظ — النسخة الحقيقية (بعد كتابة البيانات)
    // **********************************

    try {
      final fileName =
          'Invoice_${invoice.id ?? "Unknown"}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(label: 'Excel', extensions: ['xlsx']),
        ],
      );

      if (location == null) return;

      var fileBytes = excel.save();

      if (fileBytes != null) {
        final savedFile = File(location.path);
        await savedFile.writeAsBytes(fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الملف في: ${savedFile.path}'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return tr('n_a');
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerInvoicesCubit>().fetchInvoicesById(invoiceId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('invoice_details'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [_buildExportButton(context)],
      ),
      body: BlocBuilder<CustomerInvoicesCubit, CustomerInvoiceState>(
        builder: (context, state) {
          if (state is CustomerInvoiceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (state is CustomerInvoiceError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is CustomerInvoiceLoaded) {
            if (state.invoices.isEmpty) {
              return Center(
                child: Text(
                  tr('no_data_for_invoice'),
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }

            final CustomerInvoiceModel invoice = state.invoices.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(tr('invoice_info')),
                  _buildInvoiceHeaderCard(invoice),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('products')),
                  _buildProductTable(invoice.items),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('notes')),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        invoice.notes ?? tr('no_notes'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle(tr('financial_summary')),
                  _buildFinancialSummaryCard(invoice),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return BlocSelector<CustomerInvoicesCubit, CustomerInvoiceState, bool>(
      selector: (state) =>
          state is CustomerInvoiceLoaded && state.invoices.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
                  final state = context.read<CustomerInvoicesCubit>().state;
                  if (state is CustomerInvoiceLoaded) {
                    _exportInvoiceToExcel(context, state.invoices.first);
                  }
                }
              : null,
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
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _buildInvoiceHeaderCard(CustomerInvoiceModel invoice) {
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
              tr('invoice_type'),
              invoice.invoiceType ?? tr('undefined'),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.person,
              tr('customer_name'),
              invoice.customerName ?? tr('unknown'),
            ),
            const Divider(),
            _buildInfoRowWithIcon(
              Icons.calendar_today,
              tr('date'),
              _formatDate(invoice.dateTime),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.teal.shade50,
          ),
          columns: [
            DataColumn(
              label: Text(
                tr('product'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                tr('qty'),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                tr('price'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    product.productName ?? tr('n_a'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Container(
                    alignment: Alignment.center,
                    child: Text("${product.qun ?? 0}"),
                  ),
                ),
                DataCell(
                  Text("${product.salePrice?.toStringAsFixed(2) ?? 0.00} EGP"),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(CustomerInvoiceModel invoice) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              tr('total_before_discount'),
              invoice.totalBeforeDiscount,
              Colors.black87,
            ),
            _buildInfoRow(tr('discount'), invoice.discount, Colors.red),
            const Divider(height: 15),
            _buildInfoRow(
              tr('total_payable'),
              invoice.totalAfterDiscount,
              Colors.teal.shade700,
              isTotal: true,
            ),
            const Divider(height: 20, thickness: 1.5),
            _buildInfoRow(
              tr('previous_debt'),
              invoice.debtBefore,
              Colors.black54,
            ),
            _buildInfoRow(
              tr('current_debt'),
              invoice.debtAfter,
              Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    double? value,
    Color valueColor, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${value?.toStringAsFixed(2) ?? 0.00} EGP",
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
