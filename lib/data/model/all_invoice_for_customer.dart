import 'package:el_doctor/data/model/product_model.dart';

class CustomerInvoiceModel {
  static const String collectionName = 'InvoicesForCustomer';
  String? id;
  String? invoiceType; // بيع، مرتجع للمخزن
  String? customerId;
  String? customerName;
  String? notes;
  List<ProductModel> items; // المنتجات في الفاتورة
  double? discount;
  double? totalBeforeDiscount;
  double? totalAfterDiscount;
  double? debtBefore; // المديونية قبل الفاتورة
  double? debtAfter;  // المديونية بعد الفاتورة
  DateTime? dateTime;

  CustomerInvoiceModel({
    this.id,
    this.invoiceType,
    this.customerId,
    this.notes,
    this.customerName,
    this.items = const [],
    this.discount,
    this.totalBeforeDiscount,
    this.totalAfterDiscount,
    this.debtBefore,
    this.debtAfter,
    this.dateTime,
  });

  // إنشاء من بيانات Firestore
  CustomerInvoiceModel.fromFireStore(Map<String, dynamic>? data)
      : this(
    id: data?['id'],
    invoiceType: data?['invoiceType'],
    notes: data?['notes'],
    customerId: data?['customerId'],
    customerName: data?['customerName'],
    items: data?['items'] != null
        ? (data?['items'] as List)
        .map((e) => ProductModel.fromFireStore(e))
        .toList()
        : [],
    discount: data?['discount']?.toDouble(),
    totalBeforeDiscount: data?['totalBeforeDiscount']?.toDouble(),
    totalAfterDiscount: data?['totalAfterDiscount']?.toDouble(),
    debtBefore: data?['debtBefore']?.toDouble(),
    debtAfter: data?['debtAfter']?.toDouble(),
    dateTime: data?['dateTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data?['dateTime'])
        : null,
  );

  // تحويل البيانات لـ Map لحفظها في Firestore
  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'invoiceType': invoiceType,
      'notes': notes,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((e) => e.toFireStore()).toList(),
      'discount': discount,
      'totalBeforeDiscount': totalBeforeDiscount,
      'totalAfterDiscount': totalAfterDiscount,
      'debtBefore': debtBefore,
      'debtAfter': debtAfter,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }
}
