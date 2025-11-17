import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_doctor/cubits/product_cubit/product_cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product_state.dart';
import 'package:el_doctor/data/model/product_model.dart';

// تعريف الـ callback لتمرير العنصر الجديد إلى الـ State
typedef OnItemAdded = void Function(Map<String, dynamic> item);

void showAddProductDialog(BuildContext context, OnItemAdded onItemAdded) {
  ProductModel? selectedProduct;
  int quantity = 1;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocProvider.value(
        value: context.read<ProductCubit>(),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('إضافة منتج جديد', textAlign: TextAlign.right),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        List<ProductModel> products = (state is ProductLoaded) ? state.sections : [];
                        return DropdownButtonFormField<ProductModel>(
                          decoration: const InputDecoration(labelText: 'اختر المنتج'),
                          value: selectedProduct,
                          items: products.map((product) {
                            return DropdownMenuItem<ProductModel>(
                              value: product,
                              child: Text(product.productName ?? ""),
                            );
                          }).toList(),
                          onChanged: (product) {
                            setStateDialog(() => selectedProduct = product);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الكمية'),
                      onChanged: (value) => quantity = int.tryParse(value) ?? 1,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'سعر الوحدة',
                        hintText: selectedProduct != null
                            ? (selectedProduct!.salePrice ?? 0.0).toString()
                            : 'اختر المنتج أولاً',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('إلغاء'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('إضافة'),
                  onPressed: () {
                    if (selectedProduct != null && quantity > 0) {
                      onItemAdded({
                        'id': selectedProduct!.id,
                        'name': selectedProduct!.productName,
                        'quantity': quantity,
                        'price': selectedProduct!.salePrice ?? 0.0,
                        'total': quantity * (selectedProduct!.salePrice ?? 0.0),
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );
}