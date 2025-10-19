import 'package:el_doctor/ui/home_screen/add_transaction/widgets/amount_and_details_form.dart';
import 'package:el_doctor/ui/home_screen/add_transaction/widgets/save_button.dart';
import 'package:el_doctor/ui/home_screen/add_transaction/widgets/section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/money_transaction_cubit/money_transaction_cubit.dart';
import '../../../cubits/money_transaction_cubit/money_transaction_state_state.dart';
import '../../../cubits/section_cubit/section_cubit.dart';
import '../../../data/model/sections_model.dart';
import '../../../utils/snack_bar.dart';

class AddMoneyTransactionDialog extends StatefulWidget {
  final bool isIncome;

  const AddMoneyTransactionDialog({required this.isIncome});

  @override
  State<AddMoneyTransactionDialog> createState() =>
      _AddMoneyTransactionDialogState();
}

class _AddMoneyTransactionDialogState extends State<AddMoneyTransactionDialog> {
  DateTime? _selectedDate;
  SectionsModel? _selectedSection;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SectionCubit>().getSections();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MoneyTransactionCubit, MoneyTransactionState>(
      listener: (context, state) {
        if (state is MoneyTransactionSuccess) {
          Navigator.pop(context);
          showSuccessSnackBar(context, "تم إضافة الحركة بنجاح");
        } else if (state is MoneyTransactionError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إضافة حركة مالية"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              SectionDropdown(
                isIncome: widget.isIncome,
                onSectionSelected: (section) => _selectedSection = section,
              ),
              const SizedBox(height: 10),
              AmountAndDetailsForm(
                amountController: _amountController,
                detailsController: _detailsController,
                selectedDate: _selectedDate,
                onDatePicked: (date) => setState(() => _selectedDate = date),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          SaveButton(
            amountController: _amountController,
            detailsController: _detailsController,
            selectedSection: _selectedSection,
            selectedDate: _selectedDate,
          ),
        ],
      ),
    );
  }
}
