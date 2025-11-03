import 'package:el_doctor/cubits/customer_cubit/customer_cubit.dart';
import 'package:el_doctor/cubits/product_cubit/product_cubit.dart';
import 'package:el_doctor/ui/transactions_list_page/transactions_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'cubits/cash_box_cubit/cash_box_cubit.dart';
import 'cubits/money_transaction_cubit/money_transaction_cubit.dart';
import 'cubits/section_cubit/section_cubit.dart';
import 'cubits/vendors_cubit/vendor_cubit.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ui/home_screen/Home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar', null); // تهيئة اللغة العربية

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const AccountingApp());
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
      ],

      child: MaterialApp(
        title: 'نظام الحسابات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        ),
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          TransactionsListPage.routeName: (context) => TransactionsListPage(isIncome: false,),
        },
      ),
    );
  }
}
