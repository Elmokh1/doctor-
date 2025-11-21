import 'package:firebase_auth/firebase_auth.dart';

class ProductTransactionModel {
  static const String collectionName = 'ProductTransaction';
  String? id;
  int? qun;
  String? name;
  String? transactionType;
  String? transactionNum;
  bool? isCustomer;
  DateTime? transactionDate;

  ProductTransactionModel({
    this.id,
    this.qun,
    this.transactionType,
    this.name,
    this.transactionNum,
    this.isCustomer,
    this.transactionDate,
  });

  ProductTransactionModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        qun: (data?['qun'] ?? 0).toInt(),
        transactionType: data?['transactionType'],
        name: data?['name'],
        transactionNum: data?['transactionNum'],
        isCustomer: data?['isCustomer'],
    transactionDate: data?["transactionDate"] != null
        ? DateTime.fromMillisecondsSinceEpoch(data?["transactionDate"])
        : null,

      );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'qun': qun,
      'transactionType': transactionType,
      'name': name,
      'transactionNum': transactionNum,
      'isCustomer': isCustomer,
      "transactionDate": transactionDate?.millisecondsSinceEpoch,

    };
  }
}
