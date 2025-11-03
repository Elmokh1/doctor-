class ProductModel {
  static const String collectionName = 'products';
  String? id;
  String? productName;
  int? qun;
  double? buyPrice;
  double? salePrice;
  double? total;

  ProductModel({
    this.id,
    this.productName,
    this.qun,
    this.salePrice,
    this.buyPrice,
    this.total,
  });
  ProductModel.fromFireStore(Map<String, dynamic>? date)
      : this(
    id: date?["id"],
    productName: date?["productName"],
    qun: date?["qun"],
    salePrice: date?["salePrice"],
    buyPrice: date?["buyPrice"],
    total: date?["total"],
  );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "productName": productName,
      "qun": qun,
      "salePrice": salePrice,
      "buyPrice": buyPrice,
      "total": total,
    };
  }
}
