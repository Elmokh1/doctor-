import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:el_doctor/cubits/product_cubit/product__cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product_state.dart';
import 'package:el_doctor/data/model/product_model.dart';

typedef OnItemAdded = void Function(Map<String, dynamic> item);

void showAddProductDialog(
    BuildContext context,
    OnItemAdded onItemAdded, {
      required bool isSale,
    }) {
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
              title: Text('add_new_product'.tr(), textAlign: TextAlign.right),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        List<ProductModel> products =
                        (state is ProductLoaded) ? state.sections : [];

                        return DropdownButtonFormField<ProductModel>(
                          decoration:
                          InputDecoration(labelText: 'choose_product'.tr()),
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

                    // Quantity
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'quantity'.tr()),
                      onChanged: (value) =>
                      quantity = int.tryParse(value) ?? 1,
                    ),

                    const SizedBox(height: 15),

                    // Unit Price (sale OR buy)
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'unit_price'.tr(),
                        hintText: selectedProduct != null
                            ? (isSale
                            ? (selectedProduct!.salePrice ?? 0.0)
                            : (selectedProduct!.buyPrice ?? 0.0))
                            .toString()
                            : 'select_product_first'.tr(),
                      ),
                    ),
                  ],
                ),
              ),

              // ACTIONS
              actions: [
                TextButton(
                  child: Text('cancel'.tr()),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('add'.tr()),
                  onPressed: () {
                    if (selectedProduct != null && quantity > 0) {
                      double unitPrice = isSale
                          ? (selectedProduct!.salePrice ?? 0.0)
                          : (selectedProduct!.buyPrice ?? 0.0);

                      onItemAdded({
                        'id': selectedProduct!.id,
                        'name': selectedProduct!.productName,
                        'quantity': quantity,
                        'price': unitPrice,
                        'total': quantity * unitPrice,
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
