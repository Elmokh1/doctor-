import 'package:flutter/material.dart';

import '../add_transaction/add_transaction_widget.dart';
import '../add_section/add_section_widget.dart';

class TransactionButtonsRow extends StatelessWidget {
  final double w;
  final double h;

  const TransactionButtonsRow({required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddTransactionDialog(context, true),
          icon: Icon(Icons.add, size: w * 0.015, color: Colors.white),
          label: Text(
            "إضافة دخل جديد",
            style: TextStyle(color: Colors.white, fontSize: w * 0.013),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.02),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(width: w * 0.015),
        ElevatedButton.icon(
          onPressed: () => _showAddSectionDialog(context),
          icon: Icon(Icons.add, size: w * 0.015, color: Colors.white),
          label: Text(
            "إضافة بند جديد",
            style: TextStyle(color: Colors.white, fontSize: w * 0.013),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.02),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(width: w * 0.015),
        ElevatedButton.icon(
          onPressed: () => _showAddTransactionDialog(context, false),
          icon: Icon(Icons.remove, size: w * 0.015, color: Colors.white),
          label: Text(
            "إضافة مصروف جديد",
            style: TextStyle(color: Colors.white, fontSize: w * 0.013),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.02),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context, bool isIncome) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddMoneyTransactionDialog(isIncome: isIncome),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddSectionDialog(),
    );
  }
}
