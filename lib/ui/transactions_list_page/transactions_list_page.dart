import 'package:el_doctor/data/my_dataBase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/model/money_transaction_model.dart';

class TransactionsListPage extends StatefulWidget {
  static const String routeName = "/transactionsListPage";
  final bool isIncome;

  const TransactionsListPage({required this.isIncome, Key? key}) : super(key: key);

  @override
  _TransactionsListPageState createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> pickDateRange() async {
    final pickedFrom = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: context.locale, // تحديد اللغة حسب Easy Localization
    );

    if (pickedFrom == null) return;

    final pickedTo = await showDatePicker(
      context: context,
      initialDate: toDate ?? pickedFrom,
      firstDate: pickedFrom,
      lastDate: DateTime(2100),
      locale: context.locale,
    );

    if (pickedTo == null) return;

    setState(() {
      fromDate = pickedFrom;
      toDate = pickedTo;
    });
  }

  String formatDateFromMillis(int? millis) {
    if (millis == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat.yMMMd(context.locale.toString()).format(date);
  }

  String formatDate(DateTime date) {
    return DateFormat("dd MMMM yyyy", context.locale.toString()).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "financial_transactions".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (fromDate != null && toDate != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  fromDate = null;
                  toDate = null;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: pickDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fromDate == null || toDate == null
                          ? "select_date_range".tr()
                          : "${"from".tr()} ${formatDate(fromDate!)} ${"to".tr()} ${formatDate(toDate!)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.date_range),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<MoneyTransactionModel>>(
              stream: (fromDate != null && toDate != null)
                  ? MyDatabase.getTransactionsByDateRange(
                fromDate: fromDate!,
                toDate: toDate!,
                isIncome: widget.isIncome,
              )
                  : MyDatabase.getAllTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'error_occurred'.tr(args: [snapshot.error.toString()]),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data?.docs
                    .map((doc) => doc.data())
                    .where((tx) => tx.isIncome == widget.isIncome)
                    .toList() ??
                    [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      "no_data".tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                      MaterialStateProperty.all(Colors.blue.shade50),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: [
                        DataColumn(label: Text("amount".tr())),
                        DataColumn(label: Text("type".tr())),
                        DataColumn(label: Text("cash_before".tr())),
                        DataColumn(label: Text("cash_after".tr())),
                        DataColumn(label: Text("date".tr())),
                        DataColumn(label: Text("details".tr())),
                      ],
                      rows: transactions.map((tx) {
                        final isDeposit = (tx.amount ?? 0) > 0;
                        final textColor = isDeposit ? Colors.green : Colors.red;

                        return DataRow(
                          cells: [
                            DataCell(Text(
                                "${tx.amount} ${"currency".tr()}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor))),
                            DataCell(Text(tx.transactionType ?? "",
                                style: TextStyle(color: textColor))),
                            DataCell(Text("${tx.cashBoxBefore ?? 0}")),
                            DataCell(Text("${tx.cashBoxAfter ?? 0}")),
                            DataCell(Text(tx.transactionDate != null
                                ? formatDate(tx.transactionDate!)
                                : "")),
                            DataCell(Text("${tx.transactionDetails ?? ""}")),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
