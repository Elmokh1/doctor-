import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_doctor/data/model/product_model.dart';
import 'model/cash_box_model.dart';
import 'model/customer_model.dart';
import 'model/money_transaction_model.dart';
import 'model/sections_model.dart';
import 'model/vendor_model.dart';

class MyDatabase {
  // ----------------------
  // Sections Collection
  // ----------------------
  static CollectionReference<SectionsModel> getSectionsCollection() {
    return FirebaseFirestore.instance
        .collection(SectionsModel.collectionName)
        .withConverter<SectionsModel>(
          fromFirestore: (snapshot, options) =>
              SectionsModel.fromFireStore(snapshot.data()),
          toFirestore: (sections, options) => sections.toFireStore(),
        );
  }

  static Future<void> addSections(SectionsModel addSections) async {
    print("داخل addSections");
    try {
      final docRef = getSectionsCollection().doc();
      addSections.id = docRef.id;
      print(
        "بيحاول يحفظ القسم بالـ ID: ${addSections.id} و الاسم: ${addSections.name}",
      );
      await docRef.set(addSections);
      print("تم الحفظ بنجاح داخل addSections");
    } catch (e, s) {
      print("خطأ داخل addSections: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<SectionsModel?> readSections(String id) async {
    return (await getSectionsCollection().doc(id).get()).data();
  }

  static Stream<QuerySnapshot<SectionsModel>> getSectionsRealTimeUpdate() {
    return getSectionsCollection().snapshots();
  }

  static Future<void> deleteSection(String sId) {
    return getSectionsCollection().doc(sId).delete();
  }

  static Stream<QuerySnapshot<SectionsModel>>
  getSectionsRealTimeUpdateForRecommend(String sectionId) {
    return getSectionsCollection()
        .where("id", isEqualTo: sectionId)
        .snapshots();
  }

  // CashBox
  static CollectionReference<CashBoxModel> getCashBoxCollection() {
    return FirebaseFirestore.instance
        .collection(CashBoxModel.collectionName)
        .withConverter<CashBoxModel>(
          fromFirestore: (snapshot, _) =>
              CashBoxModel.fromFireStore(snapshot.data()),
          toFirestore: (cash, _) => cash.toFireStore(),
        );
  }

  static Future<double> getCash() async {
    final docSnapshot = await getCashBoxCollection()
        .doc("wSBVnqAT2mZ6p7sg0DB2")
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?.cash?.toDouble() ?? 0.0;
    } else {
      // لو الوثيقة مش موجودة، انشئ واحدة برصيد 0
      await getCashBoxCollection()
          .doc("wSBVnqAT2mZ6p7sg0DB2")
          .set(CashBoxModel(id: "wSBVnqAT2mZ6p7sg0DB2", cash: 0.0));
      return 0.0;
    }
  }

  static Stream<QuerySnapshot<CashBoxModel>> getCashBoxStream() {
    return getCashBoxCollection().snapshots();
  }

  static Future<void> updateCash(double newCash) async {
    final collection = getCashBoxCollection();

    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({'cash': newCash});
    } else {
      // لو الخزنة فاضية، ممكن تنشئ سجل جديد
      final docRef = collection.doc();
      await docRef.set(CashBoxModel(id: docRef.id, cash: newCash));
    }
  }

  // Money Transaction Collection

