import 'package:el_doctor/cubits/vendor_bills_cubit/vendor_bills_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/all_invoice_for_customer.dart';
import '../../data/model/product_model.dart';
import '../../data/my_dataBase.dart';

class VendorBillCubit extends Cubit<VendorBillState> {
  VendorBillCubit() : super(VendorBillInitial());

  // إضافة فاتورة مورد جديدة – Auto ID من فايربيز
  Future<String> addVendorBill({
    required String vendorId,
    required String invoiceNum,
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
        invoiceNum: invoiceNum,
        customerId: vendorId,
        customerName: vendorName,
        invoiceType: invoiceType,
        items: items,
        totalBeforeDiscount: totalBeforeDiscount,
        totalAfterDiscount: totalAfterDiscount,
        discount: discount,
        debtBefore: debtBefore,
        debtAfter: debtAfter,
        dateTime: dateTime,
      );

      // 🔥 Auto ID
      final String firestoreId = await MyDatabase.addVendorBill(bill);

      emit(VendorBillSuccess());

      // تحديث القائمة
      getVendorBills(vendorId);

      return firestoreId;
    } catch (e) {
      emit(VendorBillError("حدث خطأ أثناء الحفظ: $e"));
      return Future.error(e);
    }
  }

  // تحميل كل فواتير المورد
  void getVendorBills(String vendorId) {
    emit(VendorBillLoading());
    MyDatabase.getVendorBillStream(vendorId).listen(
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
      final bills = await MyDatabase.getVendorBillById(id);
      emit(VendorBillLoaded(bills));
    } catch (e) {
      emit(VendorBillError("حدث خطأ أثناء جلب الفواتير: $e"));
    }
  }

  // استبدال فاتورة مورد (نفس replace بتاع العملاء)
  Future<void> replaceVendorBill({
    required CustomerInvoiceModel oldBill,
    required CustomerInvoiceModel newBill,
  }) async {
    emit(VendorBillLoading());
    try {
      // 1️⃣ حذف القديمة
      await MyDatabase.deleteVendorBill(oldBill.id!);

      // 2️⃣ الاحتفاظ بالثوابت
      newBill.debtBefore = oldBill.debtBefore;

      // 3️⃣ إضافة الجديدة وأخذ ID
      final newId = await MyDatabase.addVendorBill(newBill);
      newBill.id = newId;

      emit(VendorBillSuccess());

      // 4️⃣ تحديث القائمة
      getVendorBills(newBill.customerId!);

    } catch (e) {
      emit(VendorBillError("حدث خطأ أثناء استبدال الفاتورة: $e"));
    }
  }
}
