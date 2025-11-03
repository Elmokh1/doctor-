import 'package:el_doctor/cubits/product_cubit/product_cubit.dart';
import 'package:el_doctor/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreTableWidget extends StatelessWidget {
  const StoreTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<List<ProductModel>>(
        stream: cubit.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching product: ${snapshot.error}");
            return const Center(child: Text("حدث خطأ أثناء جلب البيانات"));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text("لا توجد منتجات في المخزن"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              dataTextStyle: const TextStyle(fontSize: 18),
              columns: const [
                DataColumn(label: Text("اسم المنتج")),
                DataColumn(label: Text("الكمية")),
                DataColumn(label: Text("سعر البيع")),
                DataColumn(label: Text("سعر الشراء")),
              ],
              rows: products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () {
                          _showEditDialog(context, product, cubit);
                        },
                        child: Text(
                          product.productName ?? "",
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(product.qun?.toString() ?? "0")),
                    DataCell(Text(product.salePrice?.toStringAsFixed(1) ?? "0.00")),
                    DataCell(Text(product.buyPrice?.toStringAsFixed(2) ?? "0.00")),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }



  void _showEditDialog(BuildContext context, ProductModel product, ProductCubit cubit) {
    final nameController = TextEditingController(text: product.productName ?? "");
    final buyController = TextEditingController(text: product.buyPrice?.toString() ?? "");
    final saleController = TextEditingController(text: product.salePrice?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            "تعديل بيانات المنتج",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "اسم المنتج",
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: buyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "سعر الشراء",
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: saleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "سعر البيع",
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 18),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              label: const Text("حفظ"),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newBuy = double.tryParse(buyController.text) ?? 0.0;
                final newSale = double.tryParse(saleController.text) ?? 0.0;

                await cubit.updateProductInfo(
                  id: product.id ?? "",
                  newName: newName,
                  newBuyPrice: newBuy,
                  newSalePrice: newSale,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ تم تحديث المنتج بنجاح")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
