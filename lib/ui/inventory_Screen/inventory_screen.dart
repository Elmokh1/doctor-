import 'package:easy_localization/easy_localization.dart';
import 'package:el_doctor/ui/inventory_Screen/widgets/store_table_widget.dart';
import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title:  Text("inventory".tr()),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 3,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: StoreTableWidget()),
            ],
          ),
        ),
      ),
    );
  }

}



