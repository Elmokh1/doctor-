import 'dart:io';

import 'package:excel/excel.dart' as excel_format; // 👈 إضافة الاسم المستعار
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../cubits/customer_cubit/customer_state.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_state.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';
import '../../../data/model/customer_model.dart';
import '../../../data/model/customer_transaction_summary_model.dart';
import '../../../data/model/receive_payment.dart';

class ReceivePaymentByIdScreen extends StatelessWidget {
  final String paymentNum;
  final String customerId;

  const ReceivePaymentByIdScreen({
    super.key,
    required this.paymentNum,
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
  void _exportPaymentToExcel(
    BuildContext context,
    ReceivePaymentModel payment,
  ) async {
    var excel = excel_format.Excel.createExcel();
    excel_format.Sheet sheetObject = excel[tr("payment_receipt")];
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

    addDetailRow(tr('receipt_id'), payment.invoiceNum ?? '-');
    addDetailRow(tr('customer_name'), payment.customerName ?? '-');
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
            : tr('no_notes'),
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
          'Invoice_${payment.invoiceNum ?? "Unknown"}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

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
        SnackBar(content: Text('فشل التصدير: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // **********************************************

  @override
  Widget build(BuildContext context) {
    context.read<ReceivedPaymentInvoiceCubit>().fetchReceivedPaymentById(
      customerId,
      paymentNum,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('payment_receipt_details')),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.red),
            onPressed: () {
              final state = context.read<ReceivedPaymentInvoiceCubit>().state;
              if (state is ReceivedPaymentInvoiceLoaded) {
                _showEditDialog(context, state.transactions.first);
              }
            },
          ),
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
                      _infoCard(
                        children: [
                          _labeledRow(
                            tr('receipt_id'),
                            payment.invoiceNum ?? '-',
                          ),
                          _labeledRow(
                            tr('customer_name'),
                            payment.customerName ?? '-',
                          ),
                          _labeledRow(
                            tr('date'),
                            _formatDate(payment.dateTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle(tr('payment_details')),
                      _infoCard(
                        children: [
                          _labeledRow(
                            tr('balance_before'),
                            _formatCurrency(payment.oldBalance),
                          ),
                          _labeledRow(
                            tr('received_amount'),
                            _formatCurrency(payment.amount),
                          ),
                          const Divider(),
                          _labeledRow(
                            tr('balance_after'),
                            _formatCurrency(payment.newBalance),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle(tr('transaction_notes')),
                      _infoCard(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              payment.transactionDetails?.isNotEmpty == true
                                  ? payment.transactionDetails!
                                  : tr('no_notes'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // تم إزالة زر الرجوع واستبداله بزر التصدير في AppBar
                      // يمكنك إبقاء هذا الزر هنا إذا أردت زرين (تصدير ورجوع)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(tr('back')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
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
    return BlocSelector<
      ReceivedPaymentInvoiceCubit,
      ReceivedPaymentInvoiceState,
      bool
    >(
      selector: (state) =>
          state is ReceivedPaymentInvoiceLoaded &&
          state.transactions.isNotEmpty,
      builder: (context, canExport) {
        return IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          tooltip: tr("export_to_excel"),
          onPressed: canExport
              ? () {
                  final state = context
                      .read<ReceivedPaymentInvoiceCubit>()
                      .state;
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

  void _showEditDialog(BuildContext context, ReceivePaymentModel payment) {
    final TextEditingController amountController = TextEditingController(
      text: payment.amount?.toString() ?? '',
    );

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
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('received_amount'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
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
                    final double newAmount =
                        double.tryParse(amountController.text) ??
                        payment.amount!;
                    final DateTime newDate = selectedDate ?? payment.dateTime!;

                    // فرق المبلغ بين الجديد والقديم
                    final double difference = newAmount - payment.amount!;

                    // جلب رصيد العميل الحالي (Opening Balance) من CustomerCubit
                    final customerState = context.read<CustomerCubit>().state;
                    double openingBalance = 0;
                    if (customerState is CustomerLoaded) {
                      final customer = customerState.customers.firstWhere(
                        (c) => c.id == payment.customerId,
                        orElse: () =>
                            CustomerModel(name: '', openingBalance: 0),
                      );
                      openingBalance = customer.openingBalance ?? 0;
                    }

                    // تحديث رصيد العميل
                    final double updatedBalance = openingBalance - difference;
                    await context.read<CustomerCubit>().updateCustomerBalance(
                      customerId: payment.customerId!,
                      newBalance: updatedBalance,
                    );
                    await context.read<CashBoxCubit>().updateCash(difference, isIncome: true);

                    // إنشاء الموديل الجديد مع القيمة الجديدة
                    final updatedPayment = ReceivePaymentModel(
                      id: payment.id,
                      invoiceNum: payment.invoiceNum,
                      customerName: payment.customerName,
                      customerId: payment.customerId,
                      amount: newAmount,
                      cashBoxBefore: payment.cashBoxBefore,
                      cashBoxAfter: payment.cashBoxAfter,
                      oldBalance: payment.oldBalance,
                      newBalance: payment.oldBalance!-newAmount,
                      transactionDetails: payment.transactionDetails,
                      dateTime: newDate,
                    );

                    // تحديث الفاتورة نفسها في Firestore
                    await context
                        .read<ReceivedPaymentInvoiceCubit>()
                        .updateReceivedPaymentInvoice(
                          customerId: payment.customerId!,
                          payment: updatedPayment,
                        );

                    // تحديث حركة العميل فقط لو موجودة
                    final transactionState = context
                        .read<CustomerTransactionSummaryCubit>()
                        .state;
                    CustomerTransactionSummaryModel? originalTransaction;

                    if (transactionState is CustomerTransactionSummaryLoaded) {
                      final matchingTransactions = transactionState.transactions
                          .where((t) => t.invoiceId == payment.id)
                          .toList();

                      if (matchingTransactions.isNotEmpty) {
                        originalTransaction = matchingTransactions.first;
                      }
                    }

                    if (originalTransaction != null) {
                      final updatedTransaction =
                          CustomerTransactionSummaryModel(
                            id: originalTransaction.id,
                            customerId: payment.customerId,
                            customerName: payment.customerName,
                            transactionType: originalTransaction.transactionType,
                            invoiceId: payment.id,
                            invoiceNum: payment.invoiceNum,
                            debtBefore: originalTransaction.debtBefore,
                            debtAfter: updatedBalance,
                            amount: newAmount,
                            dateTime: newDate,
                            notes: payment.transactionDetails,
                          );

                      await context
                          .read<CustomerTransactionSummaryCubit>()
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
