import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          print("جاري الحفظ...");
        } else if (state is SectionSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "تم إضافة البند بنجاح");
        } else if (state is SectionError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إضافة بند جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<bool>(
              value: _isIncome,
              decoration: const InputDecoration(
                labelText: "نوع البند",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text('دخل')),
                DropdownMenuItem(value: false, child: Text('مصروف')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _isIncome = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "اكتب اسم البند",
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
              if (_controller.text.trim().isEmpty) {
                showErrorSnackBar(context, "اكتب اسم البند أولاً");
                return;
              }
              context.read<SectionCubit>().addSection(
                _controller.text.trim(),
                _isIncome,
              );
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
