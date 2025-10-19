import 'package:el_doctor/ui/home_screen/widgets/transaction_buttons_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cash_box_cubit/cash_box_cubit.dart';
import 'widgets/slide_bar_widget.dart';
import 'widgets/cash_balance_widget.dart';
import 'widgets/recent_transactions_section.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CashBoxCubit>().getCash();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Scaffold(
          body: Row(
            children: [
              SlideBarWidget(w, h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CashBalanceWidget(),
                      SizedBox(height: h * 0.04),
                      TransactionButtonsRow(w: w, h: h),
                      SizedBox(height: h * 0.05),
                      Expanded(
                        child: RecentTransactionsSection(h: h, w: w),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
