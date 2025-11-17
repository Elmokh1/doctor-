
abstract class VendorPayCounterState {}

class VendorPayCounterInitial extends VendorPayCounterState {}

class VendorPayCounterLoading extends VendorPayCounterState {}

class VendorPayCounterLoaded extends VendorPayCounterState {
  final int counter;
  VendorPayCounterLoaded(this.counter);
}

class VendorPayCounterError extends VendorPayCounterState {
  final String message;
  VendorPayCounterError(this.message);
}
