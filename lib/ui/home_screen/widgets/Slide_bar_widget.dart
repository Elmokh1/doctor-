import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // مهم للترجمة

// Cubits & UI
import '../../customer/add_customer/add_customer.dart';
import '../../customer/all_customer_invoice_transaction/all_customer_invoice_transaction_page_for_customer.dart';
import '../../customer/invoice/invoice_screen.dart';

import '../../customer/customer_screen.dart';
import '../../inventory_Screen/inventory_screen.dart';
import '../../vendors/add_vendor/add_vendor.dart';
import '../../vendors/all_vendor_invoice_transactions/all_vendor_invoice_transaction_page_for_customer.dart';
import '../../vendors/pay_to_vendor/pay_screen.dart';
import '../../vendors/vendors_screen.dart';
import '../add_product/add_product.dart';
import 'Slide_bar_item.dart';
import 'package:el_doctor/ui/home_screen/Home_screen.dart';
import 'package:el_doctor/ui/transactions_list_page/transactions_list_page.dart';

class SlideBarWidget extends StatelessWidget {
  final double w;
  final double h;

  const SlideBarWidget(this.h, this.w, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w * 0.3,
      color: const Color(0xFF1E3A8A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: h * 0.06),

          InkWell(
            child: SlideBarItem(Icons.home_outlined, "home".tr()),
            onTap: () => Navigator.pushNamed(context, HomeScreen.routeName),
          ),

          InkWell(
            child: SlideBarItem(Icons.trending_up, "income".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TransactionsListPage(isIncome: true)),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.trending_down, "expenses".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TransactionsListPage(isIncome: false)),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.store_mall_directory, "vendors".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VendorsScreen()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.people_alt, "customers".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CustomerScreen()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.warehouse, "store".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StorePage()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.add_box, "add_product".tr()),
            onTap: () => _showAddProductDialog(context),
          ),

          InkWell(
            child: SlideBarItem(Icons.person_add_alt_1, "add_vendor".tr()),
            onTap: () => _showAddVendorDialog(context),
          ),

          InkWell(
            child: SlideBarItem(Icons.person_add, "add_customer".tr()),
            onTap: () => _showAddCustomerDialog(context),
          ),

          InkWell(
            child: SlideBarItem(Icons.request_quote, "collect".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceivedPaymentInvoiceScreen()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.credit_card, "pay".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PayVendorInvoiceScreen()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.receipt_long, "add_customer_invoice".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddInvoicePage()),
            ),
          ),

          InkWell(
            child: SlideBarItem(Icons.receipt, "add_vendor_invoice".tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddVendorInvoicePage()),
            ),
          ),

          const Spacer(),

          // زر تغيير اللغة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                context.locale = context.locale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en');
              },
              icon: const Icon(Icons.language),
              label: Text('change_language'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(w * 0.25, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) =>
      showDialog(context: context, barrierDismissible: false, builder: (_) => AddProductDialog());

  void _showAddCustomerDialog(BuildContext context) =>
      showDialog(context: context, barrierDismissible: false, builder: (_) => AddCustomerDialog());

  void _showAddVendorDialog(BuildContext context) =>
      showDialog(context: context, barrierDismissible: false, builder: (_) => AddVendorDialog());
}
