import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui'as ui;
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
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: items.isEmpty
            ? Center(
          child: Text(
            "no_data".tr(),
            style: const TextStyle(fontSize: 18),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          scrollDirection: Axis.vertical,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columnSpacing: 50,
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: [
                DataColumn(
                  label: Text(
                    'name'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'balance'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        balance.toStringAsFixed(2),
                        style: TextStyle(
                          color: balance > 0 ? Colors.green : Colors.red,
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
