import 'package:el_doctor/cubits/vendors_cubit/vendor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/vendor_model.dart';
import '../../data/my_dataBase.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorInitial());

  Future<void> addVendor(String name, double opiningBalance) async {
    emit(VendorLoading());
    try {
      await MyDatabase.addVendor(
        VendorModel(name: name, openingBalance: opiningBalance),
      );
      emit(VendorSuccess());
      getVendors();
    } catch (e) {
      emit(VendorError("حدث خطأ أثناء الحفظ"));
    }
  }

  void getVendors() {
    emit(VendorLoading());
    MyDatabase.getVendorsRealTimeUpdate().listen(
          (snapshot) {
        final sections = snapshot.docs.map((e) => e.data()).toList();
        emit(VendorLoaded(sections));
      },
      onError: (error) {
        emit(VendorError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }

  Future<void> updateVendorBalance({
    required String vendorId,
    required double newBalance,
  }) async {
    try {
      await MyDatabase.updateVendor(
        id: vendorId,
        newBalance: newBalance,
      );
      print("✅ تم تحديث رصيد العميل بنجاح");
      getVendors();
    } catch (e) {
      print("❌ خطأ أثناء تحديث رصيد العميل: $e");
      emit(VendorError("حدث خطأ أثناء تحديث الرصيد"));
    }
  }

}
