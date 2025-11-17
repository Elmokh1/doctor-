import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/receive_payment.dart';
import '../../data/my_dataBase.dart';
import 'received_payment_invoice_state.dart';

class ReceivedPaymentInvoiceCubit extends Cubit<ReceivedPaymentInvoiceState> {
  ReceivedPaymentInvoiceCubit() : super(ReceivedPaymentInvoiceInitial());


  Future<void> addReceivedPaymentInvoice({
    required String id,
    required String customerName,
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
      await MyDatabase.addInvoice(
        ReceivePaymentModel(
          id: id,
          customerName: customerName,
          customerId: customerId,
          amount: amount,
          cashBoxBefore: cashBoxBefore,
          cashBoxAfter: cashBoxAfter,
          oldBalance: oldBalance,
          newBalance: newBalance,
          transactionDetails: transactionDetails,
          dateTime: transactionDate,
        ),
        customerId,
        id,
      );

      emit(ReceivedPaymentInvoiceSuccess());
    } catch (e) {
      print("❌ خطأ أثناء الحفظ: $e");
      emit(ReceivedPaymentInvoiceError("حدث خطأ أثناء الحفظ"));
    }
  }

  // ----------------------------
  // جلب فواتير العميل
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
}
