import 'package:el_doctor/cubits/invoice_counter/invoice_counter_cubit.dart';
import 'package:el_doctor/ui/customer/invoice/widgets/customer_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../cubits/cash_box_cubit/cash_box_cubit.dart';
import '../../../cubits/cash_box_cubit/cash_box_state.dart';
import '../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../cubits/customer_cubit/customer_state.dart';
import '../../../cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import '../../../cubits/recieved_payment_invoice_cubit/received_payment_invoice_state.dart';
import '../../../data/model/customer_model.dart';
import '../../../data/model/customer_transaction_summary_model.dart';
import '../../../utils/amount_input.dart';
import '../../../utils/data_picker_field.dart';
import '../../../utils/details_input.dart';
import '../../../utils/save_button.dart';

class ReceivedPaymentInvoiceScreen extends StatefulWidget {
  const ReceivedPaymentInvoiceScreen({super.key});

  @override
  State<ReceivedPaymentInvoiceScreen> createState() =>
      _ReceivedPaymentInvoiceScreenState();
}

class _ReceivedPaymentInvoiceScreenState
    extends State<ReceivedPaymentInvoiceScreen> {
  String? selectedCustomerId;
  String? selectedCustomerName;
  double? oldBalance;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().getCustomers();
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
    final invoiceCubit = context.read<ReceivedPaymentInvoiceCubit>();
    final cashCubit = context.read<CashBoxCubit>();
    final customerCubit = context.read<CustomerCubit>();
    final counterCubit = context.read<InvoiceCounterCubit>();
    final transactionCubit = context.read<CustomerTransactionSummaryCubit>();

    final amount = double.tryParse(amountController.text) ?? 0;
    final details = detailsController.text;

    if (selectedCustomerId == null ||
        selectedCustomerName == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("fill_all_fields"))),
      );
      return;
    }

    final cashBoxBefore = cashCubit.state is CashBoxLoaded
        ? (cashCubit.state as CashBoxLoaded).cash
        : 0.0;
    final cashBoxAfter = cashBoxBefore + amount;

    if (customerCubit.state is CustomerLoaded) {
      final customerState = customerCubit.state as CustomerLoaded;
      final currentCustomer = customerState.customers.firstWhere(
            (c) => c.id == selectedCustomerId,
        orElse: () => CustomerModel(
          id: selectedCustomerId,
          name: selectedCustomerName,
          openingBalance: 0,
        ),
      );

      final oldBalance = currentCustomer.openingBalance ?? 0;
      final newBalance = oldBalance - amount;

      final currentCounter = await counterCubit.getCounter();
      final newCounter = currentCounter + 1;

      // إضافة الفاتورة
      await invoiceCubit.addReceivedPaymentInvoice(
        id: newCounter.toString(),
        customerName: selectedCustomerName!,
        customerId: selectedCustomerId!,
        amount: amount,
        cashBoxBefore: cashBoxBefore,
        cashBoxAfter: cashBoxAfter,
        oldBalance: oldBalance,
        newBalance: newBalance,
        transactionDetails: details,
        transactionDate: selectedDate,
      );

      // تحديث الكاش بوكس
      await cashCubit.updateCash(amount, isIncome: true);

      // تحديث رصيد العميل
      await customerCubit.updateCustomerBalance(
        customerId: selectedCustomerId!,
        newBalance: newBalance,
      );

      // 🔹 إضافة حركة للـ CustomerTransactionSummary
      await transactionCubit.addTransaction(
        CustomerTransactionSummaryModel(
          invoiceId: newCounter.toString(),
          customerId: selectedCustomerId!,
          customerName: selectedCustomerName!,
          amount: amount,
          debtBefore: oldBalance,
          debtAfter: newBalance,
          notes: details,
          dateTime: selectedDate,
          transactionType: "تحصيل", // ممكن تستخدم أي تسمية
        ),
      );
    }

    await counterCubit.updateCounter();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr("invoice_saved_successfully")),
      ),
    );

    // تنظيف الحقول
    amountController.clear();
    detailsController.clear();
    setState(() {
      selectedCustomerId = null;
      selectedCustomerName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("received_payment_invoice")),
        centerTitle: true,
      ),
      body: BlocConsumer<ReceivedPaymentInvoiceCubit,
          ReceivedPaymentInvoiceState>(
        listener: (context, state) {
          if (state is ReceivedPaymentInvoiceError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                CustomerDropdown(
                  selectedCustomerId: selectedCustomerId,
                  onCustomerSelected: (id, name) {
                    setState(() {
                      selectedCustomerId = id;
                      selectedCustomerName = name;
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
                  isLoading: state is ReceivedPaymentInvoiceLoading,
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
