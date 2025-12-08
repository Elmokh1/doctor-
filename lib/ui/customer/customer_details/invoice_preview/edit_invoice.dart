import 'package:flutter/material.dart';

class EditCustomerInvoice extends StatelessWidget {
  final String invoiceId;

  EditCustomerInvoice({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.red,
      ),
    );
  }
}
