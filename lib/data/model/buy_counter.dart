class BuyCounterModel {
  static const String collectionName = 'BuyCounter';
  String? id;
  int? counter;

  BuyCounterModel({this.id, this.counter});

  BuyCounterModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], counter: data?['counter']);

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'counter': counter};
  }
}
