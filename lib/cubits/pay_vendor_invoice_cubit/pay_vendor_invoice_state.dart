import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/receive_payment.dart';

import '../../data/model/money_transaction_model.dart';

abstract class PayVendorInvoiceState {}

class PayVendorInvoiceInitial extends PayVendorInvoiceState {}

class PayVendorInvoiceLoading extends PayVendorInvoiceState {}

class PayVendorInvoiceSuccess extends PayVendorInvoiceState {}

class PayVendorInvoiceLoaded extends PayVendorInvoiceState {
  final List<PayVendorModel> transactions;
  PayVendorInvoiceLoaded(this.transactions);
}

class PayVendorInvoiceFiltered extends PayVendorInvoiceState {
  final List<PayVendorModel> filteredTransactions;
  PayVendorInvoiceFiltered(this.filteredTransactions);
}

class PayVendorInvoiceError extends PayVendorInvoiceState {
  final String message;
  PayVendorInvoiceError(this.message);
}
