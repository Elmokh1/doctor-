import 'package:el_doctor/cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import 'package:el_doctor/data/model/vendor_transaction_summary_model.dart';
import 'package:el_doctor/ui/vendors/pay_to_vendor/widgets/vendor_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../cubits/cash_box_cubit/cash_box_state.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_state.dart';
import '../../../cubits/vendor_pay_counter/vendor_pay_counter_cubit.dart';
import '../../../cubits/vendors_cubit/vendor_cubit.dart';
import '../../../cubits/vendors_cubit/vendor_state.dart';
import '../../../data/model/vendor_model.dart';
import '../../../utils/amount_input.dart';
import '../../../utils/data_picker_field.dart';
import '../../../utils/details_input.dart';
import '../../../utils/save_button.dart';

class PayVendorInvoiceScreen extends StatefulWidget {
  const PayVendorInvoiceScreen({super.key});

  @override
  State<PayVendorInvoiceScreen> createState() => _PayVendorInvoiceScreenState();
}

class _PayVendorInvoiceScreenState extends State<PayVendorInvoiceScreen> {
  String? selectedVendorId;
  String? selectedVendorName;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<VendorCubit>().getVendors();
  }

  void pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> saveInvoice() async {
    final invoiceCubit = context.read<PayVendorInvoiceCubit>();
    final cashCubit = context.read<CashBoxCubit>();
    final vendorCubit = context.read<VendorCubit>();
    final counterCubit = context.read<VendorPayCounterCubit>();
    final transactionCubit = context.read<VendorTransactionSummaryCubit>();

    final amount = double.tryParse(amountController.text) ?? 0;
    final details = detailsController.text;

    if (selectedVendorId == null || selectedVendorName == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("please_fill_all_fields".tr())),
      );
      return;
    }

    final cashBoxBefore = cashCubit.state is CashBoxLoaded
        ? (cashCubit.state as CashBoxLoaded).cash
        : 0.0;
    final cashBoxAfter = cashBoxBefore - amount;

    if (vendorCubit.state is VendorLoaded) {
      final vendorState = vendorCubit.state as VendorLoaded;

      final currentVendor = vendorState.vendors.firstWhere(
            (v) => v.id == selectedVendorId,
        orElse: () => VendorModel(
          id: selectedVendorId,
          name: selectedVendorName,
          openingBalance: 0,
        ),
      );

      final oldBalance = currentVendor.openingBalance ?? 0;
      final newBalance = oldBalance - amount;

      final currentCounter = await counterCubit.getCounter();
      final newCounter = currentCounter + 1;

      await invoiceCubit.addPayVendorInvoice(
        id: newCounter.toString(),
        vendorName: selectedVendorName!,
        vendorId: selectedVendorId!,
        amount: amount,
        cashBoxBefore: cashBoxBefore,
        cashBoxAfter: cashBoxAfter,
        oldBalance: oldBalance,
        newBalance: newBalance,
        transactionDetails: details,
        transactionDate: selectedDate,
      );

      await cashCubit.updateCash(amount, isIncome: false);
      await vendorCubit.updateVendorBalance(
        vendorId: selectedVendorId!,
        newBalance: newBalance,
      );

      await transactionCubit.addTransaction(
        VendorTransactionSummaryModel(
          invoiceId: newCounter.toString(),
          vendorId: selectedVendorId!,
          vendorName:selectedVendorName!,
          amount: amount,
          debtBefore: oldBalance,
          debtAfter: newBalance,
          notes: details,
          dateTime: selectedDate,
          transactionType: 'دفع',
        ),
      );

      await counterCubit.updateCounter();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("invoice_saved_success".tr()),
      ),
    );

    amountController.clear();
    detailsController.clear();
    setState(() {
      selectedVendorId = null;
      selectedVendorName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("pay_vendor_invoice".tr()),
        centerTitle: true,
      ),
      body: BlocConsumer<PayVendorInvoiceCubit, PayVendorInvoiceState>(
        listener: (context, state) {
          if (state is PayVendorInvoiceError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                VendorDropdown(
                  selectedVendorId: selectedVendorId,
                  onVendorSelected: (id, name) {
                    setState(() {
                      selectedVendorId = id;
                      selectedVendorName = name;
                    });
                  },
                ),
                const SizedBox(height: 16),
                AmountInput(controller: amountController),
                const SizedBox(height: 16),
                DetailsInput(controller: detailsController),
                const SizedBox(height: 16),
                DatePickerField(
                  selectedDate: selectedDate,
                  onPickDate: pickDate,
                ),
                const SizedBox(height: 24),
                SaveButton(
                  isLoading: state is PayVendorInvoiceLoading,
                  onPressed: saveInvoice,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
