import 'package:el_doctor/ui/vendors/vendors_details/vendor_payment_Invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import '../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_state.dart';
import '../../cubits/vendors_cubit/vendor_cubit.dart';
import '../../cubits/vendors_cubit/vendor_state.dart';
import '../../data/model/vendor_model.dart';
import '../../utils/universal_list_screen.dart';

class VendorsScreen extends StatelessWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorCubit = context.read<VendorCubit>();
    vendorCubit.getVendors();

    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VendorError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }

        if (state is VendorLoaded) {
          final vendors = state.vendors;

          if (vendors.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text(
                  "no_vendors".tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          return UniversalListScreen<VendorModel>(
            title: "vendors_list".tr(),
            items: vendors,
            getName: (v) => v.name ?? "-",
            getBalance: (v) => v.openingBalance ?? 0.0,
            onTap: (vendor) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VendorTransactionSummaryView(vendor: vendor),
                ),
              );
            },
          );
        }

        // Default fallback
        return Scaffold(
          body: Center(
            child: Text("load_error".tr()),
          ),
        );
      },
    );
  }
}
