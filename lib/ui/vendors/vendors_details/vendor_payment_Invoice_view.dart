import 'package:el_doctor/ui/vendors/vendors_details/bills_preview.dart';
import 'package:el_doctor/ui/vendors/vendors_details/payment_to_vendor_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import '../../../cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_state.dart';
import '../../../data/model/vendor_model.dart';

class VendorTransactionSummaryView extends StatelessWidget {
  final VendorModel vendor;

  const VendorTransactionSummaryView({super.key, required this.vendor});

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
