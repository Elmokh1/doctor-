import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';

// Cubits
import 'cubits/section_cubit/section_cubit.dart';
import 'cubits/money_transaction_cubit/money_transaction_cubit.dart';
import 'cubits/cash_box_cubit/cash_box_cubit.dart';
import 'cubits/product_cubit/product__cubit.dart';
import 'cubits/customer_cubit/customer_cubit.dart';
import 'cubits/vendors_cubit/vendor_cubit.dart';
import 'cubits/recieved_payment_invoice_cubit/received_payment_invoice_cubit.dart';
import 'cubits/pay_vendor_invoice_cubit/pay_vendor_invoice_cubit.dart';
import 'cubits/invoice_counter/invoice_counter_cubit.dart';
import 'cubits/vendor_pay_counter/vendor_pay_counter_cubit.dart';
import 'cubits/customer_invoice_cubit/customer_invoice_cubit.dart';
import 'cubits/sale_counter/sale_counter_cubit.dart';
import 'cubits/customer_transaction_summury_cubit/customer_transaction_summury_cubit.dart';
import 'cubits/vendor_transaction_summury_cubit/vendor_transaction_summury_cubit.dart';
import 'cubits/vendor_bills_cubit/vendor_bills_cubit.dart';
import 'cubits/buy_counter/buy_counter_cubit.dart';
import 'cubits/product_tranaction_cubit/product_transaction_cubit.dart';

// UI
import 'ui/home_screen/Home_screen.dart';
import 'ui/transactions_list_page/transactions_list_page.dart';

// Firebase
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('ar', null); // تهيئة التاريخ العربي

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations', // فولدر ملفات JSON
      fallbackLocale: const Locale('en'),
      child: const AccountingApp(),
    ),
  );
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SectionCubit()),
        BlocProvider(create: (_) => MoneyTransactionCubit()),
        BlocProvider(create: (_) => CashBoxCubit()..getCash()),
        BlocProvider(create: (_) => ProductCubit()),
        BlocProvider(create: (_) => CustomerCubit()),
        BlocProvider(create: (_) => VendorCubit()),
        BlocProvider(create: (_) => ReceivedPaymentInvoiceCubit()),
        BlocProvider(create: (_) => PayVendorInvoiceCubit()),
        BlocProvider(create: (_) => InvoiceCounterCubit()),
        BlocProvider(create: (_) => VendorPayCounterCubit()),
        BlocProvider(create: (_) => CustomerInvoicesCubit()),
        BlocProvider(create: (_) => SaleCounterCubit()),
        BlocProvider(create: (_) => CustomerTransactionSummaryCubit()),
        BlocProvider(create: (_) => VendorTransactionSummaryCubit()),
        BlocProvider(create: (_) => VendorBillCubit()),
        BlocProvider(create: (_) => BuyCounterCubit()),
        BlocProvider(create: (_) => ProductTransactionCubit()),
      ],
      child: MaterialApp(
        title: 'نظام الحسابات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        ),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          TransactionsListPage.routeName: (context) =>
              TransactionsListPage(isIncome: false),
        },
      ),
    );
  }
}
