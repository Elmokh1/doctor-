// vendor_bill_state.dart
import '../../data/model/all_invoice_for_customer.dart';

abstract class VendorBillState {}

class VendorBillInitial extends VendorBillState {}

class VendorBillLoading extends VendorBillState {}

class VendorBillLoaded extends VendorBillState {
  final List<CustomerInvoiceModel> bills;
  VendorBillLoaded(this.bills);
}

class VendorBillSuccess extends VendorBillState {}

class VendorBillError extends VendorBillState {
  final String message;
  VendorBillError(this.message);
}

class VendorBillUpdated extends VendorBillState {}
