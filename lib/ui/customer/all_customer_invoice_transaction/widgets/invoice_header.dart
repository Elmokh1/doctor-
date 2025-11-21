import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:el_doctor/cubits/customer_cubit/customer_cubit.dart';
import 'package:el_doctor/cubits/customer_cubit/customer_state.dart';
import 'package:el_doctor/data/model/customer_model.dart';

class InvoiceHeader extends StatelessWidget {
  final CustomerModel? selectedCustomer;
  final DateTime selectedDate;
  final Function(CustomerModel?) onCustomerChanged;
  final Future<void> Function(BuildContext) onDateSelected;

  const InvoiceHeader({
    required this.selectedCustomer,
    required this.selectedDate,
    required this.onCustomerChanged,
    required this.onDateSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              List<CustomerModel> customers = [];
              if (state is CustomerLoaded) {
                customers = state.customers;
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: tr("select_customer"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                value: selectedCustomer?.id,
                hint: customers.isEmpty
                    ? Text(tr("no_customers_available"))
                    : Text(tr("choose_customer_from_list")),
                items: customers.map((CustomerModel customer) {
                  return DropdownMenuItem<String>(
                    value: customer.id,
                    child: Text(customer.name ?? ""),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    onCustomerChanged(null);
                  } else {
                    final selected =
                    customers.firstWhere((c) => c.id == value);
                    onCustomerChanged(selected);
                  }
                },
                isExpanded: true,
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () => onDateSelected(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: tr("invoice_date"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
