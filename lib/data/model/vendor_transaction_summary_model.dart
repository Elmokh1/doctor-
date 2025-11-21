class VendorTransactionSummaryModel {
  static const String collectionName = 'VendorTransactionsSummary';

  String? id; // رقم فريد للحركة
  String? vendorId;
  String? vendorName;
  String? transactionType; // sale / return / receivePayment
  String? invoiceId; // رقم الفاتورة أو العملية
  double? debtBefore;
  double? debtAfter;
  double? amount; // صافي العملية (صافي الفاتورة أو استلام)
  DateTime? dateTime;
  String? notes; // أي ملاحظات إضافية

  VendorTransactionSummaryModel({
    this.id,
    this.vendorId,
    this.vendorName,
    this.transactionType,
    this.invoiceId,
    this.debtBefore,
    this.debtAfter,
    this.amount,
    this.dateTime,
    this.notes,
  });

  // إنشاء من بيانات Firestore
  VendorTransactionSummaryModel.fromFireStore(Map<String, dynamic>? data)
      : this(
    id: data?['id'],
    vendorId: data?['vendorId'],
    vendorName: data?['vendorName'],
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
      'vendorId': vendorId,
      'vendorName': vendorName,
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
