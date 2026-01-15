import 'package:el_doctor/cubits/vendors_cubit/vendor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/vendor_model.dart';
import '../../data/my_dataBase.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorInitial());

  /// إضافة مورد جديد
  Future<void> addVendor(String name, double openingBalance) async {
    emit(VendorLoading());
    try {
      await MyDatabase.addVendor(
        VendorModel(name: name, openingBalance: openingBalance),
      );
      emit(VendorSuccess());
      getVendors(); // إعادة تحميل القائمة
    } catch (e) {
      emit(VendorError("حدث خطأ أثناء الحفظ"));
    }
  }

  /// جلب جميع الموردين بشكل لحظي
  void getVendors() {
    emit(VendorLoading());
    MyDatabase.getVendorsRealTimeUpdate().listen(
          (snapshot) {
        final vendors = snapshot.docs.map((e) => e.data()).toList();
        emit(VendorLoaded(vendors));
      },
      onError: (error) {
        emit(VendorError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }

  /// تحديث رصيد المورد
  Future<void> updateVendorBalance({
    required String vendorId,
    required double newBalance,
  }) async {
    try {
      await MyDatabase.updateVendor(
        id: vendorId,
        newBalance: newBalance,
      );
      print("✅ تم تحديث رصيد المورد بنجاح");
      getVendors(); // إعادة تحميل القائمة بعد التحديث
    } catch (e) {
      print("❌ خطأ أثناء تحديث رصيد المورد: $e");
      emit(VendorError("حدث خطأ أثناء تحديث الرصيد"));
    }
  }

  /// جلب مورد محدد حسب الـ ID من الكيوبت
  /// جلب مورد محدد حسب الـ ID من الكيوبت
  VendorModel? getVendorById(String vendorId) {
    if (state is VendorLoaded) {
      final vendors = (state as VendorLoaded).vendors;
      try {
        return vendors.firstWhere((v) => v.id == vendorId);
      } catch (e) {
        // لو المورد مش موجود، نرجع null
        return null;
      }
    }
    return null;
  }
}
