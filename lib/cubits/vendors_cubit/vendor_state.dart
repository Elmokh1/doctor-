// money_transaction_state_state.dart
import '../../data/model/sections_model.dart';
import '../../data/model/vendor_model.dart';

abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorSuccess extends VendorState {}

class VendorLoaded extends VendorState {
  final List<VendorModel> sections;
  VendorLoaded(this.sections);
}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
}
