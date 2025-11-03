import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/vendors_cubit/vendor_cubit.dart';
import '../../../cubits/vendors_cubit/vendor_state.dart';
import '../../../utils/snack_bar.dart';

class AddVendorDialog extends StatefulWidget {
  const AddVendorDialog({super.key});

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _opiningBalanceController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorCubit, VendorState>(
      listener: (context, state) {
        if (state is VendorLoading) {
          print("جاري الحفظ...");
        } else if (state is VendorSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "تم إضافة العميل بنجاح");
        } else if (state is VendorError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إضافة مورد جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: " اسم المورد",
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
              context.read<VendorCubit>().addVendor(
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
