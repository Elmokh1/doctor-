import 'package:flutter/material.dart';

class UniversalListScreen<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) getName;
  final double Function(T) getBalance;
  final void Function(T) onTap;

  const UniversalListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.getName,
    required this.getBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: items.isEmpty
            ? const Center(child: Text("لا يوجد بيانات بعد"))
            : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
              columnSpacing: width * 0.3,
              border: TableBorder.symmetric(
                inside: const BorderSide(color: Colors.grey, width: 0.2),
                outside: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'الاسم',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الرصيد',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
              rows: items.map((item) {
                final name = getName(item);
                final balance = getBalance(item);

                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => onTap(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        balance.toStringAsFixed(2),
                        style: TextStyle(
                          color: balance > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
}
