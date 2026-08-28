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

class BfsTransactionModel {
  final int? id;
  final String? bfsTxnId;
  final String? status;
  final String? bankId;
  final String? accountNo;
  final double amount;
  final String? responseCode;
  final String? responseDesc;

  BfsTransactionModel({
    this.id,
    this.bfsTxnId,
    this.status,
    this.bankId,
    this.accountNo,
    this.amount = 0.0,
    this.responseCode,
    this.responseDesc,
  });

  factory BfsTransactionModel.fromJson(Map<String, dynamic> json) {
    return BfsTransactionModel(
      id: json['id'],
      bfsTxnId: json['bfs_txn_id']?.toString(),
      status: json['status']?.toString(),
      bankId: json['bank_id']?.toString(),
      accountNo: json['account_no']?.toString(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      responseCode: json['response_code']?.toString(),
      responseDesc: json['response_desc']?.toString(),
    );
  }
}

class EcommerceOrderModel {
  final int? id;
  final int? customerId;
  final String? orderId;
  final String? deliveryOtp;
  final String? deliveryDate;
  final int? checkoutBfsTransactionId;
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
  final String? deliveryStatus;
  final String? remarks;
  final String? statusRemarks;
  final String? placedOn;
  final String? createdAt;
  final String? updatedAt;
  final EcommerceOrderPaymentDetailModel? paymentDetail;
  final BfsTransactionModel? bfsTransaction;
  final List<EcommerceOrderItemModel> items;

  EcommerceOrderModel({
    this.id,
    this.customerId,
    this.orderId,
    this.deliveryOtp,
    this.deliveryDate,
    this.checkoutBfsTransactionId,
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
    this.deliveryStatus,
    this.remarks,
    this.statusRemarks,
    this.placedOn,
    this.createdAt,
    this.updatedAt,
    this.paymentDetail,
    this.bfsTransaction,
    this.items = const [],
  });

  bool get isCancellable {
    final s = (status ?? deliveryStatus ?? '').toUpperCase().trim();
    if (s.isEmpty) return true;
    if (s == 'CAN' ||
        s == 'CC' ||
        s == 'CANCELLED' ||
        s == 'PCAN' ||
        s == 'PARTIALLY CANCELLED' ||
        s == 'PARTIALLY_CANCELLED' ||
        s == 'DELIVERED' ||
        s == 'PDELIVERED' ||
        s == 'PARTIALLY DELIVERED' ||
        s == 'PARTIALLY_DELIVERED' ||
        s == 'RE' ||
        s == 'REJECTED' ||
        s == 'PRE' ||
        s == 'PARTIALLY REJECTED' ||
        s == 'PARTIALLY_REJECTED') {
      return false;
    }
    return true;
  }

