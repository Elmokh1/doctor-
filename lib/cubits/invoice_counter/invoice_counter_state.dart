
abstract class InvoiceCounterState {}

class InvoiceCounterInitial extends InvoiceCounterState {}

class InvoiceCounterLoading extends InvoiceCounterState {}

class InvoiceCounterLoaded extends InvoiceCounterState {
  final int counter;
  InvoiceCounterLoaded(this.counter);
}

class InvoiceCounterError extends InvoiceCounterState {
  final String message;
  InvoiceCounterError(this.message);
}
