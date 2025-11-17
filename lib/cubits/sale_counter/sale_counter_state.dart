
abstract class SaleCounterState {}

class SaleCounterInitial extends SaleCounterState {}

class SaleCounterLoading extends SaleCounterState {}

class SaleCounterLoaded extends SaleCounterState {
  final int counter;
  SaleCounterLoaded(this.counter);
}

class SaleCounterError extends SaleCounterState {
  final String message;
  SaleCounterError(this.message);
}
