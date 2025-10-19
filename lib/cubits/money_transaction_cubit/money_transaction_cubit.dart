// money_transaction_cubit.dart

import 'dart:ui';

import 'package:el_doctor/data/model/sections_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/money_transaction_model.dart';
import '../../data/my_dataBase.dart';
import '../cash_box_cubit/cash_box_cubit.dart';
import 'money_transaction_state_state.dart';

class MoneyTransactionCubit extends Cubit<MoneyTransactionState> {
  MoneyTransactionCubit() : super(MoneyTransactionInitial());

  Future<void> addMoneyTransaction(
      String name,
      SectionsModel section,
      double amount,
      double cashBoxBefore,
      double cashBoxAfter,
      String transactionDetails,
      DateTime? transactionDate, {
        VoidCallback? onSuccess, // callback
      }) async {
    emit(MoneyTransactionLoading());
    try {
      await MyDatabase.addTransaction(
        MoneyTransactionModel(
          amount: amount,
          cashBoxBefore: cashBoxBefore,
          cashBoxAfter: cashBoxAfter,
          createdAt: DateTime.now(),
          transactionDate: transactionDate,
          transactionDetails: transactionDetails,
          transactionType: section.name,
        ),
        section.id!,
      );

      emit(MoneyTransactionSuccess());

      if (onSuccess != null) onSuccess(); // نفذ callback
    } catch (e) {
      emit(MoneyTransactionError("حدث خطأ أثناء الحفظ"));
    }
  }


  Stream<List<MoneyTransactionModel>> getAllTransactionsStream() {
    return MyDatabase.getAllTransactionsStream().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

}
