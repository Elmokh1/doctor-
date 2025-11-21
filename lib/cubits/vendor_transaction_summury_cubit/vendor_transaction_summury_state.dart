import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/customer_transaction_summary_model.dart';
import '../../data/model/vendor_transaction_summary_model.dart';
import '../../data/my_dataBase.dart';

abstract class VendorTransactionSummaryState {}

class VendorTransactionSummaryInitial
    extends VendorTransactionSummaryState {}

class VendorTransactionSummaryLoading
    extends VendorTransactionSummaryState {}

class VendorTransactionSummaryLoaded extends VendorTransactionSummaryState {
  final List<VendorTransactionSummaryModel> transactions;

  VendorTransactionSummaryLoaded(this.transactions);
}

class VendorTransactionSummarySuccess
    extends VendorTransactionSummaryState {}

class VendorTransactionSummaryError extends VendorTransactionSummaryState {
  final String message;

  VendorTransactionSummaryError(this.message);
}
