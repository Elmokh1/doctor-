import '../../data/model/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  CustomerLoaded(this.customers);
}

class CustomerSuccess extends CustomerState {}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
