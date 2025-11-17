class PayVendorModel {
  static const String collectionName = 'PayVendor';
  String? id;
  String? customerName;
  String? customerId;
  String? transactionDetails;
  double? oldBalance;
  double? newBalance;
  double? cashBoxBefore;
  double? cashBoxAfter;
  double? amount;
  DateTime? dateTime;

  PayVendorModel({
    this.id,
    this.customerName,
    this.customerId,
    this.dateTime,
    this.amount,
    this.transactionDetails,
    this.oldBalance,
    this.cashBoxAfter,
    this.cashBoxBefore,
    this.newBalance,
  });

  PayVendorModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        customerName: data?['customerName'],
        customerId: data?['customerId'],
        amount: data?['amount'],
        transactionDetails: data?['transactionDetails'],
        oldBalance: data?['oldBalance'],
        newBalance: data?['newBalance'],
        cashBoxBefore: data?['cashBoxBefore'],
        cashBoxAfter: data?['cashBoxAfter'],
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
      "oldBalance": oldBalance,
      "newBalance": newBalance,
      "cashBoxBefore": cashBoxBefore,
      "cashBoxAfter": cashBoxAfter,
      "transactionDetails": transactionDetails,
      "dateTime": dateTime?.millisecondsSinceEpoch,
    };
  }
}
