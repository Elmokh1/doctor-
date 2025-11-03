class PayVendorModel {
  static const String collectionName = 'pay_vendors';
  String? id;
  String? vendorName;
  String? vendorId;
  double? amount;
  DateTime? dateTime;

  PayVendorModel({this.id, this.vendorName, this.vendorId, this.dateTime,this.amount});

  PayVendorModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        vendorName: data?['vendorName'],
        vendorId: data?['vendorId'],
        amount: data?['amount'],
        dateTime: data?["dateTime"] != null
            ? DateTime.fromMillisecondsSinceEpoch(data?["dateTime"])
            : null,
      );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'vendorName': vendorName,
      "vendorId": vendorId,
      "amount": amount,
      "dateTime": dateTime?.millisecondsSinceEpoch,
    };
  }
}
