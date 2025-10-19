import 'package:flutter/material.dart';

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
          SlideBarItem(Icons.home, "الصفحة الرئيسية"),
          SlideBarItem(Icons.attach_money, "الدخل"),
          SlideBarItem(Icons.money_off, "المصروفات"),
          SlideBarItem(Icons.bar_chart, "التقارير"),
        ],
      ),
    );
  }
}
