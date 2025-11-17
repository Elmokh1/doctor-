import 'package:el_doctor/ui/invoice/invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/customer_cubit/customer_cubit.dart';
import '../../../cubits/customer_cubit/customer_state.dart';
import '../../../data/model/customer_model.dart';
import '../../../utils/universal_list_screen.dart';
import 'customer_details/receive_payment_Invoice_view.dart'; // المفروض عندك الملف ده جاهز

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomerCubit>();
    cubit.getCustomers();

    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CustomerError) {
          return Scaffold(body: Center(child: Text(state.message)));
        } else if (state is CustomerLoaded) {
          final customers = state.customers;

          return UniversalListScreen<CustomerModel>(
            title: "قائمة العملاء",
            items: customers,
            getName: (c) => c.name ?? "-",
            getBalance: (c) => c.openingBalance ?? 0.0,
            onTap: (c) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceivePaymentInvoiceView(customer: c),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم الضغط على ${c.name ?? "-"}")),
              );
            },
          );
        }

        return const Scaffold(
          body: Center(child: Text("حدث خطأ أثناء تحميل البيانات")),
        );
      },
    );
  }
}
