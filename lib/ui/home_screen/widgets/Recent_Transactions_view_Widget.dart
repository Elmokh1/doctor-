import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/money_transaction_cubit/money_transaction_cubit.dart';
import '../../../data/model/money_transaction_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final double w;
  final double h;

  const RecentTransactionsWidget(this.h, this.w, {super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MoneyTransactionCubit>();

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        padding: EdgeInsets.all(w * 0.015),
        child: StreamBuilder<List<MoneyTransactionModel>>(
          stream: cubit.getAllTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Error fetching transactions: ${snapshot.error}");
              return Center(child: Text("حدث خطأ أثناء جلب البيانات"));
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return const Center(child: Text("لا توجد معاملات حتى الآن"));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: w * 0.08,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.014,
                ),
                dataTextStyle: TextStyle(fontSize: w * 0.013),
                columns: const [
                  DataColumn(label: Text("رصيد الخزنة بعد")),
                  DataColumn(label: Text("رصيد الخزنة قبل")),
                  DataColumn(label: Text("النوع")),
                  DataColumn(label: Text("المبلغ")),
                  DataColumn(label: Text("الوصف")),
                  DataColumn(label: Text("التاريخ")),
                ],
                rows: transactions.map((transaction) {
                  // هنا تحتاج تحسب الرصيد قبل وبعد المعاملة
                  final beforeCash =
                      transaction.cashBoxBefore ??
                      0.0; // استبدل بالرصيد الحقيقي قبل المعاملة
                  final afterCash =
                      transaction.cashBoxAfter ??
                      0.0; // استبدل بالرصيد بعد المعاملة

                  return DataRow(
                    cells: [
                      DataCell(
                        afterCash > beforeCash
                            ? Text(
                                afterCash.toStringAsFixed(2),
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                afterCash.toStringAsFixed(2),
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
                      DataCell(Text(beforeCash.toStringAsFixed(2))),

                      DataCell(Text(transaction.transactionType ?? "")),
                      DataCell(
                        Text(transaction.amount?.toStringAsFixed(2) ?? "0.00"),
                      ),
                      DataCell(Text(transaction.transactionDetails ?? "")),
                      DataCell(
                        Text(
                          transaction.transactionDate != null
                              ? "${transaction.transactionDate!.day}/${transaction.transactionDate!.month}/${transaction.transactionDate!.year}"
                              : "",
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
