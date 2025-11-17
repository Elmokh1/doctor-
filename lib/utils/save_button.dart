import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
      icon: const Icon(Icons.save),
      label: const Text("حفظ الفاتورة"),
      onPressed: onPressed,
    );
  }
}
