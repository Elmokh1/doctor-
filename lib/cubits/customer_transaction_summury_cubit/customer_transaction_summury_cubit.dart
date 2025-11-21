import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/customer_transaction_summary_model.dart';
import '../../data/my_dataBase.dart';
import 'customer_transaction_summury_state.dart';

class CustomerTransactionSummaryCubit extends Cubit<CustomerTransactionSummaryState> {
  CustomerTransactionSummaryCubit() : super(CustomerTransactionSummaryInitial());

  void getTransactions(String customerId) {
    emit(CustomerTransactionSummaryLoading());
    MyDatabase.getCustomerTransactionsSummaryStream(customerId).listen(
          (snapshot) {
        final transactions = snapshot.docs.map((e) => e.data()).toList();
        emit(CustomerTransactionSummaryLoaded(transactions));
      },
      onError: (error) {
        emit(CustomerTransactionSummaryError("$errorحدث خطأ أثناء جلب الحركات "));
        print(error);
      },
    );
  }

  Future<void> addTransaction(CustomerTransactionSummaryModel transaction) async {
    emit(CustomerTransactionSummaryLoading());
    try {
      await MyDatabase.addCustomerTransactionSummary(transaction);
      emit(CustomerTransactionSummarySuccess());
      getTransactions(transaction.customerId!);
    } catch (e) {
      emit(CustomerTransactionSummaryError("حدث خطأ أثناء حفظ الحركة"));
    }
  }


  Future<void> updateTransaction(CustomerTransactionSummaryModel transaction) async {
    emit(CustomerTransactionSummaryLoading());
    try {
      await MyDatabase.updateCustomerTransactionSummary(transaction);
      emit(CustomerTransactionSummarySuccess());
      getTransactions(transaction.customerId!);
    } catch (e) {
      emit(CustomerTransactionSummaryError("حدث خطأ أثناء تحديث الحركة"));
    }
  }

  Future<void> deleteTransaction(CustomerTransactionSummaryModel transaction) async {
    emit(CustomerTransactionSummaryLoading());
    try {
      await MyDatabase.deleteCustomerTransactionSummary(transaction.id!);
      emit(CustomerTransactionSummarySuccess());
      getTransactions(transaction.customerId!);
    } catch (e) {
      emit(CustomerTransactionSummaryError(" حدث خطأ أثناء حذف الحركة"));
    }
  }
}