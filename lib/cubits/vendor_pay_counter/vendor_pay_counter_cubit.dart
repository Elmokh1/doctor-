import 'package:el_doctor/cubits/vendor_pay_counter/vendor_pay_counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/my_dataBase.dart';

class VendorPayCounterCubit extends Cubit<VendorPayCounterState> {
  VendorPayCounterCubit() : super(VendorPayCounterInitial());

  Future<int> getCounter() async {
    emit(VendorPayCounterLoading());
    try {
      final snapshot = await MyDatabase.getVendorPayCounterCollection().limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("العداد فاضي !");
        emit(VendorPayCounterLoaded(0));
        return 0;
      }
      final VendorPayCounterModel = snapshot.docs.first.data();
      print("عداد من Firestore: ${VendorPayCounterModel.counter}");
      emit(VendorPayCounterLoaded(VendorPayCounterModel.counter ?? 0));
      return VendorPayCounterModel.counter ?? 0;
    } catch (e, s) {
      print("خطأ في getCash: $e");
      print(s);
      emit(VendorPayCounterError("حدث خطأ أثناء جلب الرصيد"));
      return 0;
    }
  }


  Future<void> updateCounter() async {
    final currentCounter = (state is VendorPayCounterLoaded) ? (state as VendorPayCounterLoaded).counter : 0;
    final newCounter =  currentCounter+1 ;

    await MyDatabase.updateVendorPayCounter(newCounter);

    emit(VendorPayCounterLoaded(newCounter));
  }

}
