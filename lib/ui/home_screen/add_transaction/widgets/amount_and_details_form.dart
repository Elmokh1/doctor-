import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "المبلغ", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: detailsController,
          decoration: const InputDecoration(labelText: "تفاصيل الحركة", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedDate == null
                ? "لم يتم اختيار تاريخ"
                : "التاريخ: ${selectedDate!.toString().split(' ')[0]}"),
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
              child: const Text("اختيار تاريخ"),
            ),
          ],
        ),
      ],
    );
  }
}
