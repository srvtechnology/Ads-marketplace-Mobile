class EcommerceCheckoutModel {
  final int id;
  final String orderId;
  final String? deliveryOtp;
  final double totalAmount;
  final String? paymentUrl;
  final String? message;

  EcommerceCheckoutModel({
    required this.id,
    required this.orderId,
    this.deliveryOtp,
    required this.totalAmount,
    this.paymentUrl,
    this.message,
  });

  factory EcommerceCheckoutModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCheckoutModel(
      id: json['id'] ?? 0,
      orderId: json['order_id']?.toString() ?? json['checkout_no']?.toString() ?? '',
      deliveryOtp: json['delivery_otp']?.toString() ?? json['otp']?.toString(),
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentUrl: json['payment_url']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
