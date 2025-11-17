import 'package:flutter_bloc/flutter_bloc.dart';

class SaleInvoiceCubit extends Cubit<List<Map<String, dynamic>>> {
  SaleInvoiceCubit() : super([]);

  void addItem(Map<String, dynamic> item) => emit([...state, item]);

  void removeItem(int index) {
    final newList = List<Map<String, dynamic>>.from(state);
    newList.removeAt(index);
    emit(newList);
  }

  void clearItems() => emit([]);
}
