import 'package:el_doctor/ui/vendors/vendors_details/vendor_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import '../../../cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_state.dart';
import '../../../data/model/vendor_model.dart';
import '../../customer/customer_details/invoice_details_card.dart';

class PayVendorInvoiceView extends StatelessWidget {
  final VendorModel vendor;

  const PayVendorInvoiceView({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocBuilder<PayVendorInvoiceCubit, PayVendorInvoiceState>(
      builder: (context, state) {
        if (state is PayVendorInvoiceLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is PayVendorInvoiceError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        } else if (state is PayVendorInvoiceLoaded) {
          final invoices = state.transactions;

          if (invoices.isEmpty) {
            return Scaffold(
              body: Center(child: Text("لا توجد فواتير لهذا المورد")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("فواتير المورد: ${vendor.name}"),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                width: 900,
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "فاتورة رقم: ${invoice.id}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "المبلغ: ${invoice.amount?.toStringAsFixed(2) ?? "0"} جنيه",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "التاريخ: ${invoice.dateTime != null ? dateFormat.format(invoice.dateTime!) : "--"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VendorDetailsCard(invoice: invoice),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("عرض التفاصيل"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
