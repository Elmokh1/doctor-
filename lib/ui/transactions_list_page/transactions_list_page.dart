import 'package:el_doctor/data/my_dataBase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
    );

    if (pickedFrom == null) return;

    final pickedTo = await showDatePicker(
      context: context,
      initialDate: toDate ?? pickedFrom,
      firstDate: pickedFrom,
      lastDate: DateTime(2100),
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
    return DateFormat("dd/MM/yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isIncome);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الحركات المالية",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                          ? "اختر فترة زمنية"
                          : "من ${DateFormat("dd MMMM yyyy", "ar").format(fromDate!)} إلى ${DateFormat("dd MMMM yyyy", "ar").format(toDate!)}",
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
                  print(snapshot.error);
                  return Center(
                    child: Text('حدث خطأ: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
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
                print(widget.isIncome);

                if (transactions.isEmpty) {
                  print(widget.isIncome);
                  return const Center(
                    child: Text("لا توجد بيانات",
                        style: TextStyle(color: Colors.grey, fontSize: 20)),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("المبلغ")),
                        DataColumn(label: Text("النوع")),
                        DataColumn(label: Text("الخزنة قبل")),
                        DataColumn(label: Text("الخزنة بعد")),
                        DataColumn(label: Text("التاريخ")),
                        DataColumn(label: Text("التفاصيل")),
                      ],
                      rows: transactions.map((tx) {
                        final isDeposit = (tx.amount ?? 0) > 0;
                        final textColor = isDeposit ? Colors.green : Colors.red;

                        return DataRow(
                          cells: [
                            DataCell(Text("${tx.amount} جنيه",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: textColor))),
                            DataCell(
                                Text(tx.transactionType ?? "", style: TextStyle(color: textColor))),
                            DataCell(Text("${tx.cashBoxBefore ?? 0}")),
                            DataCell(Text("${tx.cashBoxAfter ?? 0}")),
                            DataCell(Text( tx.transactionDate != null ? "${tx.transactionDate!.day}/${tx.transactionDate!.month}/${tx.transactionDate!.year}" : "", ),),                            DataCell(Text("${tx.transactionDetails ?? ""}")),
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
