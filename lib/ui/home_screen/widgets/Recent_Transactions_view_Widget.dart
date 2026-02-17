import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../cubits/money_transaction_cubit/money_transaction_cubit.dart';
import '../../../data/model/money_transaction_model.dart';
import '../All_Money_Transaction_Page.dart';

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
        child: Column(
          children: [
            /// 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "recent_transactions".tr(),
                  style: TextStyle(
                    fontSize: w * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllMoneyTransactionsPage(),
                      ),
                    );
                  },
                  child: Text(
                    "more".tr(), // أو More
                    style: TextStyle(fontSize: w * 0.013),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// 🔹 Table
            Expanded(
              child: StreamBuilder<List<MoneyTransactionModel>>(
                stream: cubit.getAllTransactionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("error_fetching_data".tr()));
                  }

                  final transactions = snapshot.data ?? [];

                  if (transactions.isEmpty) {
                    return Center(child: Text("no_transactions_yet".tr()));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: w * 0.08,
                      columns: [
                        DataColumn(label: Text("cash_after".tr())),
                        DataColumn(label: Text("cash_before".tr())),
                        DataColumn(label: Text("transaction_type".tr())),
                        DataColumn(label: Text("amount".tr())),
                        DataColumn(label: Text("details".tr())),
                        DataColumn(label: Text("date".tr())),
                      ],
                      rows: transactions.map((transaction) {
                        final beforeCash = transaction.cashBoxBefore ?? 0.0;
                        final afterCash = transaction.cashBoxAfter ?? 0.0;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                afterCash.toStringAsFixed(2),
                                style: TextStyle(
                                  color: afterCash > beforeCash
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            DataCell(Text(beforeCash.toStringAsFixed(2))),
                            DataCell(Text(transaction.transactionType ?? "")),
                            DataCell(Text(
                                transaction.amount?.toStringAsFixed(2) ?? "0")),
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
          ],
        ),
      ),
    );
  }

}
