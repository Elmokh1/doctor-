class InvoiceModel {
  final String id;
  final String name; // اسم العميل أو المورد
  final String entityId; // كود العميل أو المورد
  final double amount;
  final double oldBalance;
  final double newBalance;
  final double cashBoxBefore;
  final double cashBoxAfter;
  final String transactionDetails;
  final DateTime dateTime;

  InvoiceModel({
    required this.id,
    required this.name,
    required this.entityId,
    required this.amount,
    required this.oldBalance,
    required this.newBalance,
    required this.cashBoxBefore,
    required this.cashBoxAfter,
    required this.transactionDetails,
    required this.dateTime,
  });
}
