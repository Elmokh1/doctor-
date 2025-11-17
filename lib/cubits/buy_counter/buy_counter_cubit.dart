import 'package:el_doctor/cubits/vendor_pay_counter/vendor_pay_counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/my_dataBase.dart';
import 'buy_counter_state.dart';

class BuyCounterCubit extends Cubit<BuyCounterState> {
  BuyCounterCubit() : super(BuyCounterInitial());

  Future<int> getCounter() async {
    emit(BuyCounterLoading());
    try {
      final snapshot = await MyDatabase.getBuyCounterCollection().limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("العداد فاضي !");
        emit(BuyCounterLoaded(0));
        return 0;
      }
      final BuyCounterModel = snapshot.docs.first.data();
      print("عداد من Firestore: ${BuyCounterModel.counter}");
      emit(BuyCounterLoaded(BuyCounterModel.counter ?? 0));
      return BuyCounterModel.counter ?? 0;
    } catch (e, s) {
      print("خطأ في getCash: $e");
      print(s);
      emit(BuyCounterError("حدث خطأ أثناء جلب الرصيد"));
      return 0;
    }
  }


  Future<void> updateCounter() async {
    final currentCounter = (state is BuyCounterLoaded) ? (state as BuyCounterLoaded).counter : 0;
    final newCounter =  currentCounter+1 ;

    await MyDatabase.updateBuyCounter(newCounter);

    emit(BuyCounterLoaded(newCounter));
  }

}
