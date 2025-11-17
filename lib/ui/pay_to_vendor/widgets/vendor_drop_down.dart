import 'package:el_doctor/cubits/vendors_cubit/vendor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../../cubits/customer_cubit/customer_state.dart';
import '../../../cubits/vendors_cubit/vendor_state.dart';

class VendorDropdown extends StatelessWidget {
  final String? selectedVendorId;
  final Function(String id, String name) onVendorSelected;

  const VendorDropdown({
    super.key,
    required this.selectedVendorId,
    required this.onVendorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VendorLoaded) {
          final vendors = state.vendors;
          if (vendors.isEmpty) return const Text("لا يوجد موردين بعد");

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "اختر المورد",
              border: OutlineInputBorder(),
            ),
            value: selectedVendorId,
            items: vendors.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text(c.name ?? ""),
              );
            }).toList(),
            onChanged: (value) {
              final selected = vendors.firstWhere((c) => c.id == value);
              onVendorSelected(selected.id!, selected.name!);
            },
          );
        } else if (state is VendorError) {
          return Text(state.message);
        }
        return const SizedBox();
      },
    );
  }
}
