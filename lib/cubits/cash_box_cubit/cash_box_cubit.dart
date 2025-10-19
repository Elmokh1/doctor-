import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/my_dataBase.dart';
import 'cash_box_state.dart';

class CashBoxCubit extends Cubit<CashBoxState> {
  CashBoxCubit() : super(CashBoxInitial());

  // جلب الرصيد الحالي
  Future<double> getCash() async {
    emit(CashBoxLoading());
    try {
      final snapshot = await MyDatabase.getCashBoxCollection().limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("الخزنة فاضية!");
        emit(CashBoxLoaded(0.0));
        return 0.0;
      }
      final cashModel = snapshot.docs.first.data();
      print("رصيد الخزنة من Firestore: ${cashModel.cash}");
      emit(CashBoxLoaded(cashModel.cash ?? 0.0));
      return cashModel.cash ?? 0.0;
    } catch (e, s) {
      print("خطأ في getCash: $e");
      print(s);
      emit(CashBoxError("حدث خطأ أثناء جلب الرصيد"));
      return 0.0;
    }
  }


  // تحديث الرصيد بعد أي حركة مالية
  Future<void> updateCash(double amount, {bool isIncome = true}) async {
    final currentCash = (state is CashBoxLoaded) ? (state as CashBoxLoaded).cash : 0.0;
    final newCash = isIncome ? currentCash + amount : currentCash - amount;

    await MyDatabase.updateCash(newCash);

    // حدث الـ state فورًا عشان الـ UI يتغير
    emit(CashBoxLoaded(newCash));
  }

}
