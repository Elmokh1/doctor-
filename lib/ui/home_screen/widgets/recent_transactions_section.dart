import 'package:flutter/material.dart';
import 'Recent_Transactions_view_Widget.dart';

class RecentTransactionsSection extends StatelessWidget {
  final double h;
  final double w;

  const RecentTransactionsSection({required this.h, required this.w});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "آخر الحركات المالية",
          style: TextStyle(fontSize: w * 0.018, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: h * 0.02),
        RecentTransactionsWidget(h, w),
      ],
    );
  }
}
