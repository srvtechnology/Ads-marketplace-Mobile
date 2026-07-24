import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';

class EcommerceOrderPaymentDetailModel {
  final double itemsSubtotal;
  final double totalServiceCharge;
  final double totalDeliveryCharge;
  final double totalShipmentCharge;
  final double totalGstAmount;
  final double grandTotal;

  EcommerceOrderPaymentDetailModel({
    required this.itemsSubtotal,
    required this.totalServiceCharge,
    required this.totalDeliveryCharge,
    required this.totalShipmentCharge,
    required this.totalGstAmount,
    required this.grandTotal,
  });

  factory EcommerceOrderPaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return EcommerceOrderPaymentDetailModel(
      itemsSubtotal: double.tryParse(json['items_subtotal']?.toString() ?? '0') ?? 0.0,
      totalServiceCharge: double.tryParse(json['total_service_charge']?.toString() ?? '0') ?? 0.0,
      totalDeliveryCharge: double.tryParse(json['total_delivery_charge']?.toString() ?? '0') ?? 0.0,
      totalShipmentCharge: double.tryParse(json['total_shipment_charge']?.toString() ?? '0') ?? 0.0,
      totalGstAmount: double.tryParse(json['total_gst_amount']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class EcommerceOrderModel {
  final int? id;
  final int? customerId;
  final String? orderId;
  final String? name;
  final String? email;
  final String? countryCode;
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
  final String? placedOn;
  final String? createdAt;
  final String? updatedAt;
  final EcommerceOrderPaymentDetailModel? paymentDetail;
  final List<EcommerceOrderItemModel> items;

  EcommerceOrderModel({
    this.id,
    this.customerId,
    this.orderId,
    this.name,
    this.email,
    this.countryCode,
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
    this.placedOn,
    this.createdAt,
    this.updatedAt,
    this.paymentDetail,
    this.items = const [],
  });

  factory EcommerceOrderModel.fromJson(Map<String, dynamic> json) {
    return EcommerceOrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      orderId: json['order_id']?.toString() ?? json['order_no']?.toString(),
      name: json['name'],
      email: json['email'],
      countryCode: json['country_code']?.toString(),
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
      placedOn: json['placed_on']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      paymentDetail: json['payment_detail'] != null && json['payment_detail'] is Map
          ? EcommerceOrderPaymentDetailModel.fromJson(json['payment_detail'])
          : null,
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
      'order_id': orderId,
      'name': name,
      'email': email,
      'country_code': countryCode,
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
      'placed_on': placedOn,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class EcommerceOrderItemModel {
  final int? id;
  final int? itemId;
  final int? orderId;
  final int? productId;
  final int? productVariantId;
  final String? title;
  final String? platform;
  final String? sourceUrl;
  final String? image;
  final String? price;
  final int? qty;
  final String? subtotal;
  final String? variantDetails;
  final double serviceCharge;
  final double deliveryCharge;
  final double shipmentCharge;
  final double gstCharge;
  final double gstAmount;
  final double finalAmount;
  final EcommerceProductModel? product;
  final EcommerceVariantModel? variant;

  EcommerceOrderItemModel({
    this.id,
    this.itemId,
    this.orderId,
    this.productId,
    this.productVariantId,
    this.title,
    this.platform,
    this.sourceUrl,
    this.image,
    this.price,
    this.qty,
    this.subtotal,
    this.variantDetails,
    this.serviceCharge = 0.0,
    this.deliveryCharge = 0.0,
    this.shipmentCharge = 0.0,
    this.gstCharge = 0.0,
    this.gstAmount = 0.0,
    this.finalAmount = 0.0,
    this.product,
    this.variant,
  });

  factory EcommerceOrderItemModel.fromJson(Map<String, dynamic> json) {
    String? itemTitle = json['title']?.toString() ?? json['name']?.toString();
    String? itemImage = json['image']?.toString() ?? json['image_url']?.toString();
    int quantity = json['quantity'] is int
        ? json['quantity']
        : (json['qty'] is String ? int.tryParse(json['qty']) ?? 1 : json['qty'] ?? 1);

    return EcommerceOrderItemModel(
      id: json['id'] ?? json['item_id'],
      itemId: json['item_id'] ?? json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productVariantId: json['product_varient_id'],
      title: itemTitle,
      platform: json['platform']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      image: itemImage,
      price: (json['unit_price'] ?? json['price'])?.toString(),
      qty: quantity,
      subtotal: (json['final_amount'] ?? json['subtotal'])?.toString(),
      variantDetails: json['variant_details']?.toString(),
      serviceCharge: double.tryParse(json['service_charge']?.toString() ?? '0') ?? 0.0,
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '0') ?? 0.0,
      shipmentCharge: double.tryParse(json['shipment_charge']?.toString() ?? '0') ?? 0.0,
      gstCharge: double.tryParse(json['gst_charge']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0.0,
      product: json['product'] != null && json['product'] is Map
          ? EcommerceProductModel.fromJson(json['product'])
          : (itemTitle != null ? EcommerceProductModel(
              id: json['product_id'] ?? 0,
              name: itemTitle,
              description: json['platform']?.toString(),
              ecommerceCategoryId: 0,
              ecommerceSubcategoryId: 0,
              platformId: 0,
              images: [],
              imageUrl: itemImage ?? '',
              variants: [],
            ) : null),
      variant: json['variant'] != null && json['variant'] is Map
          ? EcommerceVariantModel.fromJson(json['variant'])
          : (json['variant_details'] != null ? EcommerceVariantModel(
              id: json['product_varient_id'] ?? 0,
              productId: json['product_id'] ?? 0,
              price: double.tryParse((json['unit_price'] ?? json['price'] ?? 0).toString()) ?? 0.0,
              variantName: json['variant_details'].toString(),
            ) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'order_id': orderId,
      'product_id': productId,
      'product_varient_id': productVariantId,
      'title': title,
      'platform': platform,
      'source_url': sourceUrl,
      'image': image,
      'price': price,
      'qty': qty,
      'subtotal': subtotal,
      'variant_details': variantDetails,
      'product': product?.toJson(),
      'variant': variant?.toJson(),
    };
  }
}
