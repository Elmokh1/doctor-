import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/customer_transaction_summary_model.dart';
import '../../data/model/vendor_transaction_summary_model.dart';
import '../../data/my_dataBase.dart';
import 'vendor_transaction_summury_state.dart';

class VendorTransactionSummaryCubit extends Cubit<VendorTransactionSummaryState> {
  VendorTransactionSummaryCubit() : super(VendorTransactionSummaryInitial());

  void getTransactions(String customerId) {
    emit(VendorTransactionSummaryLoading());
    MyDatabase.getVendorTransactionsSummaryStream(customerId).listen(
          (snapshot) {
        final transactions = snapshot.docs.map((e) => e.data()).toList();
        emit(VendorTransactionSummaryLoaded(transactions));
      },
      onError: (error) {
        emit(VendorTransactionSummaryError("حدث خطأ أثناء جلب الحركات"));
        print(error);
      },
    );
  }

  Future<void> addTransaction(VendorTransactionSummaryModel transaction) async {
    emit(VendorTransactionSummaryLoading());
    try {
      await MyDatabase.addVendorTransactionSummary(transaction);
      emit(VendorTransactionSummarySuccess());
      getTransactions(transaction.vendorId!);
    } catch (e) {
      emit(VendorTransactionSummaryError("حدث خطأ أثناء حفظ الحركة"));
    }
  }


  Future<void> updateTransaction(VendorTransactionSummaryModel transaction) async {
    emit(VendorTransactionSummaryLoading());
    try {
      await MyDatabase.updateVendorTransactionSummary(transaction);
      emit(VendorTransactionSummarySuccess());
      getTransactions(transaction.vendorId!);
    } catch (e) {
      emit(VendorTransactionSummaryError("حدث خطأ أثناء تحديث الحركة"));
    }
  }

  Future<void> deleteTransaction(VendorTransactionSummaryModel transaction) async {
    emit(VendorTransactionSummaryLoading());
    try {
      await MyDatabase.deleteVendorTransactionSummary(transaction.id!);
      emit(VendorTransactionSummarySuccess());
      getTransactions(transaction.vendorId!);
    } catch (e) {
      emit(VendorTransactionSummaryError("حدث خطأ أثناء حذف الحركة"));
    }
  }
}