import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DetailsInput extends StatelessWidget {
  final TextEditingController controller;

  const DetailsInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: "transaction_details_optional".tr(),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
