class EcommerceCheckoutModel {
  final int id;
  final int customerId;
  final String checkoutNo;
  final String name;
  final String email;
  final String mobile;
  final String shippingAddress;
  final String shippingZipcode;
  final String shippingLandmark;
  final String paymentMode;
  final double totalAmount;
  final String status;

  EcommerceCheckoutModel({
    required this.id,
    required this.customerId,
    required this.checkoutNo,
    required this.name,
    required this.email,
    required this.mobile,
    required this.shippingAddress,
    required this.shippingZipcode,
    required this.shippingLandmark,
    required this.paymentMode,
    required this.totalAmount,
    required this.status,
  });

  factory EcommerceCheckoutModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCheckoutModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      checkoutNo: json['checkout_no'] is String ? json['checkout_no'] : '',
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String ? json['email'] : '',
      mobile: json['mobile'] is String ? json['mobile'] : '',
      shippingAddress: json['shipping_address'] is String ? json['shipping_address'] : '',
      shippingZipcode: json['shipping_zipcode'] is String ? json['shipping_zipcode'] : '',
      shippingLandmark: json['shipping_landmark'] is String ? json['shipping_landmark'] : '',
      paymentMode: json['payment_mode'] is String ? json['payment_mode'] : '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] is String ? json['status'] : '',
    );
  }
}
