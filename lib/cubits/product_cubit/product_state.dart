import '../../data/model/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductSuccess extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> sections;
  ProductLoaded(this.sections);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
