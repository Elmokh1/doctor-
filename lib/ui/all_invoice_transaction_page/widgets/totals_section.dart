import 'package:flutter/material.dart';

class TotalsAndDiscountSection extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final double grandTotal;
  final double initialDiscount;
  final Function(double) onDiscountChanged;
  final Future<void> Function() onSavePressed;

  const TotalsAndDiscountSection({
    required this.subtotal,
    required this.discountAmount,
    required this.grandTotal,
    required this.initialDiscount,
    required this.onDiscountChanged,
    required this.onSavePressed,
  });

  Widget _buildTotalRow(
      String label,
      double value,
      Color color, {
        bool isGrandTotal = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 20 : 16,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} ج.م',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: isGrandTotal ? 22 : 16,
              fontWeight: isGrandTotal ? FontWeight.w900 : FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(),
                      controller: TextEditingController(text: initialDiscount > 0 ? initialDiscount.toString() : ''),
                      decoration: const InputDecoration(
                        labelText: '% خصم',
                        hintText: '0',
                      ),
                      onChanged: (value) {
                        onDiscountChanged(double.tryParse(value) ?? 0.0);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('أدخل نسبة الخصم', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text(
                  'حفظ وطباعة الفاتورة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: onSavePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalRow('الإجمالي الفرعي:', subtotal, Colors.black87),
                  const Divider(),
                  _buildTotalRow('الخصم المطبق:', -discountAmount, Colors.red),
                  const Divider(thickness: 3, height: 25),
                  _buildTotalRow(
                    'صافي الإجمالي:',
                    grandTotal,
                    Colors.indigo.shade800,
                    isGrandTotal: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}