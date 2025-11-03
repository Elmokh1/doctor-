class MoneyTransactionModel {
  static const String collectionName = 'MoneyTransaction';

  String? id;
  double? amount;
  bool? isIncome;
  double? cashBoxBefore;
  double? cashBoxAfter;
  DateTime? transactionDate;
  DateTime? createdAt;
  String? transactionType;
  String? transactionDetails;

  MoneyTransactionModel({
    this.id,
    this.amount,
    this.isIncome,
    this.cashBoxBefore,
    this.cashBoxAfter,
    this.transactionDate,
    this.createdAt,
    this.transactionType,
    this.transactionDetails,
  });

  MoneyTransactionModel.fromFireStore(Map<String, dynamic>? data)
      : this(
    id: data?['id'],
    amount: (data?['amount'] as num?)?.toDouble(),
    cashBoxBefore: (data?['cashBoxBefore'] as num?)?.toDouble(),
    cashBoxAfter: (data?['cashBoxAfter'] as num?)?.toDouble(),
    transactionType: data?['transactionType'],
    isIncome: data?['isIncome'],
    transactionDetails: data?['transactionDetails'],
    transactionDate: data?["transactionDate"] != null
        ? DateTime.fromMillisecondsSinceEpoch(data?["transactionDate"])
        : null,
    createdAt: data?["createdAt"] != null
        ? DateTime.fromMillisecondsSinceEpoch(data?["createdAt"])
        : null,
  );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'amount': amount,
      'isIncome': isIncome,
      'cashBoxBefore': cashBoxBefore,
      'cashBoxAfter': cashBoxAfter,
      'transactionType': transactionType,
      'transactionDetails': transactionDetails,
      "transactionDate": transactionDate?.millisecondsSinceEpoch,
      "createdAt": createdAt?.millisecondsSinceEpoch,
    };
  }
}
