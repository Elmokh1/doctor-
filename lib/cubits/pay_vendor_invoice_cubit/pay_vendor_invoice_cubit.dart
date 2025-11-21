import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/pay_vendor.dart';
import '../../data/my_dataBase.dart';
import 'pay_vendor_invoice_state.dart';

class PayVendorInvoiceCubit extends Cubit<PayVendorInvoiceState> {
  PayVendorInvoiceCubit() : super(PayVendorInvoiceInitial());

  /// إضافة فاتورة مورد
  Future<void> addPayVendorInvoice({
    required String id,
    required String vendorName,
    required String vendorId,
    required double amount,
    required double cashBoxBefore,
    required double cashBoxAfter,
    required double oldBalance,
    required double newBalance,
    required String transactionDetails,
    required DateTime transactionDate,
  }) async {
    emit(PayVendorInvoiceLoading());
    try {
      await MyDatabase.addVendorInvoice(
        PayVendorModel(
          id: id,
          customerName: vendorName, // ممكن نسميه EntityName لو عايز توحيد
          customerId: vendorId,     // نفس الشيء
          amount: amount,
          cashBoxBefore: cashBoxBefore,
          cashBoxAfter: cashBoxAfter,
          oldBalance: oldBalance,
          newBalance: newBalance,
          transactionDetails: transactionDetails,
          dateTime: transactionDate,
        ),
        vendorId,
        id,
      );

      emit(PayVendorInvoiceSuccess());
    } catch (e) {
      print("❌ خطأ أثناء الحفظ: $e");
      emit(PayVendorInvoiceError("حدث خطأ أثناء الحفظ"));
    }
  }

  /// تحميل فواتير مورد
  Future<void> loadInvoices(String vendorId) async {
    emit(PayVendorInvoiceLoading());
    try {
      final invoices = await MyDatabase.getVendorInvoices(vendorId);
      emit(PayVendorInvoiceLoaded(invoices));
    } catch (e) {
      print("❌ خطأ أثناء تحميل الفواتير: $e");
      emit(PayVendorInvoiceError("حدث خطأ أثناء تحميل الفواتير"));
    }
  }
  Future<void> fetchPaymentById(String vendorId,String id) async {
    emit(PayVendorInvoiceLoading());
    try {
      final invoices = await MyDatabase.getVendorPaymentById(vendorId,id);
      emit(PayVendorInvoiceLoaded(invoices));
    } catch (e) {
      emit(PayVendorInvoiceError("حدث خطأ أثناء جلب الفواتير: $e"));
    }
  }

}
