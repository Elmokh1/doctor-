import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cubits/product_tranaction_cubit/product_transaction_cubit.dart';
import '../../cubits/product_tranaction_cubit/product_transaction_state.dart';
import '../../data/model/proudct_transaction_model.dart';
import '../customer/customer_details/invoice_preview.dart';
import '../vendors/vendors_details/bills_preview.dart';

class ProductTransactionsPage extends StatefulWidget {
  final String productId;
  final String productName;
  final String qun;

  const ProductTransactionsPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.qun,
  });

  @override
  State<ProductTransactionsPage> createState() =>
      _ProductTransactionsPageState();
}

class _ProductTransactionsPageState extends State<ProductTransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductTransactionCubit>().loadTransactions(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("product_movements".tr() + " — ${widget.productName}"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProductTransactionCubit, ProductTransactionState>(
        builder: (context, state) {
          if (state is ProductTransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductTransactionError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (state is ProductTransactionLoaded) {
            final List<ProductTransactionModel> items = state.transactions;

            if (items.isEmpty) {
              return Center(
                child: Text(
                  "no_movements_found".tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return SizedBox.expand(
              child: Column(
                children: [
                  // Header: Product Name + Quantity
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    color: Colors.black12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${"product".tr()}: ${widget.productName}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${"quantity".tr()}: ${widget.qun}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Table
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 48,
                          dataRowHeight: 44,
                          columnSpacing: 50,
                          border: TableBorder.all(color: Colors.black),
                          headingRowColor: MaterialStateProperty.all(Colors.black12),
                          columns: [
                            DataColumn(label: Text("name".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            DataColumn(label: Text("invoice_no".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            DataColumn(label: Text("type".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            DataColumn(label: Text("date".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            DataColumn(label: Text("quantity".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          ],
                          rows: items.map((t) {
                            return DataRow(
                              cells: [
                                DataCell(Text(t.name ?? "unknown".tr())),
                                DataCell(
                                  InkWell(
                                    child: Text(
                                      t.transactionNum ?? "-",
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    onTap: () {
                                      if (t.isCustomer == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CustomerInvoiceByIdScreen(
                                              invoiceId: t.transactionNum ?? "",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VendorBillByIdScreen(
                                              billId: t.transactionNum ?? "",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                DataCell(Text(t.transactionType ?? "")),
                                DataCell(Text(
                                  t.transactionDate != null
                                      ? t.transactionDate.toString().substring(0, 10)
                                      : "-",
                                )),
                                DataCell(Text("${t.qun ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
