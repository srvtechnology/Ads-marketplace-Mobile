import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';

class EcommerceOrderModel {
  final int? id;
  final int? customerId;
  final String? orderNo;
  final String? name;
  final String? email;
  final String? mobile;
  final String? shippingAddress;
  final String? shippingZipcode;
  final String? shippingLandmark;
  final String? billingAddress;
  final String? billingZipcode;
  final String? billingLandmark;
  final String? paymentMode;
  final String? totalAmount;
  final String? status;
  final String? remarks;
  final String? statusRemarks;
  final String? createdAt;
  final String? updatedAt;
  final List<EcommerceOrderItemModel> items;

  EcommerceOrderModel({
    this.id,
    this.customerId,
    this.orderNo,
    this.name,
    this.email,
    this.mobile,
    this.shippingAddress,
    this.shippingZipcode,
    this.shippingLandmark,
    this.billingAddress,
    this.billingZipcode,
    this.billingLandmark,
    this.paymentMode,
    this.totalAmount,
    this.status,
    this.remarks,
    this.statusRemarks,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory EcommerceOrderModel.fromJson(Map<String, dynamic> json) {
    return EcommerceOrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      orderNo: json['order_no'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      shippingAddress: json['shipping_address'],
      shippingZipcode: json['shipping_zipcode']?.toString(),
      shippingLandmark: json['shipping_landmark']?.toString(),
      billingAddress: json['billing_address'],
      billingZipcode: json['billing_zipcode']?.toString(),
      billingLandmark: json['billing_landmark']?.toString(),
      paymentMode: json['payment_mode'],
      totalAmount: json['total_amount']?.toString(),
      status: json['status'],
      remarks: json['remarks'],
      statusRemarks: json['status_remarks'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      items: (json['items'] as List?)
              ?.map((e) => EcommerceOrderItemModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_no': orderNo,
      'name': name,
      'email': email,
      'mobile': mobile,
      'shipping_address': shippingAddress,
      'shipping_zipcode': shippingZipcode,
      'shipping_landmark': shippingLandmark,
      'billing_address': billingAddress,
      'billing_zipcode': billingZipcode,
      'billing_landmark': billingLandmark,
      'payment_mode': paymentMode,
      'total_amount': totalAmount,
      'status': status,
      'remarks': remarks,
      'status_remarks': statusRemarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class EcommerceOrderItemModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? productVariantId;
  final String? price;
  final int? qty;
  final String? subtotal;
  final EcommerceProductModel? product;
  final EcommerceVariantModel? variant;

  EcommerceOrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    this.productVariantId,
    this.price,
    this.qty,
    this.subtotal,
    this.product,
    this.variant,
  });

  factory EcommerceOrderItemModel.fromJson(Map<String, dynamic> json) {
    return EcommerceOrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productVariantId: json['product_varient_id'],
      price: json['price']?.toString(),
      qty: json['qty'] is String ? int.tryParse(json['qty']) : json['qty'],
      subtotal: json['subtotal']?.toString(),
      product: json['product'] != null
          ? EcommerceProductModel.fromJson(json['product'])
          : null,
      variant: json['variant'] != null
          ? EcommerceVariantModel.fromJson(json['variant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_varient_id': productVariantId,
      'price': price,
      'qty': qty,
      'subtotal': subtotal,
      'product': product?.toJson(),
      'variant': variant?.toJson(),
    };
  }
}
