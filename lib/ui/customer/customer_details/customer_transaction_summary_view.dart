import 'dart:io';

import 'package:el_doctor/ui/customer/customer_details/payment_preview.dart';
import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ******** IMPORTات إضافية قد تحتاج إليها للتصدير ********
// import 'package:excel/excel.dart'; // مثال لمكتبة التصدير
// import 'package:path_provider/path_provider.dart'; // مثال لحفظ الملفات
// import 'dart:io'; // مطلوب لمعالجة الملفات
// ********************************************************

import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_state.dart';
import '../../../data/model/customer_model.dart';
import 'invoice_preview.dart';

class CustomerTransactionSummaryView extends StatelessWidget {
  final CustomerModel customer;

  const CustomerTransactionSummaryView({super.key, required this.customer});

  // **********************************************
  //           دالة التصدير إلى Excel
  // **********************************************
// دالة التصدير الفعلي
// دالة التصدير الفعلي
// **********************************************
//           دالة التصدير إلى Excel المُعدلة
// **********************************************
  void _exportToExcel(BuildContext context, List<dynamic> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("no_data_to_export"))),
      );
      return;
    }

    // 1. إنشاء ملف Excel جديد
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[customer.name ?? ""]; // اسم الشيت

    // 2. إعداد العناوين (Headers)
    List<String> headers = [
      tr("type"),
      tr("date"),
      tr("number"),
      tr("memo"),
      tr("debt"),
      tr("credit"),
      tr("balance"),
    ];
    // التحويل إلى TextCellValue
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    final dateFormat = DateFormat('dd/MM/yyyy');

    // 3. إضافة البيانات (Rows)
    for (var t in transactions) {
      String type;
      if (t.transactionType == 'مبيعات') {
        type = tr("invoice");
      } else if (t.transactionType == 'تحصيل') {
        type = tr("payment");
      } else if (t.transactionType == 'مرتجع') {
        type = tr("credit_transaction");
      } else {
        type = "-";
      }

      // تجهيز البيانات كسلاسل نصية (Strings)
      List<String> rowData = [
        type,
        t.dateTime != null ? dateFormat.format(t.dateTime!) : '--',
        t.invoiceId ?? "-",
        t.notes ?? "-",
        t.transactionType == 'مبيعات' ? (t.amount ?? 0).toStringAsFixed(2) : '',
        t.transactionType != 'مبيعات' ? (t.amount ?? 0).toStringAsFixed(2) : '',
        (t.debtAfter ?? 0).toStringAsFixed(2),
      ];

      // التحويل إلى TextCellValue وإضافة الصف
      sheetObject.appendRow(
          rowData.map((data) => TextCellValue(data)).toList());
    }

    try {
      // اسم الملف
      final fileName =
          '${customer.name}_Transactions_${DateFormat('yyyyMMdd').format(
          DateTime.now())}.xlsx';

      // فتح نافذة اختيار مكان الحفظ
      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(label: 'Excel', extensions: ['xlsx']),
        ],
      );

      // لو اليوزر قفل الـ dialog
      if (location == null) return;

      // حفظ البايتات
      var fileBytes = excel.save();

      if (fileBytes != null) {
        final savedFile = File(location.path);
        await savedFile.writeAsBytes(fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الملف في: ${savedFile.path}'),
            duration: Duration(),
          ),
        );
      } else {
        throw Exception("Failed to generate Excel file bytes.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
      print("Export Error: $e");
    }
  }
// ... باقي الكود
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    print(customer.name);
    return BlocProvider(
      create: (_) =>
      CustomerTransactionSummaryCubit()..getTransactions(customer.id!),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("${customer.name}"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,

          // **********************************************
          //           إضافة زر التصدير في AppBar
          // **********************************************
          actions: [
            BlocBuilder<CustomerTransactionSummaryCubit, CustomerTransactionSummaryState>(
              builder: (context, state) {
                // عرض الزر فقط عند تحميل البيانات بنجاح ووجود بيانات
                if (state is CustomerTransactionSummaryLoaded && state.transactions.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.file_download, color: Colors.white),
                    tooltip: tr("export_to_excel"),
                    onPressed: () => _exportToExcel(context, state.transactions),
                  );
                }
                return const SizedBox.shrink(); // لا شيء إذا لم يتم تحميل البيانات
              },
            ),
          ],
          // **********************************************

        ),
        body:
        BlocBuilder<
            CustomerTransactionSummaryCubit,
            CustomerTransactionSummaryState
        >(
          builder: (context, state) {
            if (state is CustomerTransactionSummaryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerTransactionSummaryError) {
              return Center(child: Text(state.message));
            }

            if (state is CustomerTransactionSummaryLoaded) {
              final data = state.transactions;

              if (data.isEmpty) {
                return Center(
                  child: Text(
                    tr("no_transactions"),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }

              return Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.blue.shade50,
                        ),
                        border: TableBorder.all(color: Colors.black12),
                        columns: [
                          DataColumn(label: Text(tr("type"))),
                          DataColumn(label: Text(tr("date"))),
                          DataColumn(label: Text(tr("number"))),
                          DataColumn(label: Text(tr("memo"))),
                          DataColumn(label: Text(tr("debt"))),
                          DataColumn(label: Text(tr("credit"))),
                          DataColumn(label: Text(tr("balance"))),
                        ],
                        rows: data.map((t) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  t.transactionType == 'مبيعات'
                                      ? tr("invoice")
                                      : t.transactionType == 'تحصيل'
                                      ? tr("payment")
                                      : t.transactionType == 'مرتجع'
                                      ? tr("credit_transaction")
                                      : "-",
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          if (t.transactionType == "تحصيل") {
                                            // قد تحتاج إلى تعديل اسم الشاشة (Screen) هنا حسب مشروعك
                                            return ReceivePaymentByIdScreen(
                                              paymentId: t.invoiceId!,
                                              customerId: t.customerId!,
                                            );
                                          }
                                          return CustomerInvoiceByIdScreen(
                                            invoiceId: t.invoiceId!,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(t.invoiceId ?? "-"),
                                ),
                              ),
                              DataCell(Text(t.notes ?? "-")),
                              // عمود الدين (مبيعات)
                              t.transactionType == 'مبيعات'
                                  ? DataCell(
                                Text(
                                  "${t.amount?.toStringAsFixed(2) ?? '0'}",
                                ),
                              )
                                  : DataCell(Text("")),
                              // عمود الدائن (تحصيل/مرتجع)
                              t.transactionType == 'مبيعات'
                                  ? DataCell(Text(""))
                                  : DataCell(
                                Text(
                                  "${t.amount?.toStringAsFixed(2) ?? '0'}",
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
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}