class InvoiceCounterModel {
  static const String collectionName = 'invoiceCounter';
  String? id;
  int? counter;

  InvoiceCounterModel({this.id, this.counter});

  InvoiceCounterModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], counter: data?['counter']);

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'counter': counter};
  }
}
