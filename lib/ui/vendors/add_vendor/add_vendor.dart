import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

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
          print("saving...".tr());
        } else if (state is VendorSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "vendor_added_success".tr());
        } else if (state is VendorError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("add_new_vendor".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "vendor_name".tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _opiningBalanceController,
              decoration: InputDecoration(
                hintText: "opening_balance".tr(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _opiningBalanceController.text.trim().isEmpty) {
                showErrorSnackBar(context, "fill_all_fields".tr());
                return;
              }
              context.read<VendorCubit>().addVendor(
                _nameController.text.trim(),
                double.parse(_opiningBalanceController.text.trim()),
              );
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }
}
