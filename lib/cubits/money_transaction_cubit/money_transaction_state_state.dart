import '../../data/model/money_transaction_model.dart';

abstract class MoneyTransactionState {}

class MoneyTransactionInitial extends MoneyTransactionState {}

class MoneyTransactionLoading extends MoneyTransactionState {}

class MoneyTransactionSuccess extends MoneyTransactionState {}

class MoneyTransactionLoaded extends MoneyTransactionState {
  final List<MoneyTransactionModel> transactions;
  MoneyTransactionLoaded(this.transactions);
}

class MoneyTransactionFiltered extends MoneyTransactionState {
  final List<MoneyTransactionModel> filteredTransactions;
  MoneyTransactionFiltered(this.filteredTransactions);
}

class MoneyTransactionError extends MoneyTransactionState {
  final String message;
  MoneyTransactionError(this.message);
}
