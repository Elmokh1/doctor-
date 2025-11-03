import 'package:el_doctor/ui/inventory_Screen/widgets/store_table_widget.dart';
import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('📦 المخزن'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 3,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: StoreTableWidget()),
            ],
          ),
        ),
      ),
    );
  }

}



// child: Container(
// width: double.infinity,
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(12),
// boxShadow: [
// BoxShadow(
// color: Colors.black12,
// blurRadius: 8,
// offset: const Offset(0, 3),
// ),
// ],
// ),
// child: Column(
// children: [
// const SizedBox(height: 20),
// Expanded(
// child: SingleChildScrollView(
// controller: verticalController,
// scrollDirection: Axis.vertical,
// child: Scrollbar(
// controller: horizontalController,
// thumbVisibility: true,
// trackVisibility: true,
// notificationPredicate: (_) => false,
// child: SingleChildScrollView(
// controller: horizontalController,
// scrollDirection: Axis.horizontal,
// reverse: true,
// child: DataTable(
// headingRowColor:
// WidgetStatePropertyAll(Colors.teal.shade100),
// border: TableBorder.all(color: Colors.grey.shade300),
// headingTextStyle: const TextStyle(
// fontWeight: FontWeight.bold, color: Colors.black87),
// columns: const [
// DataColumn(label: Text('اسم المنتج')),
// DataColumn(label: Text('سعر الشراء')),
// DataColumn(label: Text('سعر البيع')),
// DataColumn(label: Text('الكمية')),
// ],
// rows: dummyProducts.map((product) {
// final total = (product['salePrice'] as double) *
// (product['quantity'] as int);
// return DataRow(
// cells: [
// DataCell(Text(product['name'].toString())),
// DataCell(Text('${product['buyPrice']} ج')),
// DataCell(Text('${product['salePrice']} ج')),
// DataCell(Text('${product['quantity']}')),
// ],
// );
// }).toList(),
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// ),
