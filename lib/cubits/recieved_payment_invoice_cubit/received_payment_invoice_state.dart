import 'package:el_doctor/data/model/receive_payment.dart';

import '../../data/model/money_transaction_model.dart';

abstract class ReceivedPaymentInvoiceState {}

class ReceivedPaymentInvoiceInitial extends ReceivedPaymentInvoiceState {}

class ReceivedPaymentInvoiceLoading extends ReceivedPaymentInvoiceState {}

class ReceivedPaymentInvoiceSuccess extends ReceivedPaymentInvoiceState {}

class ReceivedPaymentInvoiceLoaded extends ReceivedPaymentInvoiceState {
  final List<ReceivePaymentModel> transactions;
  ReceivedPaymentInvoiceLoaded(this.transactions);
}

class ReceivedPaymentInvoiceFiltered extends ReceivedPaymentInvoiceState {
  final List<ReceivePaymentModel> filteredTransactions;
  ReceivedPaymentInvoiceFiltered(this.filteredTransactions);
}

class ReceivedPaymentInvoiceError extends ReceivedPaymentInvoiceState {
  final String message;
  ReceivedPaymentInvoiceError(this.message);
}
