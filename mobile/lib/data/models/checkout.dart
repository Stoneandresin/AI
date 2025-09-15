class Checkout {
  final String jobId;
  final String itemId;
  final int quantity;
  final DateTime outTs;
  final DateTime? dueTs;
  final DateTime? returnedTs;

  const Checkout({
    required this.jobId,
    required this.itemId,
    required this.quantity,
    required this.outTs,
    this.dueTs,
    this.returnedTs,
  });
}
