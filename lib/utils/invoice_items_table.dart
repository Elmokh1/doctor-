import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InvoiceItemsTable extends StatelessWidget {
  final List<Map<String, dynamic>> invoiceItems;
  final Function(int) onItemRemoved;

  const InvoiceItemsTable({
    required this.invoiceItems,
    required this.onItemRemoved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 35.0,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade100),
          columns: [
            DataColumn(
              label: Text(
                'no'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'product_name'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'quantity'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'unit_price'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            DataColumn(
              label: Text(
                'total'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            DataColumn(
              label: Text(
                'action'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: invoiceItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      item['name'].toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item['quantity'].toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataCell(
                  Text(
                    item['price'].toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  ),
                ),
                DataCell(
                  Text(
                    item['total'].toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'delete_product'.tr(),
                    onPressed: () => onItemRemoved(index),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
