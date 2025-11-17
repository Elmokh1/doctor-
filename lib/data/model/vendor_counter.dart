class VendorPayCounterModel {
  static const String collectionName = 'vendorPayCounter';
  String? id;
  int? counter;

  VendorPayCounterModel({this.id, this.counter});

  VendorPayCounterModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], counter: data?['counter']);

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'counter': counter};
  }
}
