import 'dart:async';
import 'dart:ui';

import 'package:el_doctor/data/model/sections_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/money_transaction_model.dart';
import '../../data/my_dataBase.dart';
import 'money_transaction_state_state.dart';

class MoneyTransactionCubit extends Cubit<MoneyTransactionState> {
  MoneyTransactionCubit() : super(MoneyTransactionInitial());

  StreamSubscription? _transactionSubscription;

  Future<void> addMoneyTransaction(
    String name,
    SectionsModel section,
    bool isIncome,
    double amount,
    double cashBoxBefore,
    double cashBoxAfter,
    String transactionDetails,
    DateTime? transactionDate, {
    VoidCallback? onSuccess,
  }) async {
    emit(MoneyTransactionLoading());
    try {
      await MyDatabase.addTransaction(
        MoneyTransactionModel(
          amount: amount,
          isIncome: isIncome,
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

      if (onSuccess != null) onSuccess();
    } catch (e) {
      emit(MoneyTransactionError("حدث خطأ أثناء الحفظ"));
    }
  }

  Stream<List<MoneyTransactionModel>> getAllTransactionsStream() {
    return MyDatabase.getAllTransactionsStream().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<void> fetchTransactionsByDateRange(
    DateTime fromDate,
    DateTime toDate,
    bool isIncome,
  ) async {
    emit(MoneyTransactionLoading());

    await _transactionSubscription?.cancel();

    try {
      final stream = MyDatabase.getTransactionsByDateRange(
        fromDate: fromDate,
        toDate: toDate,
        isIncome: isIncome,
      );

      _transactionSubscription = stream.listen((snapshot) {
        final transactions = snapshot.docs
            .map((doc) => doc.data())
            .where((t) => t.isIncome == isIncome)
            .toList();

        emit(MoneyTransactionLoaded(transactions));
      });
    } catch (e) {
      emit(MoneyTransactionError("حدث خطأ أثناء جلب البيانات"));
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
