import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/customer_transaction_summary_model.dart';
import '../../data/my_dataBase.dart';

abstract class CustomerTransactionSummaryState {}

class CustomerTransactionSummaryInitial
    extends CustomerTransactionSummaryState {}

class CustomerTransactionSummaryLoading
    extends CustomerTransactionSummaryState {}

class CustomerTransactionSummaryLoaded extends CustomerTransactionSummaryState {
  final List<CustomerTransactionSummaryModel> transactions;

  CustomerTransactionSummaryLoaded(this.transactions);
}

class CustomerTransactionSummarySuccess
    extends CustomerTransactionSummaryState {}

class CustomerTransactionSummaryError extends CustomerTransactionSummaryState {
  final String message;

  CustomerTransactionSummaryError(this.message);
}
