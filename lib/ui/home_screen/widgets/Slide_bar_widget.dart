import 'package:el_doctor/ui/customer/customer_screen.dart';
import 'package:el_doctor/ui/home_screen/Home_screen.dart';
import 'package:el_doctor/ui/transactions_list_page/transactions_list_page.dart';
import 'package:el_doctor/ui/vendors/vendors_screen.dart';
import 'package:flutter/material.dart';

import '../../inventory_Screen/inventory_screen.dart';
import '../add_customer/add_customer.dart';
import '../add_product/add_product.dart';
import '../add_vendor/add_vendor.dart';
import 'Slide_bar_item.dart';

class SlideBarWidget extends StatelessWidget {
  final double w;
  final double h;

  SlideBarWidget(this.h, this.w);

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
            child: SlideBarItem(Icons.home, "الصفحة الرئيسية"),
            onTap: () {
              Navigator.pushNamed(context, HomeScreen.routeName);
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.attach_money, "الدخل"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionsListPage(isIncome: true),
                ),
              );
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.money_off, "المصروفات"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionsListPage(isIncome: false),
                ),
              );
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.account_balance, "الموردين"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorsScreen(),
                ),
              );
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.group, "العملاء"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerScreen(),
                ),
              );
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.inventory, "المخزن"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StorePage(),
                ),
              );
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.add_shopping_cart, "اضافه منتج"),
            onTap: () {
              _showAddProductDialog(context);
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.add_business_rounded, "اضافه مورد"),
            onTap: () {
          _showAddVendorDialog(context);
            },
          ),
          InkWell(
            child: SlideBarItem(Icons.group_add, "اضافه عميل"),
            onTap: () {
              _showAddCustomerDialog(context);
            },
          ),
        ],
      ),
    );
  }
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddProductDialog(),
    );
  }
  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddCustomerDialog(),
    );
  }
  void _showAddVendorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddVendorDialog(),
    );
  }

}
