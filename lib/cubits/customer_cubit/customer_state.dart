// money_transaction_state_state.dart

import '../../data/model/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerSuccess extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> sections;
  CustomerLoaded(this.sections);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
