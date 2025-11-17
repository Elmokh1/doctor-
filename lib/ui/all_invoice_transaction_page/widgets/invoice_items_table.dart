import 'package:flutter/material.dart';

class InvoiceItemsTable extends StatelessWidget {
  final List<Map<String, dynamic>> invoiceItems;
  final Function(int) onItemRemoved;

  const InvoiceItemsTable({
    super.key,
    required this.invoiceItems,
    required this.onItemRemoved,
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
          columns: const [
            DataColumn(label: Text('م', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('اسم المنتج', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('سعر الوحدة', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
            DataColumn(label: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
            DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: invoiceItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(SizedBox(width: 150, child: Text(item['name'].toString(), overflow: TextOverflow.ellipsis))),
                DataCell(Text(item['quantity'].toString(), textAlign: TextAlign.center)),
                DataCell(Text(item['price'].toStringAsFixed(2), textAlign: TextAlign.right, textDirection: TextDirection.ltr)),
                DataCell(Text(item['total'].toStringAsFixed(2), textAlign: TextAlign.right, textDirection: TextDirection.ltr)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'حذف المنتج',
                    onPressed: () => onItemRemoved(index), // استدعاء الدالة الممررة
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