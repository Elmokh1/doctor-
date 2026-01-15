import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/proudct_transaction_model.dart';
import '../../data/my_dataBase.dart';
import 'product_transaction_state.dart';

class ProductTransactionCubit extends Cubit<ProductTransactionState> {
  ProductTransactionCubit() : super(ProductTransactionInitial());

  // --------------------------------------
  //  Add Transaction
  // --------------------------------------
  Future<void> addTransaction({
    required String productId,
    required int qun,
    required String name,
    required String transactionType,
    required DateTime transactionDate,
    required String transactionNum,
    required bool isCustomer,
    required String transactionId,
  }) async {
    emit(ProductTransactionLoading());

    try {
      await MyDatabase.addProductTransaction(
        productId,
        ProductTransactionModel(
          qun: qun,
          name: name,
          transactionType: transactionType,
          transactionNum: transactionNum,
          transactionDate: transactionDate,
          isCustomer: isCustomer,
          invoiceId: transactionId,
        ),
      );

      emit(ProductTransactionSuccess());
    } catch (e) {
      emit(ProductTransactionError("حدث خطأ أثناء إضافة الحركة"));
    }
  }

  // --------------------------------------
  //  Load All Transactions (Realtime)
  // --------------------------------------
  void loadTransactions(String productId) {
    emit(ProductTransactionLoading());

    MyDatabase.getProductTransactionsStream(productId).listen(
          (snapshot) {
        final items = snapshot.docs.map((e) => e.data()).toList();
        emit(ProductTransactionLoaded(items));
      },
      onError: (error) {
        emit(ProductTransactionError("حدث خطأ أثناء جلب الحركات"));
      },
    );
  }

  // --------------------------------------
  //  Read Single Transaction
  // --------------------------------------
  Future<ProductTransactionModel?> readTransaction({
    required String productId,
    required String transactionId,
  }) async {
    try {
      return await MyDatabase.readProductTransaction(productId, transactionId);
    } catch (e) {
      emit(ProductTransactionError("تعذر قراءة الحركة"));
      return null;
    }
  }

  // --------------------------------------
  //  Delete
  // --------------------------------------
  Future<void> deleteTransaction({
    required String productId,
    required String transactionId,
  }) async {
    emit(ProductTransactionLoading());

    try {
      await MyDatabase.deleteProductTransaction(productId, transactionId);
      emit(ProductTransactionSuccess());
    } catch (e) {
      emit(ProductTransactionError("حدث خطأ أثناء حذف الحركة"));
    }
  }

  Future<void> updateTransaction({
    required String productId,
    required String oldInvoiceId, // الـ invoiceId القديم لتحديث الحركات المرتبطة به
    required int newQuantity,
    required DateTime newDate,
    required String newInvoiceId, // الـ invoiceId الجديد
  }) async {
    emit(ProductTransactionLoading());
    try {
      // تحديث الحركات المرتبطة بالـ invoiceId القديم
      await MyDatabase.updateProductTransactionByInvoiceId(
        productId: productId,
        oldInvoiceId: oldInvoiceId,
        newQuantity: newQuantity,
        newDate: newDate,
        newInvoiceId: newInvoiceId,
      );

      emit(ProductTransactionSuccess());

      // إزالة استدعاء loadTransactions لتجنب إعادة تحميل البيانات بعد التحديث، خاصة إذا كانت الصفحة مغلقة
      // loadTransactions(productId); // تم تعطيله لتجنب الخطأ "Cannot emit new states after calling close"
    } catch (e) {
      emit(ProductTransactionError("حدث خطأ أثناء تحديث الحركة"));
    }
  }
}

