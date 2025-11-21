import '../../data/model/proudct_transaction_model.dart';

abstract class ProductTransactionState {}

class ProductTransactionInitial extends ProductTransactionState {}

class ProductTransactionLoading extends ProductTransactionState {}

class ProductTransactionSuccess extends ProductTransactionState {}

class ProductTransactionError extends ProductTransactionState {
  final String message;
  ProductTransactionError(this.message);
}

class ProductTransactionLoaded extends ProductTransactionState {
  final List<ProductTransactionModel> transactions;
  ProductTransactionLoaded(this.transactions);
}
