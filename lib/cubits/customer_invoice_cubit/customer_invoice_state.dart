import '../../data/model/all_invoice_for_customer.dart';

abstract class CustomerInvoiceState {}

class CustomerInvoiceInitial extends CustomerInvoiceState {}

class CustomerInvoiceLoading extends CustomerInvoiceState {}

class CustomerInvoiceLoaded extends CustomerInvoiceState {
  final List<CustomerInvoiceModel> invoices;
  CustomerInvoiceLoaded(this.invoices);
}

class CustomerInvoiceSuccess extends CustomerInvoiceState {}

class CustomerInvoiceError extends CustomerInvoiceState {
  final String message;
  CustomerInvoiceError(this.message);
}

class CustomerInvoiceUpdated extends CustomerInvoiceState {}
