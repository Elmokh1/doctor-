import 'package:el_doctor/cubits/sale_counter/sale_counter_state.dart';
import 'package:el_doctor/cubits/vendor_pay_counter/vendor_pay_counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/my_dataBase.dart';

class SaleCounterCubit extends Cubit<SaleCounterState> {
  SaleCounterCubit() : super(SaleCounterInitial());

  Future<int> getCounter() async {
    emit(SaleCounterLoading());
    try {
      final snapshot = await MyDatabase.getSaleCounterCollection().limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("العداد فاضي !");
        emit(SaleCounterLoaded(0));
        return 0;
      }
      final SaleCounterModel = snapshot.docs.first.data();
      print("عداد من Firestore: ${SaleCounterModel.counter}");
      emit(SaleCounterLoaded(SaleCounterModel.counter ?? 0));
      return SaleCounterModel.counter ?? 0;
    } catch (e, s) {
      print("خطأ في getCash: $e");
      print(s);
      emit(SaleCounterError("حدث خطأ أثناء جلب الرصيد"));
      return 0;
    }
  }


  Future<void> updateCounter() async {
    final currentCounter = (state is SaleCounterLoaded) ? (state as SaleCounterLoaded).counter : 0;
    final newCounter =  currentCounter+1 ;

    await MyDatabase.updateSaleCounter(newCounter);

    emit(SaleCounterLoaded(newCounter));
  }

}
