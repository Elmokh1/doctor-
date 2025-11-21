import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

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
  final TextEditingController _openingBalanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is CustomerLoading) {
          print(tr("saving")); // جاري الحفظ...
        } else if (state is CustomerSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, tr("customer_added_success"));
        } else if (state is CustomerError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(tr("add_new_customer")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: tr("customer_name"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _openingBalanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: tr("opening_balance"),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("cancel")),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _openingBalanceController.text.trim().isEmpty) {
                showErrorSnackBar(context, tr("fill_all_fields"));
                return;
              }
              context.read<CustomerCubit>().addCustomer(
                _nameController.text.trim(),
                double.parse(_openingBalanceController.text.trim()),
              );
            },
            child: Text(tr("save")),
          ),
        ],
      ),
    );
  }
}
