import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/all_invoice_for_customer.dart';
import '../../data/model/product_model.dart';
import '../../data/my_dataBase.dart';
import 'customer_invoice_state.dart';

class CustomerInvoicesCubit extends Cubit<CustomerInvoiceState> {
  CustomerInvoicesCubit() : super(CustomerInvoiceInitial());

  // إضافة فاتورة عميل جديدة – ترجع Auto ID من فايربيز
  Future<String> addCustomerInvoice({
    required String invoiceNum,
    required String customerId,
    required String customerName,
    required String invoiceType,
    required String notes,
    required List<ProductModel> items,
    required double totalBeforeDiscount,
    required double totalAfterDiscount,
    required double discount,
    required double debtBefore,
    required double debtAfter,
    required DateTime dateTime,
  }) async {
    emit(CustomerInvoiceLoading());
    try {
      final invoice = CustomerInvoiceModel(
        invoiceNum: invoiceNum,
        customerId: customerId,
        customerName: customerName,
        invoiceType: invoiceType,
        notes: notes,
        items: items,
        totalBeforeDiscount: totalBeforeDiscount,
        totalAfterDiscount: totalAfterDiscount,
        discount: discount,
        debtBefore: debtBefore,
        debtAfter: debtAfter,
        dateTime: dateTime,
      );

      // 🔥 استخدمنا MyDatabase وأخذنا الـ Auto ID
      final String firestoreId = await MyDatabase.addCustomerInvoice(invoice);

      emit(CustomerInvoiceSuccess());

      // تحديث قائمة الفواتير
      getCustomerInvoices(customerId);

      // 👈 مهم جداً: نرجعه
      return firestoreId;
    } catch (e) {
      emit(CustomerInvoiceError("حدث خطأ أثناء الحفظ: $e"));
      return Future.error(e);
    }
  }

  // تحميل كل الفواتير
  void getCustomerInvoices(String customerId) {
    emit(CustomerInvoiceLoading());
    MyDatabase.getCustomerInvoiceStream(customerId).listen(
          (snapshot) {
        final invoices = snapshot.docs.map((e) => e.data()).toList();
        emit(CustomerInvoiceLoaded(invoices));
      },
      onError: (error) {
        emit(CustomerInvoiceError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }

  Future<void> fetchInvoicesById(String id) async {
    emit(CustomerInvoiceLoading());
    try {
      final invoices = await MyDatabase.getCustomerInvoicesById(id);
      emit(CustomerInvoiceLoaded(invoices));
    } catch (e) {
      emit(CustomerInvoiceError("حدث خطأ أثناء جلب الفواتير: $e"));
    }
  }


  Future<void> replaceCustomerInvoice({
    required CustomerInvoiceModel oldInvoice,
    required CustomerInvoiceModel newInvoice,
  }) async {
    emit(CustomerInvoiceLoading());
    try {
      // 1️⃣ احذف الفاتورة القديمة
      await MyDatabase.deleteCustomerInvoice(oldInvoice.id!);

      // 2️⃣ احتفظ بنفس invoiceNum و debtBefore
      newInvoice.invoiceNum = oldInvoice.invoiceNum;
      newInvoice.debtBefore = oldInvoice.debtBefore;

      // 3️⃣ احفظ الفاتورة الجديدة واحصل على الـ ID الجديد
      final newId = await MyDatabase.addCustomerInvoice(newInvoice);
      newInvoice.id = newId;

      emit(CustomerInvoiceSuccess());

      // 4️⃣ حدث قائمة الفواتير
      getCustomerInvoices(newInvoice.customerId!);

    } catch (e) {
      emit(CustomerInvoiceError("حدث خطأ أثناء استبدال الفاتورة: $e"));
    }
  }

}
