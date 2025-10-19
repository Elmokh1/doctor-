import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../cubits/cash_box_cubit/cash_box_state.dart';

class CashBalanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashBoxCubit, CashBoxState>(
      builder: (context, state) {
        double cash = 0.0;

        if (state is CashBoxLoaded) {
          cash = state.cash;
        } else if (state is CashBoxLoading) {
          return const CircularProgressIndicator();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "الرصيد الحالي",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${cash.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }
}