  factory EcommerceOrderModel.fromJson(Map<String, dynamic> json) {
    return EcommerceOrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      orderId: json['order_id']?.toString() ?? json['order_no']?.toString(),
      deliveryOtp: json['delivery_otp']?.toString() ?? json['otp']?.toString(),
      deliveryDate: json['delivery_date']?.toString() ?? json['expected_delivery_date']?.toString(),
      checkoutBfsTransactionId: json['checkout_bfs_transaction_id'] is int
          ? json['checkout_bfs_transaction_id']
          : int.tryParse(json['checkout_bfs_transaction_id']?.toString() ?? ''),
      name: json['name'],
      email: json['email'],
      countryCode: json['country_code']?.toString(),
      mobile: json['mobile']?.toString(),
      shippingAddress: json['shipping_address']?.toString(),
      shippingZipcode: json['shipping_zipcode']?.toString(),
      shippingLandmark: json['shipping_landmark']?.toString(),
      billingAddress: json['billing_address']?.toString(),
      billingZipcode: json['billing_zipcode']?.toString(),
      billingLandmark: json['billing_landmark']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? json['payment_detail']?['grand_total']?.toString(),
      status: json['status']?.toString(),
      deliveryStatus: json['delivery_status']?.toString() ?? json['status_label']?.toString(),
      remarks: json['remarks']?.toString(),
      statusRemarks: json['status_remarks']?.toString(),
      placedOn: json['placed_on']?.toString() ?? json['created_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      paymentDetail: json['payment_detail'] != null && json['payment_detail'] is Map
          ? EcommerceOrderPaymentDetailModel.fromJson(Map<String, dynamic>.from(json['payment_detail']))
          : null,
      bfsTransaction: json['bfs_transaction'] != null && json['bfs_transaction'] is Map
          ? BfsTransactionModel.fromJson(Map<String, dynamic>.from(json['bfs_transaction']))
          : null,
      items: (json['items'] as List?)
              ?.map((e) => EcommerceOrderItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_id': orderId,
      'delivery_otp': deliveryOtp,
      'delivery_date': deliveryDate,
      'checkout_bfs_transaction_id': checkoutBfsTransactionId,
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
      'delivery_status': deliveryStatus,
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
  final double unitPrice;
  final int? qty;
  final String? subtotal;
  final String? variantDetails;
  final String? status;
  final String? statusLabel;
  final String? deliveryStatus;
  final String? deliveryDate;
  final String? orderNo;
  final String? remarks;
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
    this.unitPrice = 0.0,
    this.qty,
    this.subtotal,
    this.variantDetails,
    this.status,
    this.statusLabel,
    this.deliveryStatus,
    this.deliveryDate,
    this.orderNo,
    this.remarks,
    this.serviceCharge = 0.0,
    this.deliveryCharge = 0.0,
    this.shipmentCharge = 0.0,
    this.gstCharge = 0.0,
    this.gstAmount = 0.0,
    this.finalAmount = 0.0,
    this.product,
    this.variant,
  });

  String? get displayVariantDetails {
    final String? v = variantDetails ?? variant?.variantName;
    if (v != null && v.trim().isNotEmpty && v.trim().toLowerCase() != 'null') {
      return v.trim();
    }
    return null;
  }

  /// Returns effective item-wise status label or status code
  String? get effectiveStatus => statusLabel ?? status ?? deliveryStatus;

  double get effectiveUnitPrice => unitPrice > 0 ? unitPrice : (double.tryParse(price ?? '0') ?? 0.0);

  factory EcommerceOrderItemModel.fromJson(Map<String, dynamic> json) {
    String? itemTitle = json['title']?.toString() ?? json['name']?.toString();
    String? itemImage = json['image']?.toString() ?? json['image_url']?.toString();
    int quantity = json['quantity'] is int
        ? json['quantity']
        : (json['qty'] is String ? int.tryParse(json['qty']) ?? 1 : json['qty'] ?? 1);

    String? vDetails = json['variant_details']?.toString() ?? 
        json['variants']?.toString() ?? 
        json['variant_name']?.toString() ??
        (json['variant'] is Map ? (json['variant']['variant_name'] ?? json['variant']['name'])?.toString() : null);

    if (vDetails?.trim().toLowerCase() == 'null' || vDetails?.trim().isEmpty == true) {
      vDetails = null;
    }

    double parsedUnitPrice = double.tryParse((json['unit_price'] ?? json['price'] ?? '0').toString()) ?? 0.0;

    return EcommerceOrderItemModel(
      id: json['id'] ?? json['item_id'],
      itemId: json['item_id'] ?? json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productVariantId: json['product_varient_id'] ?? json['product_variant_id'],
      title: itemTitle,
      platform: json['platform']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      image: itemImage,
      price: (json['unit_price'] ?? json['price'])?.toString(),
      unitPrice: parsedUnitPrice,
      qty: quantity,
      subtotal: (json['final_amount'] ?? json['subtotal'])?.toString(),
      variantDetails: vDetails,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      deliveryStatus: json['delivery_status']?.toString(),
      deliveryDate: json['delivery_date']?.toString() ?? json['expected_delivery_date']?.toString(),
      orderNo: json['order_no']?.toString(),
      remarks: json['remarks']?.toString(),
      serviceCharge: double.tryParse(json['service_charge']?.toString() ?? '0') ?? 0.0,
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '0') ?? 0.0,
      shipmentCharge: double.tryParse(json['shipment_charge']?.toString() ?? '0') ?? 0.0,
      gstCharge: double.tryParse(json['gst_charge']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0.0,
      product: json['product'] != null && json['product'] is Map
          ? EcommerceProductModel.fromJson(Map<String, dynamic>.from(json['product']))
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
          ? EcommerceVariantModel.fromJson(Map<String, dynamic>.from(json['variant']))
          : (vDetails != null ? EcommerceVariantModel(
              id: json['product_varient_id'] ?? json['product_variant_id'] ?? 0,
              productId: json['product_id'] ?? 0,
              price: parsedUnitPrice,
              variantName: vDetails,
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
      'unit_price': unitPrice,
      'qty': qty,
      'subtotal': subtotal,
      'variant_details': variantDetails,
      'status': status,
      'status_label': statusLabel,
      'delivery_status': deliveryStatus,
      'delivery_date': deliveryDate,
      'order_no': orderNo,
      'remarks': remarks,
      'service_charge': serviceCharge,
      'delivery_charge': deliveryCharge,
      'shipment_charge': shipmentCharge,
      'gst_charge': gstCharge,
      'gst_amount': gstAmount,
      'final_amount': finalAmount,
      'product': product?.toJson(),
      'variant': variant?.toJson(),
    };
  }
}
