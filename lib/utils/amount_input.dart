import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;

  const AmountInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "amount".tr(),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
