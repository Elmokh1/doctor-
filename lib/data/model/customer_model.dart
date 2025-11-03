class CustomerModel {
  static const String collectionName = 'customers';
  String? id;
  String? name;
  double? openingBalance;

  CustomerModel({this.id, this.name, this.openingBalance});

  CustomerModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        name: data?['name'],
        openingBalance: data?['openingBalance'],
      );

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'name': name, 'openingBalance': openingBalance};
  }
}
