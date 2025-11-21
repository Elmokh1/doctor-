import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
      label: Text('save_invoice'.tr()),
      onPressed: onPressed,
    );
  }
}
