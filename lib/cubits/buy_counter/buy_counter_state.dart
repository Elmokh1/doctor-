
abstract class BuyCounterState {}

class BuyCounterInitial extends BuyCounterState {}

class BuyCounterLoading extends BuyCounterState {}

class BuyCounterLoaded extends BuyCounterState {
  final int counter;
  BuyCounterLoaded(this.counter);
}

class BuyCounterError extends BuyCounterState {
  final String message;
  BuyCounterError(this.message);
}
