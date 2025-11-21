import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../../cubits/money_transaction_cubit/money_transaction_cubit.dart';
import '../../../../cubits/money_transaction_cubit/money_transaction_state_state.dart';
import '../../../../data/model/sections_model.dart';
import '../../../../utils/snack_bar.dart';

class SaveButton extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController detailsController;
  final SectionsModel? selectedSection;
  final DateTime? selectedDate;

  const SaveButton({
    required this.amountController,
    required this.detailsController,
    required this.selectedSection,
    required this.selectedDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoneyTransactionCubit, MoneyTransactionState>(
      builder: (context, state) {
        final isLoading = state is MoneyTransactionLoading;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
            if (selectedSection == null ||
                amountController.text.trim().isEmpty ||
                detailsController.text.trim().isEmpty) {
              showErrorSnackBar(context, "all_fields_required".tr());
              return;
            }

            final cubit = context.read<MoneyTransactionCubit>();
            final cashCubit = context.read<CashBoxCubit>();
            final amount = double.tryParse(amountController.text.trim());
            if (amount == null) {
              showErrorSnackBar(context, "enter_valid_amount".tr());
              return;
            }

            double currentCash;
            try {
              currentCash = await cashCubit.getCash();
            } catch (_) {
              showErrorSnackBar(context, "failed_fetch_cash".tr());
              return;
            }

            // هنا حددنا default value لو isIncome null
            final isIncome = selectedSection!.isIncome ?? true;
            final newCash = isIncome
                ? currentCash + amount
                : currentCash - amount;

            cubit.addMoneyTransaction(
              selectedSection!.name ?? "",
              selectedSection!,
              selectedSection?.isIncome ?? false,
              amount,
              currentCash,
              newCash,
              detailsController.text.trim(),
              selectedDate,
              onSuccess: () {
                cashCubit.updateCash(amount, isIncome: isIncome);
                showSuccessSnackBar(context, "cash_updated_success".tr());
              },
            );
          },
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text("save".tr()),
        );
      },
    );
  }
}
