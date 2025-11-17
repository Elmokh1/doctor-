import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "التاريخ",
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
