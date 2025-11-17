import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../../cubits/customer_cubit/customer_state.dart';

class CustomerDropdown extends StatelessWidget {
  final String? selectedCustomerId;
  final Function(String id, String name) onCustomerSelected;

  const CustomerDropdown({
    super.key,
    required this.selectedCustomerId,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CustomerLoaded) {
          final customers = state.customers;
          if (customers.isEmpty) return const Text("لا يوجد عملاء بعد");

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "اختر العميل",
              border: OutlineInputBorder(),
            ),
            value: selectedCustomerId,
            items: customers.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text(c.name ?? ""),
              );
            }).toList(),
            onChanged: (value) {
              final selected = customers.firstWhere((c) => c.id == value);
              onCustomerSelected(selected.id!, selected.name!);
            },
          );
        } else if (state is CustomerError) {
          return Text(state.message);
        }
        return const SizedBox();
      },
    );
  }
}
