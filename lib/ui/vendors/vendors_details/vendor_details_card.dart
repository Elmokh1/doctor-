import 'package:el_doctor/data/model/pay_vendor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/model/receive_payment.dart';
import 'dart:ui' as ui;

class VendorDetailsCard extends StatelessWidget {
  final PayVendorModel invoice;

  const VendorDetailsCard({required this.invoice, super.key});

  @override
  Widget build(BuildContext context) {
    // تاريخ بشكل يوم/شهر/سنة فقط
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("عرض الفاتورة"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 800,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- رأس الفاتورة ----------
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "فاتورة استلام دفعة",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "رقم الفاتورة: ${invoice.id ?? '-'}",
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          "التاريخ: ${invoice.dateTime != null ? dateFormat.format(invoice.dateTime!) : '--'}",
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- بيانات المورد ----------
                  _sectionTitle("بيانات المورد"),
                  _infoRow("اسم المورد", invoice.customerName ?? "-"),
                  _infoRow("كود المورد", invoice.customerId ?? "-"),
                  const Divider(height: 30, thickness: 1),

                  // ---------- تفاصيل الدفع ----------
                  _sectionTitle("تفاصيل الدفع"),
                  _infoRow("المبلغ المدفوع", "${invoice.amount?.toStringAsFixed(2) ?? "0"} جنيه"),
                  _infoRow("الرصيد السابق", "${invoice.oldBalance?.toStringAsFixed(2) ?? "0"} جنيه"),
                  _infoRow("الرصيد الحالي", "${invoice.newBalance?.toStringAsFixed(2) ?? "0"} جنيه"),
                  const Divider(height: 30, thickness: 1),

                  // ---------- الخزنة ----------
                  _sectionTitle("الخزنة"),
                  _infoRow("الرصيد قبل العملية", "${invoice.cashBoxBefore?.toStringAsFixed(2) ?? "0"} جنيه"),
                  _infoRow("الرصيد بعد العملية", "${invoice.cashBoxAfter?.toStringAsFixed(2) ?? "0"} جنيه"),
                  const Divider(height: 30, thickness: 1),

                  // ---------- تفاصيل إضافية ----------
                  _sectionTitle("تفاصيل العملية"),
                  Text(
                    invoice.transactionDetails?.isNotEmpty == true
                        ? invoice.transactionDetails!
                        : "لا توجد تفاصيل إضافية",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    textAlign: TextAlign.right, // <<< محاذاة النص لليمين
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  // صف البيانات
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