  static CollectionReference<MoneyTransactionModel> _transactionCollection(
    String secId,
  ) {
    return getSectionsCollection()
        .doc(secId)
        .collection(MoneyTransactionModel.collectionName)
        .withConverter<MoneyTransactionModel>(
          fromFirestore: (snapshot, options) =>
              MoneyTransactionModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  static Future<void> addTransaction(
    MoneyTransactionModel transaction,
    String secId,
  ) async {
    final docRef = _transactionCollection(secId).doc();
    transaction.id = docRef.id;
    return await docRef.set(transaction);
  }

  static Future<MoneyTransactionModel?> readTransaction(
    String secId,
    String id,
  ) async {
    return (await _transactionCollection(secId).doc(id).get()).data();
  }

  static Stream<QuerySnapshot<MoneyTransactionModel>> getTransactionsStream(
    String secId,
  ) {
    return _transactionCollection(secId).snapshots();
  }

  static Stream<QuerySnapshot<MoneyTransactionModel>>
  getAllTransactionsStream() {
    return FirebaseFirestore.instance
        .collectionGroup(MoneyTransactionModel.collectionName)
        .orderBy('transactionDate', descending: true) // تأكد من الاسم
        .withConverter<MoneyTransactionModel>(
          fromFirestore: (snapshot, _) =>
              MoneyTransactionModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, _) => transaction.toFireStore(),
        )
        .snapshots();
  }

  static Future<void> deleteTransaction(String secId, String transactionId) {
    return _transactionCollection(secId).doc(transactionId).delete();
  }

  static Stream<QuerySnapshot<MoneyTransactionModel>>
  getTransactionsByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
    required bool isIncome,
  }) {
    return FirebaseFirestore.instance
        .collectionGroup(MoneyTransactionModel.collectionName)
        .where(
          "transactionDate",
          isGreaterThanOrEqualTo: fromDate.millisecondsSinceEpoch,
        )
        .where(
          "transactionDate",
          isLessThanOrEqualTo: toDate.millisecondsSinceEpoch,
        )
        .where("isIncome", isEqualTo: isIncome)
        .orderBy('transactionDate', descending: true)
        .withConverter<MoneyTransactionModel>(
          fromFirestore: (snapshot, _) =>
              MoneyTransactionModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, _) => transaction.toFireStore(),
        )
        .snapshots();
  }


  // Product
  static CollectionReference<ProductModel> getProductCollection() {
    return FirebaseFirestore.instance
        .collection(ProductModel.collectionName)
        .withConverter<ProductModel>(
      fromFirestore: (snapshot, options) =>
          ProductModel.fromFireStore(snapshot.data()),
      toFirestore: (product, options) => product.toFireStore(),
    );
  }

  static Future<void> addProduct(ProductModel addProduct) async {
    try {
      final docRef = getProductCollection().doc();
      addProduct.id = docRef.id;
      await docRef.set(addProduct);
    } catch (e, s) {
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<ProductModel?> readProduct(String id) async {
    return (await getProductCollection().doc(id).get()).data();
  }

  static Stream<QuerySnapshot<ProductModel>> getProductsRealTimeUpdate() {
    return getProductCollection().snapshots();
  }

  static Future<void> deleteProduct(String pId) {
    return getProductCollection().doc(pId).delete();
  }

  static Stream<QuerySnapshot<ProductModel>>
  getProductsRealTimeUpdateById(String productId) {
    return getProductCollection()
        .where("id", isEqualTo: productId)
        .snapshots();
  }

  static Future<void> updateProductInfo({
    required String id,
    required String newName,
    required double newBuyPrice,
    required double newSalePrice,
  }) async {
    try {
      await getProductCollection().doc(id).update({
        'productName': newName,
        'buyPrice': newBuyPrice,
        'salePrice': newSalePrice,
      });
      print("✅ تم تعديل بيانات المنتج بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء تعديل المنتج: $e");
      rethrow;
    }
  }
//
// Vendors
  //


  static CollectionReference<VendorModel> getVendorsCollection() {
    return FirebaseFirestore.instance
        .collection(VendorModel.collectionName)
        .withConverter<VendorModel>(
      fromFirestore: (snapshot, options) =>
          VendorModel.fromFireStore(snapshot.data()),
      toFirestore: (vendor, options) => vendor.toFireStore(),
    );
  }

  static Future<void> addVendor(VendorModel vendor) async {
    print("📦 داخل addVendor");
    try {
      final docRef = getVendorsCollection().doc();
      vendor.id = docRef.id;
      print("بيحاول يحفظ البائع بالـ ID: ${vendor.id} و الاسم: ${vendor.name}");
      await docRef.set(vendor);
      print("✅ تم الحفظ بنجاح داخل addVendor");
    } catch (e, s) {
      print("❌ خطأ داخل addVendor: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<VendorModel?> readVendor(String id) async {
    return (await getVendorsCollection().doc(id).get()).data();
  }

  static Future<void> updateVendorInfo({
    required String id,
    required String newName,
  }) async {
    try {
      await getVendorsCollection().doc(id).update({
        'name': newName,
      });
      print("✅ تم تعديل بيانات البائع بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء تعديل بيانات البائع: $e");
      rethrow;
    }
  }

  static Future<void> deleteVendor(String vId) {
    return getVendorsCollection().doc(vId).delete();
  }

  static Stream<QuerySnapshot<VendorModel>> getVendorsRealTimeUpdate() {
    return getVendorsCollection().snapshots();
  }

  static Stream<QuerySnapshot<VendorModel>> getVendorRealTimeUpdateById(String vendorId) {
    return getVendorsCollection()
        .where("id", isEqualTo: vendorId)
        .snapshots();
  }


  //
//Customer
//
  static CollectionReference<CustomerModel> getCustomersCollection() {
    return FirebaseFirestore.instance
        .collection(CustomerModel.collectionName)
        .withConverter<CustomerModel>(
      fromFirestore: (snapshot, options) =>
          CustomerModel.fromFireStore(snapshot.data()),
      toFirestore: (customer, options) => customer.toFireStore(),
    );
  }

  static Future<void> addCustomer(CustomerModel customer) async {
    print("داخل addCustomer");
    try {
      final docRef = getCustomersCollection().doc();
      customer.id = docRef.id;
      print(
        "بيحاول يحفظ العميل بالـ ID: ${customer.id} و الاسم: ${customer.name}",
      );
      await docRef.set(customer);
      print("تم الحفظ بنجاح داخل addCustomer");
    } catch (e, s) {
      print("خطأ داخل addCustomer: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<CustomerModel?> readCustomer(String id) async {
    return (await getCustomersCollection().doc(id).get()).data();
  }

  static Stream<QuerySnapshot<CustomerModel>> getCustomersRealTimeUpdate() {
    return getCustomersCollection().snapshots();
  }

  static Future<void> deleteCustomer(String customerId) {
    return getCustomersCollection().doc(customerId).delete();
  }

  static Future<void> updateCustomer({
    required String id,
    String? newName,
  }) async {
    final updates = <String, dynamic>{};
    if (newName != null) updates['name'] = newName;
    await getCustomersCollection().doc(id).update(updates);
    print("تم تحديث بيانات العميل بنجاح");
  }
}
