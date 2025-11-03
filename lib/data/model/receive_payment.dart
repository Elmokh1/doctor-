class ReceivePayment {
  static const String collectionName = 'ReceivePayment';
  String? id;
  String? customerName;
  String? customerId;
  double? amount;
  DateTime? dateTime;

  ReceivePayment({this.id, this.customerName, this.customerId, this.dateTime,this.amount});

  ReceivePayment.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        customerName: data?['customerName'],
        customerId: data?['customerId'],
        amount: data?['amount'],
        dateTime: data?["dateTime"] != null
            ? DateTime.fromMillisecondsSinceEpoch(data?["dateTime"])
            : null,
      );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'customerName': customerName,
      "customerId": customerId,
      "amount": amount,
      "dateTime": dateTime?.millisecondsSinceEpoch,
    };
  }
}
