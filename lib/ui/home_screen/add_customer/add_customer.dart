import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../cubits/customer_cubit/customer_state.dart';
import '../../../utils/snack_bar.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _opiningBalanceController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is CustomerLoading) {
          print("جاري الحفظ...");
        } else if (state is CustomerSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "تم إضافة العميل بنجاح");
        } else if (state is CustomerError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إضافة عميل جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: " اسم العميل",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _opiningBalanceController,
              decoration: const InputDecoration(
                hintText: "رصيد الافتتاحي ",
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
                  _opiningBalanceController.text.trim().isEmpty) {
                showErrorSnackBar(context, "اكمل جميع الحقول أولاً");
                return;
              }
              context.read<CustomerCubit>().addCustomer(
                _nameController.text.trim(),
                double.parse(_opiningBalanceController.text.trim()),
              );
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
