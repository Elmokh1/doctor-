import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_doctor/data/model/invoice_counter.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:el_doctor/data/model/product_model.dart';
import 'package:el_doctor/data/model/proudct_transaction_model.dart';
import 'package:el_doctor/data/model/receive_payment.dart';
import 'model/all_invoice_for_customer.dart';
import 'model/buy_counter.dart';
import 'model/cash_box_model.dart';
import 'model/customer_model.dart';
import 'model/customer_transaction_summary_model.dart';
import 'model/money_transaction_model.dart';
import 'model/sale_counter.dart';
import 'model/sections_model.dart';
import 'model/vendor_counter.dart';
import 'model/vendor_model.dart';
import 'model/vendor_transaction_summary_model.dart';

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

  static Stream<QuerySnapshot<ProductModel>> getProductsRealTimeUpdateById(
    String productId,
  ) {
    return getProductCollection().where("id", isEqualTo: productId).snapshots();
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

  static Future<void> updateProductQuantity({
    required String id,
    required int newQuantity,
  }) async {
    try {
      await getProductCollection().doc(id).update({'qun': newQuantity});
      print("✔ تم تحديث كمية المنتج");
    } catch (e) {
      print("❌ خطأ أثناء تحديث كمية المنتج: $e");
      rethrow;
    }
  }

  // Product Transaction

  static CollectionReference<ProductTransactionModel>
  productTransactionCollection(String pId) {
    return getProductCollection()
        .doc(pId)
        .collection(ProductTransactionModel.collectionName)
        .withConverter<ProductTransactionModel>(
          fromFirestore: (snapshot, options) =>
              ProductTransactionModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  // --------------------------------------
  //  Add Transaction
  // --------------------------------------
  static Future<void> addProductTransaction(
    String productId,
    ProductTransactionModel transaction,
  ) async {
    try {
      final docRef = productTransactionCollection(productId).doc();
      transaction.id = docRef.id;
      await docRef.set(transaction);
    } catch (e, s) {
      print("StackTrace: $s");
      rethrow;
    }
  }

  // --------------------------------------
  //  Read Single Transaction
  // --------------------------------------
  static Future<ProductTransactionModel?> readProductTransaction(
    String productId,
    String transactionId,
  ) async {
    return (await productTransactionCollection(
      productId,
    ).doc(transactionId).get()).data();
  }

  // --------------------------------------
  //  Stream All Transactions
  // --------------------------------------
  static Stream<QuerySnapshot<ProductTransactionModel>>
  getProductTransactionsStream(String productId) {
    return productTransactionCollection(productId).snapshots();
  }

  // --------------------------------------
  // Update Product Transaction by InvoiceId
  // --------------------------------------
  static Future<void> updateProductTransactionByInvoiceId({
    required String productId,
    required String oldInvoiceId, // رقم الفاتورة القديمة
    required int newQuantity,
    required DateTime newDate,
    required String newInvoiceId, // رقم الفاتورة الجديدة
  }) async {
    final collection = productTransactionCollection(productId);

    // الحصول على كل الحركات المرتبطة بالـ invoiceId القديم
    final querySnapshot = await collection
        .where('invoiceId', isEqualTo: oldInvoiceId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("❌ لم يتم العثور على حركات مرتبطة بهذه الفاتورة: $oldInvoiceId");
      return;
    }

    for (var doc in querySnapshot.docs) {
      await collection.doc(doc.id).update({
        'qun': newQuantity,
        'transactionDate': newDate.millisecondsSinceEpoch,
        'invoiceId': newInvoiceId,
      });

      print(
        "🔥 تم تحديث حركة المنتج وربطها بالـ Invoice جديد $newInvoiceId بدلاً من $oldInvoiceId",
      );
    }
  }

  // --------------------------------------
  //  Delete Transaction
  // --------------------------------------
  static Future<void> deleteProductTransaction(
    String productId,
    String transactionId,
  ) {
    return productTransactionCollection(productId).doc(transactionId).delete();
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
      await getVendorsCollection().doc(id).update({'name': newName});
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

  static Stream<QuerySnapshot<VendorModel>> getVendorRealTimeUpdateById(
    String vendorId,
  ) {
    return getVendorsCollection().where("id", isEqualTo: vendorId).snapshots();
  }

  static Future<void> updateVendor({
    required String id,
    double? newBalance,
  }) async {
    final updates = <String, dynamic>{};

    if (newBalance != null) updates['openingBalance'] = newBalance;

    await getVendorsCollection().doc(id).update(updates);

    print("✅ تم تحديث بيانات المورد بنجاح ( الرصيد)");
  }

  // Vendor Invoice

  static CollectionReference<PayVendorModel> vendorInvoiceCollection(
    String vId,
  ) {
    return getVendorsCollection()
        .doc(vId)
        .collection(PayVendorModel.collectionName)
        .withConverter<PayVendorModel>(
          fromFirestore: (snapshot, options) =>
              PayVendorModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  static Future<void> addVendorInvoice(
    PayVendorModel vendorPayment,
    String vendorId, // ← الفيندور زي ما هو
    String invoiceId, // ← الكاونتر الجديد Manual ID
  ) async {
    final docRef = vendorInvoiceCollection(vendorId).doc(invoiceId);

    vendorPayment.id = invoiceId; // نخزن ID الفاتورة نفسه

    return await docRef.set(vendorPayment);
  }

  static Future<PayVendorModel?> readVendorInvoice(
    String vId,
    String id,
  ) async {
    return (await vendorInvoiceCollection(vId).doc(id).get()).data();
  }

  static Future<List<PayVendorModel>> getVendorInvoices(String vId) async {
    final snap = await vendorInvoiceCollection(
      vId,
    ).orderBy('dateTime', descending: true).get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  static Future<void> deleteVendorInvoice(String vId, String invoiceId) {
    return vendorInvoiceCollection(vId).doc(invoiceId).delete();
  }

  static Stream<QuerySnapshot<PayVendorModel>> getVendorInvoicesByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    return FirebaseFirestore.instance
        .collectionGroup(PayVendorModel.collectionName)
        .where(
          "dateTime",
          isGreaterThanOrEqualTo: fromDate.millisecondsSinceEpoch,
        )
        .where("dateTime", isLessThanOrEqualTo: toDate.millisecondsSinceEpoch)
        .orderBy('dateTime', descending: true)
        .withConverter<PayVendorModel>(
          fromFirestore: (snapshot, _) =>
              PayVendorModel.fromFireStore(snapshot.data()),
          toFirestore: (receivePayment, _) => receivePayment.toFireStore(),
        )
        .snapshots();
  }

  static Future<List<PayVendorModel>> getVendorPaymentById(
    String vendorId,
    String id,
  ) async {
    final snap = await vendorInvoiceCollection(
      vendorId,
    ).where('id', isEqualTo: id).get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }
  static Future<void> updateVendorInvoice({
    required String vendorId,
    required PayVendorModel updatedPayment,
  }) async {
    if (updatedPayment.id == null) {
      throw Exception("Invoice ID is null, cannot update document");
    }

    // تعديل الفاتورة بدون مسح الحقول الأخرى
    await vendorInvoiceCollection(vendorId)
        .doc(updatedPayment.id)
        .set(
      updatedPayment, // ← Map<String, dynamic> صح
      SetOptions(merge: true),
    );
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
    double? newBalance,
  }) async {
    final updates = <String, dynamic>{};

    if (newBalance != null) updates['openingBalance'] = newBalance;

    await getCustomersCollection().doc(id).update(updates);

    print("✅ تم تحديث بيانات العميل بنجاح ( الرصيد)");
  }

  //Customer Transaction Summary
  static CollectionReference<CustomerTransactionSummaryModel>
  getCustomerTransactionsSummaryCollection() {
    return FirebaseFirestore.instance
        .collection(CustomerTransactionSummaryModel.collectionName)
        .withConverter<CustomerTransactionSummaryModel>(
          fromFirestore: (snapshot, options) =>
              CustomerTransactionSummaryModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  static Future<void> addCustomerTransactionSummary(
    CustomerTransactionSummaryModel transaction,
  ) async {
    // توليد docRef عشوائي
    final docRef = getCustomerTransactionsSummaryCollection().doc();
    transaction.id = docRef.id; // assign the generated id
    await docRef.set(transaction);
    print("✅ تم حفظ الحركة بنجاح بالـ ID: ${docRef.id}");
  }

  static Future<CustomerTransactionSummaryModel?>
  readCustomerTransactionSummary(String transactionId) async {
    return (await getCustomerTransactionsSummaryCollection()
            .doc(transactionId)
            .get())
        .data();
  }

  static Future<List<CustomerTransactionSummaryModel>>
  getAllCustomerTransactionsSummary() async {
    final snap = await getCustomerTransactionsSummaryCollection()
        .orderBy('dateTime', descending: true)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  static Stream<QuerySnapshot<CustomerTransactionSummaryModel>>
  getCustomerTransactionsSummaryStream(String customerId) {
    return getCustomerTransactionsSummaryCollection()
        .where("customerId", isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  static Future<void> deleteCustomerTransactionSummary(
    String transactionId,
  ) async {
    await getCustomerTransactionsSummaryCollection()
        .doc(transactionId)
        .delete();
    print("✅ تم حذف الحركة بنجاح بالـ ID: $transactionId");
  }

  static Future<void> updateCustomerTransactionSummary(
    CustomerTransactionSummaryModel transaction,
  ) async {
    if (transaction.id == null) throw Exception("Transaction ID is null");
    await getCustomerTransactionsSummaryCollection()
        .doc(transaction.id)
        .update(transaction.toFireStore());
    print("✅ تم تحديث الحركة بنجاح بالـ ID: ${transaction.id}");
  }

  // Customer Invoice

  static CollectionReference<ReceivePaymentModel> customerInvoiceCollection(
    String cId,
  ) {
    return getCustomersCollection()
        .doc(cId)
        .collection(ReceivePaymentModel.collectionName)
        .withConverter<ReceivePaymentModel>(
          fromFirestore: (snapshot, options) =>
              ReceivePaymentModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  static Future<String> addInvoice(
    ReceivePaymentModel receivePayment,
    String customerId,
  ) async {
    final docRef = customerInvoiceCollection(customerId).doc();

    receivePayment.id = docRef.id;

    await docRef.set(receivePayment);

    return docRef.id;
  }

  static Future<ReceivePaymentModel?> readReceivedPayment(
    String cId,
    String id,
  ) async {
    return (await customerInvoiceCollection(cId).doc(id).get()).data();
  }

  static Stream<QuerySnapshot<ReceivePaymentModel>> getReceivedPaymentStream(
    String cId,
  ) {
    return customerInvoiceCollection(cId).snapshots();
  }

  static Future<void> deleteReceivedPaymentInvoice(
    String cId,
    String receivedId,
  ) {
    return customerInvoiceCollection(cId).doc(receivedId).delete();
  }

  static Stream<QuerySnapshot<ReceivePaymentModel>>
  getReceivedPaymentByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    return FirebaseFirestore.instance
        .collectionGroup(ReceivePaymentModel.collectionName)
        .where(
          "dateTime",
          isGreaterThanOrEqualTo: fromDate.millisecondsSinceEpoch,
        )
        .where("dateTime", isLessThanOrEqualTo: toDate.millisecondsSinceEpoch)
        .orderBy('dateTime', descending: true)
        .withConverter<ReceivePaymentModel>(
          fromFirestore: (snapshot, _) =>
              ReceivePaymentModel.fromFireStore(snapshot.data()),
          toFirestore: (receivePayment, _) => receivePayment.toFireStore(),
        )
        .snapshots();
  }

  static Future<List<ReceivePaymentModel>> getCustomerInvoices(
    String cId,
  ) async {
    final snap = await customerInvoiceCollection(
      cId,
    ).orderBy('dateTime', descending: true).get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  static Future<List<ReceivePaymentModel>> getCustomerPaymentByInvoiceNum(
    String customerId,
    String id,
  ) async {
    final snap = await customerInvoiceCollection(
      customerId,
    ).where('invoiceNum', isEqualTo: id).get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }
  static Future<void> updateReceivedPayment({
    required String customerId,
    required ReceivePaymentModel payment,
  }) async {
    if (payment.id == null) {
      throw Exception("Payment ID is null, cannot update document");
    }

    await customerInvoiceCollection(customerId)
        .doc(payment.id)
        .set(
      payment,
      SetOptions(merge: true), // عشان يعدل الموجود بس وميمسحش باقي الحقول
    );
  }


  // Counters
  static CollectionReference<InvoiceCounterModel>
  getInvoiceCounterCollection() {
    return FirebaseFirestore.instance
        .collection(InvoiceCounterModel.collectionName)
        .withConverter<InvoiceCounterModel>(
          fromFirestore: (snapshot, options) =>
              InvoiceCounterModel.fromFireStore(snapshot.data()),
          toFirestore: (counter, options) => counter.toFireStore(),
        );
  }

  static Future<void> addInvoiceCounter(InvoiceCounterModel counter) async {
    try {
      final docRef = getInvoiceCounterCollection().doc();
      counter.id = docRef.id;
      await docRef.set(counter);
      print("✅ تم حفظ الكاونتر بنجاح بالـ ID: ${counter.id}");
    } catch (e, s) {
      print("❌ خطأ داخل addInvoiceCounter: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<InvoiceCounterModel?> readInvoiceCounter(String id) async {
    return (await getInvoiceCounterCollection().doc(id).get()).data();
  }

  static Future<void> updateInvoiceCounter(int newCounter) async {
    final collection = getInvoiceCounterCollection();

    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({'counter': newCounter});
    } else {
      final docRef = collection.doc();
      await docRef.set(InvoiceCounterModel(id: docRef.id, counter: newCounter));
    }
  }

  static Stream<QuerySnapshot<InvoiceCounterModel>> getInvoiceCountersStream() {
    return getInvoiceCounterCollection().snapshots();
  }

  static Future<void> deleteInvoiceCounter(String id) async {
    try {
      await getInvoiceCounterCollection().doc(id).delete();
      print("✅ تم حذف الكاونتر بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء حذف الكاونتر: $e");
      rethrow;
    }
  }

  // Vendor Pay Counter
  static CollectionReference<VendorPayCounterModel>
  getVendorPayCounterCollection() {
    return FirebaseFirestore.instance
        .collection(VendorPayCounterModel.collectionName)
        .withConverter<VendorPayCounterModel>(
          fromFirestore: (snapshot, options) =>
              VendorPayCounterModel.fromFireStore(snapshot.data()),
          toFirestore: (counter, options) => counter.toFireStore(),
        );
  }

  static Future<void> addVendorPayCounter(VendorPayCounterModel counter) async {
    try {
      final docRef = getVendorPayCounterCollection().doc();
      counter.id = docRef.id;
      await docRef.set(counter);
      print("✅ تم حفظ كاونتر الدفع للمورد بالـ ID: ${counter.id}");
    } catch (e, s) {
      print("❌ خطأ داخل addVendorPayCounter: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<VendorPayCounterModel?> readVendorPayCounter(String id) async {
    return (await getVendorPayCounterCollection().doc(id).get()).data();
  }

  static Future<void> updateVendorPayCounter(int newCounter) async {
    final collection = getVendorPayCounterCollection();

    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({'counter': newCounter});
    } else {
      final docRef = collection.doc();
      await docRef.set(
        VendorPayCounterModel(id: docRef.id, counter: newCounter),
      );
    }
  }

  static Stream<QuerySnapshot<VendorPayCounterModel>>
  getVendorPayCountersStream() {
    return getVendorPayCounterCollection().snapshots();
  }

  static Future<void> deleteVendorPayCounter(String id) async {
    try {
      await getVendorPayCounterCollection().doc(id).delete();
      print("✅ تم حذف كاونتر الدفع للمورد بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء حذف كاونتر الدفع للمورد: $e");
      rethrow;
    }
  }

  // Sale Counter
  static CollectionReference<SaleCounterModel> getSaleCounterCollection() {
    return FirebaseFirestore.instance
        .collection(SaleCounterModel.collectionName)
        .withConverter<SaleCounterModel>(
          fromFirestore: (snapshot, options) =>
              SaleCounterModel.fromFireStore(snapshot.data()),
          toFirestore: (counter, options) => counter.toFireStore(),
        );
  }

  static Future<void> addSaleCounter(SaleCounterModel counter) async {
    try {
      final docRef = getSaleCounterCollection().doc();
      counter.id = docRef.id;
      await docRef.set(counter);
      print("✅ تم حفظ كاونتر الدفع للمورد بالـ ID: ${counter.id}");
    } catch (e, s) {
      print("❌ خطأ داخل addSaleCounter: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<SaleCounterModel?> readSaleCounter(String id) async {
    return (await getSaleCounterCollection().doc(id).get()).data();
  }

  static Future<void> updateSaleCounter(int newCounter) async {
    final collection = getSaleCounterCollection();

    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({'counter': newCounter});
    } else {
      final docRef = collection.doc();
      await docRef.set(SaleCounterModel(id: docRef.id, counter: newCounter));
    }
  }

  static Stream<QuerySnapshot<SaleCounterModel>> getSaleCountersStream() {
    return getSaleCounterCollection().snapshots();
  }

  static Future<void> deleteSaleCounter(String id) async {
    try {
      await getSaleCounterCollection().doc(id).delete();
      print("✅ تم حذف كاونتر الدفع للمورد بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء حذف كاونتر الدفع للمورد: $e");
      rethrow;
    }
  }

  // Buy Counter
  static CollectionReference<BuyCounterModel> getBuyCounterCollection() {
    return FirebaseFirestore.instance
        .collection(BuyCounterModel.collectionName)
        .withConverter<BuyCounterModel>(
          fromFirestore: (snapshot, options) =>
              BuyCounterModel.fromFireStore(snapshot.data()),
          toFirestore: (counter, options) => counter.toFireStore(),
        );
  }

  static Future<void> addBuyCounter(BuyCounterModel counter) async {
    try {
      final docRef = getBuyCounterCollection().doc();
      counter.id = docRef.id;
      await docRef.set(counter);
      print("✅ تم حفظ كاونتر الدفع للمورد بالـ ID: ${counter.id}");
    } catch (e, s) {
      print("❌ خطأ داخل addBuyCounter: $e");
      print("StackTrace: $s");
      rethrow;
    }
  }

  static Future<BuyCounterModel?> readBuyCounter(String id) async {
    return (await getBuyCounterCollection().doc(id).get()).data();
  }

  static Future<void> updateBuyCounter(int newCounter) async {
    final collection = getBuyCounterCollection();

    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final docRef = snapshot.docs.first.reference;
      await docRef.update({'counter': newCounter});
    } else {
      final docRef = collection.doc();
      await docRef.set(BuyCounterModel(id: docRef.id, counter: newCounter));
    }
  }

  static Stream<QuerySnapshot<BuyCounterModel>> getBuyCountersStream() {
    return getBuyCounterCollection().snapshots();
  }

  static Future<void> deleteBuyCounter(String id) async {
    try {
      await getBuyCounterCollection().doc(id).delete();
      print("✅ تم حذف كاونتر الدفع للمورد بنجاح");
    } catch (e) {
      print("❌ حدث خطأ أثناء حذف كاونتر الدفع للمورد: $e");
      rethrow;
    }
  }

  //فواتير العملاء

  static CollectionReference<CustomerInvoiceModel>
  getCustomerInvoiceCollection() {
    return FirebaseFirestore.instance
        .collection(
          CustomerInvoiceModel.collectionName,
        ) // اسم الكوليكشن الجديد برا أي كولكشن
        .withConverter<CustomerInvoiceModel>(
          fromFirestore: (snapshot, options) =>
              CustomerInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore: (invoice, options) => invoice.toFireStore(),
        );
  }

  // إضافة فاتورة جديدة - Auto ID + إرجاع الـ ID
  static Future<String> addCustomerInvoice(CustomerInvoiceModel invoice) async {
    final docRef = getCustomerInvoiceCollection().doc(); // ← Auto ID من فايربيز

    invoice.id = docRef.id; // ← نخزن الـ ID داخل الموديل

    await docRef.set(invoice);

    print("✅ تم حفظ الفاتورة بنجاح بالـ ID: ${docRef.id}");

    return docRef
        .id; // ← مهم جداً — نرجّعه لاستخدامه في CustomerTransactionSummary
  }

  // قراءة فاتورة معينة
  static Future<CustomerInvoiceModel?> readCustomerInvoice(
    String invoiceId,
  ) async {
    return (await getCustomerInvoiceCollection().doc(invoiceId).get()).data();
  }

  // الحصول على كل الفواتير
  static Future<List<CustomerInvoiceModel>> getAllCustomerInvoices() async {
    final snap = await getCustomerInvoiceCollection()
        .orderBy('dateTime', descending: true)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  static Future<List<CustomerInvoiceModel>> getCustomerInvoicesById(
    String id,
  ) async {
    final snap = await getCustomerInvoiceCollection()
        .where('invoiceNum', isEqualTo: id)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  static Stream<QuerySnapshot<CustomerInvoiceModel>> getCustomerInvoiceStream(
    String customerId,
  ) {
    return getCustomerInvoiceCollection()
        .where("customerId", isEqualTo: customerId)
        .snapshots();
  }

  static Future<void> deleteCustomerInvoice(String invoiceId) async {
    await getCustomerInvoiceCollection().doc(invoiceId).delete();
    print("✅ تم حذف الفاتورة بنجاح بالـ ID: $invoiceId");
  }

  // تحديث فاتورة (مثلاً تعديل الخصم أو المديونية بعد)
  static Future<void> updateCustomerInvoice(
    CustomerInvoiceModel invoice,
  ) async {
    if (invoice.id == null) throw Exception("Invoice ID is null");
    await getCustomerInvoiceCollection()
        .doc(invoice.id)
        .update(invoice.toFireStore());
    print("✅ تم تحديث الفاتورة بنجاح بالـ ID: ${invoice.id}");
  }

  // =======================
  // Vendor Bills Section
  // =======================

  static CollectionReference<CustomerInvoiceModel> getVendorBillCollection() {
    return FirebaseFirestore.instance
        .collection('VendorBill')
        .withConverter<CustomerInvoiceModel>(
          fromFirestore: (snapshot, options) =>
              CustomerInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore: (bill, options) => bill.toFireStore(),
        );
  }

  // إضافة فاتورة مورد جديدة - Auto ID + إرجاع الـ ID
  static Future<String> addVendorBill(CustomerInvoiceModel bill) async {
    final docRef = getVendorBillCollection().doc(); // Auto ID من فايربيز

    bill.id = docRef.id; // تخزين الـ ID داخل الموديل

    await docRef.set(bill);

    print("✅ تم حفظ فاتورة المورد بنجاح بالـ ID: ${docRef.id}");

    return docRef.id; // نرجعه زي فواتير العملاء بالظبط
  }

  // قراءة فاتورة مورد معينة
  static Future<CustomerInvoiceModel?> readVendorBill(String billId) async {
    return (await getVendorBillCollection().doc(billId).get()).data();
  }

  // الحصول على كل فواتير المورد
  static Future<List<CustomerInvoiceModel>> getAllVendorBills() async {
    final snap = await getVendorBillCollection()
        .orderBy('dateTime', descending: true)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  // Stream لفواتير مورد معين
  static Stream<QuerySnapshot<CustomerInvoiceModel>> getVendorBillStream(
    String vendorId,
  ) {
    return getVendorBillCollection()
        .where("customerId", isEqualTo: vendorId) // customerId مستخدم كمورد
        .snapshots();
  }

  // حذف فاتورة مورد
  static Future<void> deleteVendorBill(String billId) async {
    await getVendorBillCollection().doc(billId).delete();
    print("✅ تم حذف فاتورة المورد بنجاح بالـ ID: $billId");
  }

  // تحديث فاتورة مورد
  static Future<void> updateVendorBill(CustomerInvoiceModel bill) async {
    if (bill.id == null) throw Exception("Bill ID is null");
    await getVendorBillCollection().doc(bill.id).update(bill.toFireStore());
    print("✅ تم تحديث فاتورة المورد بنجاح بالـ ID: ${bill.id}");
  }

  // البحث عن فاتورة مورد بالـ invoiceNum (زي العملاء بالضبط)
  static Future<List<CustomerInvoiceModel>> getVendorBillById(String id) async {
    final snap = await getVendorBillCollection()
        .where('invoiceNum', isEqualTo: id)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  // Vendor Transaction Summary
  static CollectionReference<VendorTransactionSummaryModel>
  getVendorTransactionsSummaryCollection() {
    return FirebaseFirestore.instance
        .collection(VendorTransactionSummaryModel.collectionName)
        .withConverter<VendorTransactionSummaryModel>(
          fromFirestore: (snapshot, options) =>
              VendorTransactionSummaryModel.fromFireStore(snapshot.data()),
          toFirestore: (transaction, options) => transaction.toFireStore(),
        );
  }

  // إضافة حركة مورد جديدة
  static Future<void> addVendorTransactionSummary(
    VendorTransactionSummaryModel transaction,
  ) async {
    final docRef = getVendorTransactionsSummaryCollection()
        .doc(); // توليد ID تلقائي
    transaction.id = docRef.id;
    await docRef.set(transaction);
    print("✅ تم حفظ الحركة بنجاح بالـ ID: ${docRef.id}");
  }

  // قراءة حركة معينة
  static Future<VendorTransactionSummaryModel?> readVendorTransactionSummary(
    String transactionId,
  ) async {
    return (await getVendorTransactionsSummaryCollection()
            .doc(transactionId)
            .get())
        .data();
  }

  // الحصول على كل الحركات
  static Future<List<VendorTransactionSummaryModel>>
  getAllVendorTransactionsSummary() async {
    final snap = await getVendorTransactionsSummaryCollection()
        .orderBy('dateTime', descending: true)
        .get();

    return snap.docs.map((e) => e.data()..id = e.id).toList();
  }

  // Stream للحصول على الحركات بشكل مباشر عند أي تحديث
  static Stream<QuerySnapshot<VendorTransactionSummaryModel>>
  getVendorTransactionsSummaryStream(String vendorId) {
    return getVendorTransactionsSummaryCollection()
        .where("vendorId", isEqualTo: vendorId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  // حذف حركة
  static Future<void> deleteVendorTransactionSummary(
    String transactionId,
  ) async {
    await getVendorTransactionsSummaryCollection().doc(transactionId).delete();
    print("✅ تم حذف الحركة بنجاح بالـ ID: $transactionId");
  }

  // تحديث حركة
  static Future<void> updateVendorTransactionSummary(
    VendorTransactionSummaryModel transaction,
  ) async {
    if (transaction.id == null) throw Exception("Transaction ID is null");
    await getVendorTransactionsSummaryCollection()
        .doc(transaction.id)
        .update(transaction.toFireStore());
    print("✅ تم تحديث الحركة بنجاح بالـ ID: ${transaction.id}");
  }
}
