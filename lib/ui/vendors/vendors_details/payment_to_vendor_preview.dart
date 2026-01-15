import 'dart:io';

import 'package:el_doctor/cubits/vendors_cubit/vendor_cubit.dart';
import 'package:excel/excel.dart' as excel_format; // 👈 إضافة
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart'; // 👈 إضافة
import 'package:share_plus/share_plus.dart'; // 👈 إضافة

import '../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_state.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_state.dart';
import '../../../cubits/vendors_cubit/vendor_state.dart';
import '../../../data/model/pay_vendor.dart';
import '../../../data/model/vendor_model.dart';
import '../../../data/model/vendor_transaction_summary_model.dart';

class PaymentToVendor extends StatelessWidget {
  final String paymentId;
  final String vendorId;

  const PaymentToVendor({
    super.key,
    required this.paymentId,
    required this.vendorId,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  String _formatCurrency(double? value) {
    if (value == null) return '0.00';
    return '${value.toStringAsFixed(2)} EGP';
  }

  // **********************************************
  //           دالة التصدير إلى Excel
  // **********************************************
  void _exportPaymentToExcel(
    BuildContext context,
    PayVendorModel payment,
  ) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("vendor_payment_receipt")];
    final int maxCols = 4;
    int rowIndex = 0;

    // **********************************
    // 1. العنوان الرئيسي
    // **********************************
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: maxCols - 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(tr('دفع'))
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
      sheetObject.merge(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: rowIndex,
        ),
      );
      sheetObject.cell(
          excel_format.CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: rowIndex,
          ),
        )
        ..value = excel_format.TextCellValue(label)
        ..cellStyle = excel_format.CellStyle(bold: true);

      sheetObject.merge(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: rowIndex,
        ),
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: maxCols - 1,
          rowIndex: rowIndex,
        ),
      );
      sheetObject.cell(
          excel_format.CellIndex.indexByColumnRow(
            columnIndex: 2,
            rowIndex: rowIndex,
          ),
        )
        ..value = excel_format.TextCellValue(value)
        ..cellStyle = excel_format.CellStyle(
          bold: boldValue,
          horizontalAlign: excel_format.HorizontalAlign.Right,
        );
      rowIndex++;
    }

    addDetailRow(tr('receipt_id'), payment.id ?? '-');
    addDetailRow(tr('vendor_name'), payment.customerName ?? '-');
    addDetailRow(tr('date'), _formatDate(payment.dateTime));

    rowIndex++;

    // **********************************
    // 3. الملخص المالي
    // **********************************
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: maxCols - 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(tr("payment_details"))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFE0E0E0"),
      );
    rowIndex++;

    addDetailRow(tr('balance_before'), _formatCurrency(payment.oldBalance));
    addDetailRow(
      tr('received_amount'),
      _formatCurrency(payment.amount),
      boldValue: true,
    );

    // تنسيق الرصيد بعد الدفع
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(tr('balance_after'))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFC0E4FF"),
      );

    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 2,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: maxCols - 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(_formatCurrency(payment.newBalance))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        horizontalAlign: excel_format.HorizontalAlign.Right,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFC0E4FF"),
      );
    rowIndex++;
    rowIndex++;

    // **********************************
    // 4. الملاحظات
    // **********************************
    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: maxCols - 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(tr("transaction_notes"))
      ..cellStyle = excel_format.CellStyle(
        bold: true,
        backgroundColorHex: excel_format.ExcelColor.fromHexString("FFE0E0E0"),
      );
    rowIndex++;

    sheetObject.merge(
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ),
      excel_format.CellIndex.indexByColumnRow(
        columnIndex: maxCols - 1,
        rowIndex: rowIndex,
      ),
    );
    sheetObject.cell(
        excel_format.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ),
      )
      ..value = excel_format.TextCellValue(
        payment.transactionDetails?.isNotEmpty == true
            ? payment.transactionDetails!
            : tr('no_notes_available'),
      )
      ..cellStyle = excel_format.CellStyle(
        horizontalAlign: excel_format.HorizontalAlign.Right,
      );
    rowIndex++;

    sheetObject.setColumnWidth(0, 18.0);
    sheetObject.setColumnWidth(2, 25.0);

    // **********************************
    // 5. الحفظ والمشاركة
    // **********************************
    try {
      final fileName =
          'VendorPayment_${payment.id ?? "Unknown"}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

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

  @override
  Widget build(BuildContext context) {
    context.read<PayVendorInvoiceCubit>().fetchPaymentById(vendorId, paymentId);

    return Scaffold(
      appBar: AppBar(
        title: Text('payment_receipt_details'.tr()),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<PayVendorInvoiceCubit>().state;
              if (state is PayVendorInvoiceLoaded &&
                  state.transactions.isNotEmpty) {
                _showEditDialog(context, state.transactions.first);
              }
            },
            icon: Icon(Icons.edit, color: Colors.red),
          ),
          _buildExportButton(context), // 👈 زر التصدير
        ],
      ),
      body: BlocBuilder<PayVendorInvoiceCubit, PayVendorInvoiceState>(
        builder: (context, state) {
          if (state is PayVendorInvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PayVendorInvoiceError) {
            return Center(child: Text(state.message));
          }

          if (state is PayVendorInvoiceLoaded) {
            if (state.transactions.isEmpty) {
              return Center(child: Text('no_data_found_for_receipt'.tr()));
            }

            final PayVendorModel payment = state.transactions.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('receipt_information'.tr()),
                  _infoCard(
                    children: [
                      _labeledRow('receipt_id'.tr(), payment.id ?? '-'),
                      _labeledRow(
                        'vendor_name'.tr(),
                        payment.customerName ?? '-',
                      ),
                      _labeledRow('date'.tr(), _formatDate(payment.dateTime)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('payment_details'.tr()),
                  _infoCard(
                    children: [
                      _labeledRow(
                        'balance_before'.tr(),
                        _formatCurrency(payment.oldBalance),
                      ),
                      _labeledRow(
                        'received_amount'.tr(),
                        _formatCurrency(payment.amount),
                      ),
                      const Divider(),
                      _labeledRow(
                        'balance_after'.tr(),
                        _formatCurrency(payment.newBalance),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('transaction_notes'.tr()),
                  _infoCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          payment.transactionDetails?.isNotEmpty == true
                              ? payment.transactionDetails!
                              : 'no_notes_available'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
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

  // **********************************
  //    دالة الزرار الخاص بالتصدير
  // **********************************
  Widget _buildExportButton(BuildContext context) {
    return BlocSelector<PayVendorInvoiceCubit, PayVendorInvoiceState, bool>(
      selector: (state) =>
          state is PayVendorInvoiceLoaded && state.transactions.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
                  final state = context.read<PayVendorInvoiceCubit>().state;
                  if (state is PayVendorInvoiceLoaded) {
                    _exportPaymentToExcel(context, state.transactions.first);
                  }
                }
              : null,
        );
      },
    );
  }

  // ---------------- Helper Widgets ----------------

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

  void _showEditDialog(BuildContext context, PayVendorModel payment) {
    final TextEditingController amountController =
    TextEditingController(text: payment.amount?.toString() ?? '');
    DateTime? selectedDate = payment.dateTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tr('edit_payment')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // تعديل المبلغ
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('received_amount'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // اختيار التاريخ
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: tr('date'),
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDate == null
                              ? tr('select_date')
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // قراءة القيم الجديدة
                    final newAmount =
                    double.tryParse(amountController.text.trim());
                    if (newAmount == null || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('enter_valid_values'))),
                      );
                      return;
                    }

                    // فرق المبلغ بين الجديد والقديم
                    final difference = newAmount - payment.amount!;

                    // جلب رصيد المورد الحالي (Opening Balance) من VendorCubit
                    final vendorState = context.read<VendorCubit>().state;
                    double openingBalance = 0;
                    if (vendorState is VendorLoaded) {
                      final vendor = vendorState.vendors.firstWhere(
                            (v) => v.id == payment.customerId,
                        orElse: () => VendorModel(name: '', openingBalance: 0),
                      );
                      openingBalance = vendor.openingBalance ?? 0;
                    }

                    // تحديث رصيد المورد
                    final updatedBalance = openingBalance - difference;
                    await context.read<VendorCubit>().updateVendorBalance(
                      vendorId: payment.customerId!,
                      newBalance: updatedBalance,
                    );

                    // تحديث الكاش بوكس زي العميل
                    await context.read<CashBoxCubit>().updateCash(
                      difference,
                      isIncome: false, // الدفع للمورد يقلل الكاش
                    );

                    // تحديث الدفع نفسه
                    final updatedPayment = PayVendorModel(
                      id: payment.id,
                      customerName: payment.customerName,
                      customerId: payment.customerId,
                      amount: newAmount,
                      cashBoxBefore: payment.cashBoxBefore,
                      cashBoxAfter: payment.cashBoxAfter,
                      oldBalance: payment.oldBalance,
                      newBalance: payment.oldBalance! - newAmount,
                      transactionDetails: payment.transactionDetails,
                      dateTime: selectedDate,
                    );

                    await context.read<PayVendorInvoiceCubit>().updatePayVendorInvoice(
                      vendorId: payment.customerId!,
                      payment: updatedPayment,
                    );

                    // تحديث حركة المورد (VendorTransactionSummary) لو موجودة
                    final transactionState =
                        context.read<VendorTransactionSummaryCubit>().state;
                    if (transactionState is VendorTransactionSummaryLoaded) {
                      final matching = transactionState.transactions
                          .firstWhere(
                            (t) => t.invoiceId == payment.id,
                        orElse: () => VendorTransactionSummaryModel(
                          id: '',
                          vendorId: payment.customerId,
                          vendorName: payment.customerName,
                          invoiceId: paymentId,
                          invoiceNum: payment.id,
                          amount: newAmount,
                          debtBefore: payment.oldBalance ?? 0,
                          debtAfter: updatedBalance,
                          transactionType: 'دفع',
                          dateTime: selectedDate,
                          notes: payment.transactionDetails,
                        ),
                      );

                      final updatedTransaction = VendorTransactionSummaryModel(
                        id: matching.id,
                        vendorId: payment.customerId,
                        vendorName: payment.customerName,
                        invoiceId: paymentId,
                        invoiceNum: payment.id,
                        amount: newAmount,
                        debtBefore: matching.debtBefore,
                        debtAfter: updatedBalance,
                        transactionType: 'دفع',
                        dateTime: selectedDate,
                        notes: payment.transactionDetails,
                      );

                      await context
                          .read<VendorTransactionSummaryCubit>()
                          .updateTransaction(updatedTransaction);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
