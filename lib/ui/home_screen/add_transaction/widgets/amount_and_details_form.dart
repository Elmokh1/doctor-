import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AmountAndDetailsForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController detailsController;
  final DateTime? selectedDate;
  final Function(DateTime) onDatePicked;

  const AmountAndDetailsForm({
    required this.amountController,
    required this.detailsController,
    required this.selectedDate,
    required this.onDatePicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "amount".tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: detailsController,
          decoration: InputDecoration(
            labelText: "details".tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedDate == null
                ? "no_date_selected".tr()
                : "${"date".tr()}: ${selectedDate!.toString().split(' ')[0]}"),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onDatePicked(picked);
              },
              child: Text("pick_date".tr()),
            ),
          ],
        ),
      ],
    );
  }
}
