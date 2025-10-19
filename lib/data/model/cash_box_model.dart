import 'package:firebase_auth/firebase_auth.dart';

class CashBoxModel {
  static const String collectionName = 'CashBox';
  String? id;
  double? cash;

  CashBoxModel({this.id, this.cash});

  CashBoxModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], cash: (data?['cash'] ?? 0).toDouble());

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'cash': cash};
  }
}
