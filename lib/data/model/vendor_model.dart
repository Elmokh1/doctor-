class VendorModel {
  static const String collectionName = 'vendors';
  String? id;
  String? name;
  double? openingBalance;

  VendorModel({this.id, this.name, this.openingBalance});

  VendorModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        name: data?['name'],
        openingBalance: data?['openingBalance'],
      );

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'name': name, 'openingBalance': openingBalance};
  }
}
