import 'package:flutter/material.dart';

class DetailsInput extends StatelessWidget {
  final TextEditingController controller;

  const DetailsInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: "تفاصيل العملية (اختياري)",
        border: OutlineInputBorder(),
      ),
    );
  }
}
