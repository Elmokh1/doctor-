import '../../data/model/cash_box_model.dart';

abstract class CashBoxState {}

class CashBoxInitial extends CashBoxState {}

class CashBoxLoading extends CashBoxState {}

class CashBoxLoaded extends CashBoxState {
  final double cash;
  CashBoxLoaded(this.cash);
}

class CashBoxError extends CashBoxState {
  final String message;
  CashBoxError(this.message);
}
