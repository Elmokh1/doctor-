import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/section_cubit/section_cubit.dart';
import '../../../cubits/section_cubit/section_state.dart';
import '../../../utils/snack_bar.dart';

class AddSectionDialog extends StatefulWidget {
  const AddSectionDialog({super.key});

  @override
  State<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isIncome = false; // افتراضي مصروف

  @override
  Widget build(BuildContext context) {
    return BlocListener<SectionCubit, SectionState>(
      listener: (context, state) {
        if (state is SectionLoading) {
          print("loading".tr());
        } else if (state is SectionSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "section_added_success".tr());
        } else if (state is SectionError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("add_new_section".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<bool>(
              value: _isIncome,
              decoration: InputDecoration(
                labelText: "section_type".tr(),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: true, child: Text('income'.tr())),
                DropdownMenuItem(value: false, child: Text('expenses'.tr())),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _isIncome = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "enter_section_name".tr(),
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
              if (_controller.text.trim().isEmpty) {
                showErrorSnackBar(context, "enter_section_name_first".tr());
                return;
              }
              context.read<SectionCubit>().addSection(
                _controller.text.trim(),
                _isIncome,
              );
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }
}
