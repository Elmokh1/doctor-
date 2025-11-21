import 'package:el_doctor/cubits/vendors_cubit/vendor_cubit.dart';
import 'package:el_doctor/cubits/vendors_cubit/vendor_state.dart';
import 'package:el_doctor/data/model/vendor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class InvoiceHeader extends StatelessWidget {
  final VendorModel? selectedVendor;
  final DateTime selectedDate;
  final Function(VendorModel?) onVendorChanged;
  final Future<void> Function(BuildContext) onDateSelected;

  const InvoiceHeader({
    required this.selectedVendor,
    required this.selectedDate,
    required this.onVendorChanged,
    required this.onDateSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: BlocBuilder<VendorCubit, VendorState>(
            builder: (context, state) {
              List<VendorModel> vendors = [];
              if (state is VendorLoaded) {
                vendors = state.vendors;
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'select_vendor'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                value: selectedVendor?.id,
                hint: vendors.isEmpty
                    ? Text('no_vendors_available'.tr())
                    : Text('choose_vendor_from_list'.tr()),
                items: vendors.map((VendorModel vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor.id,
                    child: Text(vendor.name ?? ""),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    onVendorChanged(null);
                  } else {
                    final selected =
                    vendors.firstWhere((c) => c.id == value);
                    onVendorChanged(selected);
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
                labelText: 'invoice_date'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat.yMd(context.locale.toString()).format(selectedDate),
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
