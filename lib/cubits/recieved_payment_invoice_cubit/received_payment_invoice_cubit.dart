import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/receive_payment.dart';
import '../../data/my_dataBase.dart';
import '../recieved_payment_invoice_cubit/received_payment_invoice_state.dart';

class ReceivedPaymentInvoiceCubit extends Cubit<ReceivedPaymentInvoiceState> {
  ReceivedPaymentInvoiceCubit() : super(ReceivedPaymentInvoiceInitial());

  // إضافة فاتورة تحصيل واسترجاع الـ ID اللي اتولد
  Future<String> addReceivedPaymentInvoice({
    required String customerName,
    required String invoiceNum,
    required String customerId,
    required double amount,
    required double cashBoxBefore,
    required double cashBoxAfter,
    required double oldBalance,
    required double newBalance,
    required String transactionDetails,
    required DateTime transactionDate,
  }) async {
    emit(ReceivedPaymentInvoiceLoading());
    try {
      final receivePayment = ReceivePaymentModel(
        invoiceNum: invoiceNum,
        customerName: customerName,
        customerId: customerId,
        amount: amount,
        cashBoxBefore: cashBoxBefore,
        cashBoxAfter: cashBoxAfter,
        oldBalance: oldBalance,
        newBalance: newBalance,
        transactionDetails: transactionDetails,
        dateTime: transactionDate,
      );

      // 🔥 خزننا الـ ID وجبناه
      final String firestoreId = await MyDatabase.addInvoice(receivePayment, customerId);

      emit(ReceivedPaymentInvoiceSuccess());

      // رجعنا الـ ID عشان ممكن نستخدمه في أي مكان
      return firestoreId;
    } catch (e) {
      print("❌ خطأ أثناء الحفظ: $e");
      emit(ReceivedPaymentInvoiceError("حدث خطأ أثناء الحفظ"));
      return Future.error(e);
    }
  }

  // ----------------------------
  // جلب كل فواتير العميل
  // ----------------------------
  Future<void> loadInvoices(String customerId) async {
    emit(ReceivedPaymentInvoiceLoading());
    try {
      final invoices = await MyDatabase.getCustomerInvoices(customerId);
      emit(ReceivedPaymentInvoiceLoaded(invoices));
    } catch (e) {
      print("❌ خطأ أثناء تحميل الفواتير: $e");
      emit(ReceivedPaymentInvoiceError("حدث خطأ أثناء تحميل الفواتير"));
    }
  }

  Future<void> fetchReceivedPaymentById(String customerId, String id) async {
    emit(ReceivedPaymentInvoiceLoading());
    try {
      final invoices = await MyDatabase.getCustomerPaymentByInvoiceNum(customerId, id);
      emit(ReceivedPaymentInvoiceLoaded(invoices));
    } catch (e) {
      emit(ReceivedPaymentInvoiceError("حدث خطأ أثناء جلب الفواتير: $e"));
    }
  }

  Future<void> updateReceivedPaymentInvoice({
    required String customerId,
    required ReceivePaymentModel payment,
  }) async {
    emit(ReceivedPaymentInvoiceLoading());
    try {
      await MyDatabase.updateReceivedPayment(
        customerId: customerId,
        payment: payment,
      );

      // نرجّع نفس الفاتورة بعد التعديل عشان الـ UI يتحدث
      final invoices = await MyDatabase.getCustomerPaymentByInvoiceNum(
        customerId,
        payment.invoiceNum!, // هنا الصح invoiceNum مش paymentId
      );

      emit(ReceivedPaymentInvoiceLoaded(invoices));
    } catch (e) {
      print("❌ خطأ أثناء التعديل: $e");
      emit(ReceivedPaymentInvoiceError("حدث خطأ أثناء تعديل الفاتورة"));
    }
  }


}
