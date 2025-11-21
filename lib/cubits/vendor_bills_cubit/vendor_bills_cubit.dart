import 'package:el_doctor/cubits/vendor_bills_cubit/vendor_bills_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/all_invoice_for_customer.dart';
import '../../data/model/product_model.dart';
import '../../data/my_database.dart';

class VendorBillCubit extends Cubit<VendorBillState> {
  VendorBillCubit() : super(VendorBillInitial());

  // إضافة فاتورة مورد جديدة
  Future<void> addVendorBill({
    required String id,
    required String vendorId,
    required String vendorName,
    required String invoiceType,
    required List<ProductModel> items,
    required double totalBeforeDiscount,
    required double totalAfterDiscount,
    required double discount,
    required double debtBefore,
    required double debtAfter,
    required DateTime dateTime,
  }) async {
    emit(VendorBillLoading());
    try {
      final bill = CustomerInvoiceModel(
        id: id,
        customerId: vendorId, // reuse field for vendorId
        customerName: vendorName, // reuse field for vendorName
        invoiceType: invoiceType,
        items: items,
        totalBeforeDiscount: totalBeforeDiscount,
        totalAfterDiscount: totalAfterDiscount,
        discount: discount,
        debtBefore: debtBefore,
        debtAfter: debtAfter,
        dateTime: dateTime,
      );

      await MyDatabase.addVendorBill(bill, id);

      emit(VendorBillSuccess());
      getVendorBills(vendorId); // تحديث القائمة بعد الإضافة
    } catch (e) {
      emit(VendorBillError("حدث خطأ أثناء الحفظ: $e"));
    }
  }

  // تحميل كل فواتير المورد
  void getVendorBills(String vendorId) {
    emit(VendorBillLoading());
    MyDatabase.getVendorBillStream().listen(
          (snapshot) {
        final bills = snapshot.docs.map((e) => e.data()).toList();
        emit(VendorBillLoaded(bills));
      },
      onError: (error) {
        emit(VendorBillError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }
  Future<void> fetchBillsById(String id) async {
    emit(VendorBillLoading());
    try {
      final invoices = await MyDatabase.getVendorBillById(id);
      emit(VendorBillLoaded(invoices));
    } catch (e) {
      emit(VendorBillError("حدث خطأ أثناء جلب الفواتير: $e"));
    }
  }

}