import 'package:el_doctor/cubits/product_cubit/product__cubit.dart';
import 'package:el_doctor/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../product_transaction_view.dart';

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
            return Center(child: Text("fetch_error".tr()));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(child: Text("no_products".tr()));
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
              columns: [
                DataColumn(label: Text("product_name".tr())),
                DataColumn(label: Text("quantity".tr())),
                DataColumn(label: Text("sale_price".tr())),
                DataColumn(label: Text("buy_price".tr())),
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
                    DataCell(
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductTransactionsPage(
                                productId: product.id ?? "",
                                productName: product.productName ?? "",
                                qun: product.qun?.toString() ?? "0",
                              ),
                            ),
                          );
                        },
                        child: Text(product.qun?.toString() ?? "0"),
                      ),
                    ),
                    DataCell(
                      Text(product.salePrice?.toStringAsFixed(1) ?? "0.00"),
                    ),
                    DataCell(
                      Text(product.buyPrice?.toStringAsFixed(2) ?? "0.00"),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context,
      ProductModel product,
      ProductCubit cubit,
      ) {
    final nameController = TextEditingController(text: product.productName ?? "");
    final buyController = TextEditingController(text: product.buyPrice?.toString() ?? "");
    final saleController = TextEditingController(text: product.salePrice?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            "edit_product".tr(),
            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "product_name".tr(),
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: buyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "buy_price".tr(),
                    prefixIcon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: saleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "sale_price".tr(),
                    prefixIcon: const Icon(Icons.sell_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("cancel".tr(), style: const TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 18),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              label: Text("save".tr()),
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
                  SnackBar(content: Text("product_updated_success".tr())),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
