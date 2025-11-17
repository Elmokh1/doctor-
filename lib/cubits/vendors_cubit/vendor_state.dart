import '../../data/model/customer_model.dart';
import '../../data/model/vendor_model.dart';

abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final List<VendorModel> vendors;
  VendorLoaded(this.vendors);
}

class VendorSuccess extends VendorState {}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
}
