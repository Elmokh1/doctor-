import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/cash_box_model.dart';
import 'model/money_transaction_model.dart';
import 'model/sections_model.dart';

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
      print("بيحاول يحفظ القسم بالـ ID: ${addSections.id} و الاسم: ${addSections.name}");
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

  static Stream<QuerySnapshot<SectionsModel>> getSectionsRealTimeUpdateForRecommend(String sectionId) {
    return getSectionsCollection()
        .where("id", isEqualTo: sectionId)
        .snapshots();
  }


  // CashBox
  static CollectionReference<CashBoxModel> getCashBoxCollection() {
    return FirebaseFirestore.instance
        .collection(CashBoxModel.collectionName)
        .withConverter<CashBoxModel>(
      fromFirestore: (snapshot, _) => CashBoxModel.fromFireStore(snapshot.data()),
      toFirestore: (cash, _) => cash.toFireStore(),
    );
  }
  static Future<double> getCash() async {
    final docSnapshot = await getCashBoxCollection().doc("wSBVnqAT2mZ6p7sg0DB2").get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?.cash?.toDouble() ?? 0.0;
    } else {
      // لو الوثيقة مش موجودة، انشئ واحدة برصيد 0
      await getCashBoxCollection().doc("wSBVnqAT2mZ6p7sg0DB2").set(
        CashBoxModel(id: "wSBVnqAT2mZ6p7sg0DB2", cash: 0.0),
      );
      return 0.0;
    }
  }

  static Stream<QuerySnapshot<CashBoxModel>> getCashBoxStream() {
    return getCashBoxCollection().snapshots();
  }

  static Future<void> updateCash(double newCash) async {
    final collection = getCashBoxCollection();

    // جلب أول سجل موجود للخزنة
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

  static CollectionReference<MoneyTransactionModel> _transactionCollection(String secId) {
    return getSectionsCollection()
        .doc(secId)
        .collection(MoneyTransactionModel.collectionName)
        .withConverter<MoneyTransactionModel>(
      fromFirestore: (snapshot, options) =>
          MoneyTransactionModel.fromFireStore(snapshot.data()),
      toFirestore: (transaction, options) => transaction.toFireStore(),
    );
  }

  static Future<void> addTransaction(MoneyTransactionModel transaction, String secId) async {
    final docRef = _transactionCollection(secId).doc();
    transaction.id = docRef.id;
    return await docRef.set(transaction);
  }

  static Future<MoneyTransactionModel?> readTransaction(String secId, String id) async {
    return (await _transactionCollection(secId).doc(id).get()).data();
  }

  static Stream<QuerySnapshot<MoneyTransactionModel>> getTransactionsStream(String secId) {
    return _transactionCollection(secId).snapshots();
  }
  static Stream<QuerySnapshot<MoneyTransactionModel>> getAllTransactionsStream() {
    return FirebaseFirestore.instance
        .collectionGroup(MoneyTransactionModel.collectionName)
        .orderBy('transactionDate', descending: true) // تأكد من الاسم
        .withConverter<MoneyTransactionModel>(
      fromFirestore: (snapshot, _) => MoneyTransactionModel.fromFireStore(snapshot.data()),
      toFirestore: (transaction, _) => transaction.toFireStore(),
    )
        .snapshots();
  }


  static Future<void> deleteTransaction(String secId, String transactionId) {
    return _transactionCollection(secId).doc(transactionId).delete();
  }
}
