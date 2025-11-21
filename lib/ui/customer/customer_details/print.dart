import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../data/model/all_invoice_for_customer.dart';

class CustomerInvoicePDF {
  static Future<Uint8List> generateA4Invoice(CustomerInvoiceModel invoice) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();

    final logoBytes = await rootBundle.load('assets/logo2/pepsi.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(logo, width: 120)),
                pw.SizedBox(height: 10),

                // ====== HEADER ======
                pw.Center(
                  child: pw.Text("فاتورة مبيعات",
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.dateTime ?? DateTime.now())}",
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text("Invoice Date",
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 6),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("رقم الفاتورة: ${invoice.id}",
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text("Invoice No.",
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),

                // ========= CUSTOMER INFO =========
                pw.Text("بيانات العميل:",
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),

                pw.Text("الاسم: ${invoice.customerName}",
                    style: pw.TextStyle(font: font, fontSize: 12)),
                pw.SizedBox(height: 5),

                pw.Divider(),

                // ========== PRODUCTS TABLE ==========
                pw.Text("المنتجات",
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(4),
                    1: pw.FlexColumnWidth(1.5),
                    2: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0F2F1)),
                      children: [
                        _tableHeader("المنتج", font),
                        _tableHeader("الكمية", font),
                        _tableHeader("السعر", font),
                      ],
                    ),
                    ...invoice.items.map((item) {
                      return pw.TableRow(
                        children: [
                          _tableCell(item.productName ?? "", font),
                          _tableCell("${item.qun}", font),
                          _tableCell("${item.salePrice} EGP", font),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 20),

                // ======= SUMMARY ==========
                pw.Text("الملخص",
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),

                _summaryRow("الإجمالي قبل الخصم", invoice.totalBeforeDiscount, font),
                _summaryRow("الخصم", invoice.discount, font),
                pw.Divider(),
                _summaryRow("الإجمالي بعد الخصم", invoice.totalAfterDiscount, font, isBold: true),
                pw.Divider(),
                _summaryRow("المديونية السابقة", invoice.debtBefore, font),
                _summaryRow("المديونية الحالية", invoice.debtAfter, font),

                pw.SizedBox(height: 20),

                pw.Center(
                    child: pw.Text("Amounts are in EGP",
                        style: pw.TextStyle(font: font, fontSize: 10))),
                pw.Center(
                    child: pw.Text(
                        "Printed On: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
                        style: pw.TextStyle(font: font, fontSize: 9))),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: font, fontSize: 11)),
    );
  }

  static pw.Widget _summaryRow(String title, double? value, pw.Font font,
      {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text("${value?.toStringAsFixed(2) ?? "0.00"} EGP",
            style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}
