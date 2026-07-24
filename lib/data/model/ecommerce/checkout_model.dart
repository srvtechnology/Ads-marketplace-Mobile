class EcommerceCheckoutModel {
  final int id;
  final String orderId;
  final double totalAmount;
  final String? paymentUrl;
  final String? message;

  EcommerceCheckoutModel({
    required this.id,
    required this.orderId,
    required this.totalAmount,
    this.paymentUrl,
    this.message,
  });

  factory EcommerceCheckoutModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCheckoutModel(
      id: json['id'] ?? 0,
      orderId: json['order_id']?.toString() ?? json['checkout_no']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentUrl: json['payment_url']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
