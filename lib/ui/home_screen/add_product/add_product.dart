import 'package:el_doctor/cubits/product_cubit/product_cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/section_cubit/section_cubit.dart';
import '../../../cubits/section_cubit/section_state.dart';
import '../../../utils/snack_bar.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductLoading) {
          print("جاري الحفظ...");
        } else if (state is ProductSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "تم إضافة المنتج بنجاح");
        } else if (state is ProductError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إضافة منتج جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: " اسم المنتج",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _buyController,
              decoration: const InputDecoration(
                hintText: " سعر الشراء",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _salePriceController,
              decoration: const InputDecoration(
                hintText: "سعر البيع",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _buyController.text.trim().isEmpty ||
                  _salePriceController.text.trim().isEmpty) {
                showErrorSnackBar(context, "اكمل جميع الحقول أولاً");
                return;
              }
              context.read<ProductCubit>().addProduct(
                _nameController.text.trim(),
                double.parse(_buyController.text.trim()),
               0,
                double.parse(_salePriceController.text.trim()),
                0
              );
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
