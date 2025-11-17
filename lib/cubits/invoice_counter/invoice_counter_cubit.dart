import 'package:el_doctor/cubits/vendor_pay_counter/vendor_pay_counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/my_dataBase.dart';
import 'invoice_counter_state.dart';

class InvoiceCounterCubit extends Cubit<InvoiceCounterState> {
  InvoiceCounterCubit() : super(InvoiceCounterInitial());

  Future<int> getCounter() async {
    emit(InvoiceCounterLoading());
    try {
      final snapshot = await MyDatabase.getInvoiceCounterCollection().limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("العداد فاضي !");
        emit(InvoiceCounterLoaded(0));
        return 0;
      }
      final InvoiceCounterModel = snapshot.docs.first.data();
      print("عداد من Firestore: ${InvoiceCounterModel.counter}");
      emit(InvoiceCounterLoaded(InvoiceCounterModel.counter ?? 0));
      return InvoiceCounterModel.counter ?? 0;
    } catch (e, s) {
      print("خطأ في getCounter: $e");
      print(s);
      emit(InvoiceCounterError("حدث خطأ أثناء جلب الرصيد"));
      return 0;
    }
  }


  Future<void> updateCounter() async {
    final currentCounter = (state is InvoiceCounterLoaded) ? (state as InvoiceCounterLoaded).counter : 0;
    final newCounter =  currentCounter+1 ;

    await MyDatabase.updateInvoiceCounter(newCounter);

    emit(InvoiceCounterLoaded(newCounter));
  }

}
