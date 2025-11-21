import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'Recent_Transactions_view_Widget.dart';

class RecentTransactionsSection extends StatelessWidget {
  final double h;
  final double w;

  const RecentTransactionsSection({required this.h, required this.w, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "recent_transactions".tr(),
          style: TextStyle(fontSize: w * 0.018, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: h * 0.02),
        RecentTransactionsWidget(h, w),
      ],
    );
  }
}
