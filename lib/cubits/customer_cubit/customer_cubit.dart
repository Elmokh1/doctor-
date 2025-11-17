import 'package:el_doctor/cubits/customer_cubit/customer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/customer_model.dart';
import '../../data/my_dataBase.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(CustomerInitial());

  Future<void> addCustomer(String name, double opiningBalance) async {
    emit(CustomerLoading());
    try {
      await MyDatabase.addCustomer(
        CustomerModel(name: name, openingBalance: opiningBalance),
      );
      emit(CustomerSuccess());
      getCustomers();
    } catch (e) {
      emit(CustomerError("حدث خطأ أثناء الحفظ"));
    }
  }

  void getCustomers() {
    emit(CustomerLoading());
    MyDatabase.getCustomersRealTimeUpdate().listen(
          (snapshot) {
        final sections = snapshot.docs.map((e) => e.data()).toList();
        emit(CustomerLoaded(sections));
      },
      onError: (error) {
        emit(CustomerError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }

  Future<void> updateCustomerBalance({
    required String customerId,
    required double newBalance,
  }) async {
    try {
      await MyDatabase.updateCustomer(
        id: customerId,
        newBalance: newBalance,
      );
      print("✅ تم تحديث رصيد العميل بنجاح");
      getCustomers();
    } catch (e) {
      print("❌ خطأ أثناء تحديث رصيد العميل: $e");
      emit(CustomerError("حدث خطأ أثناء تحديث الرصيد"));
    }
  }

}
