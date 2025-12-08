import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/all_invoice_for_customer.dart';
import '../../data/model/product_model.dart';
import '../../data/my_dataBase.dart';
import 'customer_invoice_state.dart';

class CustomerInvoicesCubit extends Cubit<CustomerInvoiceState> {
  CustomerInvoicesCubit() : super(CustomerInvoiceInitial());

  // إضافة فاتورة عميل جديدة
  Future<void> addCustomerInvoice({
    required String id,
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
        id: id,
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

      await MyDatabase.addCustomerInvoice(invoice, id);

      emit(CustomerInvoiceSuccess());
      getCustomerInvoices(customerId); // تحديث القائمة بعد الإضافة
    } catch (e) {
      emit(CustomerInvoiceError("حدث خطأ أثناء الحفظ: $e"));
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

}
