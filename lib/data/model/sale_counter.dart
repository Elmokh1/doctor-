class SaleCounterModel {
  static const String collectionName = 'SaleCounter';
  String? id;
  int? counter;

  SaleCounterModel({this.id, this.counter});

  SaleCounterModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], counter: data?['counter']);

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'counter': counter};
  }
}
