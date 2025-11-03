import 'package:el_doctor/cubits/product_cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/product_model.dart';
import '../../data/my_dataBase.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  Future<void> addProduct(
      String name,
      double buyPrice,
      int qun,
      double salePrice,
      double total,
      ) async {
    emit(ProductLoading());
    try {
      await MyDatabase.addProduct(
        ProductModel(
          productName: name,
          buyPrice: buyPrice,
          qun: qun,
          salePrice: salePrice,
          total: total,
        ),
      );
      emit(ProductSuccess());
    } catch (e) {
      emit(ProductError("حدث خطأ أثناء الحفظ"));
    }
  }

  Stream<List<ProductModel>> getProducts() {
    return MyDatabase.getProductsRealTimeUpdate().map(
          (snapshot) => snapshot.docs.map((e) => e.data()).toList(),
    );
  }

  Future<void> updateProductInfo({
    required String id,
    required String newName,
    required double newBuyPrice,
    required double newSalePrice,
  }) async {
    emit(ProductLoading());
    try {
      await MyDatabase.updateProductInfo(
        id: id,
        newName: newName,
        newBuyPrice: newBuyPrice,
        newSalePrice: newSalePrice,
      );
      emit(ProductSuccess());
    } catch (e) {
      emit(ProductError("حدث خطأ أثناء تعديل المنتج"));
    }
  }
}
