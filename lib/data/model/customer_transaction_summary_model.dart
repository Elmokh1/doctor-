class CustomerTransactionSummaryModel {
  static const String collectionName = 'CustomerTransactionsSummary';

  String? id; // رقم فريد للحركة
  String? customerId;
  String? customerName;
  String? transactionType; // sale / return / receivePayment
  String? invoiceId; // رقم الفاتورة أو العملية
  double? debtBefore;
  double? debtAfter;
  double? amount; // صافي العملية (صافي الفاتورة أو استلام)
  DateTime? dateTime;
  String? notes; // أي ملاحظات إضافية

  CustomerTransactionSummaryModel({
    this.id,
    this.customerId,
    this.customerName,
    this.transactionType,
    this.invoiceId,
    this.debtBefore,
    this.debtAfter,
    this.amount,
    this.dateTime,
    this.notes,
  });

  // إنشاء من بيانات Firestore
  CustomerTransactionSummaryModel.fromFireStore(Map<String, dynamic>? data)
      : this(
    id: data?['id'],
    customerId: data?['customerId'],
    customerName: data?['customerName'],
    transactionType: data?['transactionType'],
    invoiceId: data?['invoiceId'],
    debtBefore: data?['debtBefore']?.toDouble(),
    debtAfter: data?['debtAfter']?.toDouble(),
    amount: data?['amount']?.toDouble(),
    dateTime: data?['dateTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data!['dateTime'])
        : null,
    notes: data?['notes'],
  );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'transactionType': transactionType,
      'invoiceId': invoiceId,
      'debtBefore': debtBefore,
      'debtAfter': debtAfter,
      'amount': amount,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }
}
