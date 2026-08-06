import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';

class EcommerceCartItemBreakdownModel {
  final int cartItemId;
  final String title;
  final String platform;
  final String sourceUrl;
  final String placedOn;
  final String image;
  final int quantity;
  final String currency;
  final String? variants;
  final double itemTotal;
  final double serviceCharges;
  final double deliveryCharges;
  final double shipmentChargeTillJaigaon;
  final double gst5Percent;
  final double totalPrice;

  EcommerceCartItemBreakdownModel({
    required this.cartItemId,
    required this.title,
    required this.platform,
    required this.sourceUrl,
    required this.placedOn,
    required this.image,
    required this.quantity,
    required this.currency,
    this.variants,
    required this.itemTotal,
    required this.serviceCharges,
    required this.deliveryCharges,
    required this.shipmentChargeTillJaigaon,
    required this.gst5Percent,
    required this.totalPrice,
  });

  factory EcommerceCartItemBreakdownModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment_detail'] as Map<String, dynamic>? ?? {};
    return EcommerceCartItemBreakdownModel(
      cartItemId: json['cart_item_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ?? '',
      placedOn: json['placed_on']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
      currency: json['currency']?.toString() ?? 'Nu. ',
      variants: json['variants']?.toString() ?? json['variant_details']?.toString(),
      itemTotal: double.tryParse(payment['item_total']?.toString() ?? '0') ?? 0.0,
      serviceCharges: double.tryParse(payment['service_charges']?.toString() ?? '0') ?? 0.0,
      deliveryCharges: double.tryParse(payment['delivery_charges']?.toString() ?? '0') ?? 0.0,
      shipmentChargeTillJaigaon: double.tryParse(payment['shipment_charge_till_jaigaon']?.toString() ?? '0') ?? 0.0,
      gst5Percent: double.tryParse(payment['gst_5_percent']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(payment['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class EcommerceCartItemModel {
  final int id;
  final int productId;
  final int productVariantId;
  final double price;
  final int qty;
  final double subtotal;
  final bool isSelected;
  final EcommerceProductModel? product;
  final EcommerceVariantModel? variant;
  final String? variants;
  final String? platform;
  final String? url;
  final String? importedDate;

  EcommerceCartItemModel({
    required this.id,
    required this.productId,
    required this.productVariantId,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.isSelected = true,
    this.product,
    this.variant,
    this.variants,
    this.platform,
    this.url,
    this.importedDate,
  });

  String get displayVariants {
    final String? v = variants ?? variant?.variantName;
    if (v != null && v.trim().isNotEmpty) {
      return v.trim();
    }
    return '';
  }

  factory EcommerceCartItemModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCartItemModel(
      id: json['id'] ?? json['cart_item_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productVariantId: json['product_varient_id'] ?? 0,
      price: double.tryParse((json['price'] ?? json['unit_price'] ?? 0).toString()) ?? 0.0,
      qty: json['qty'] ?? json['quantity'] ?? 1,
      subtotal: double.tryParse((json['subtotal'] ?? json['total_calculated_price'] ?? 0).toString()) ?? 0.0,
      isSelected: json['is_selected'] ?? true,
      product: json['product'] != null && json['product'] is Map 
          ? EcommerceProductModel.fromJson(json['product']) 
          : (json['title'] != null || json['name'] != null ? EcommerceProductModel(
              id: json['product_id'] ?? 0, 
              name: json['title'] ?? json['name'] ?? 'Unknown Product',
              description: json['brand'] ?? json['platform'],
              ecommerceCategoryId: 0,
              ecommerceSubcategoryId: 0,
              platformId: 0,
              images: [],
              imageUrl: json['image'] ?? json['image_url'] ?? '',
              variants: [],
            ) : null),
      variant: json['variant'] != null && json['variant'] is Map 
          ? EcommerceVariantModel.fromJson(json['variant']) 
          : (json['variants'] != null ? EcommerceVariantModel(
              id: json['product_varient_id'] ?? 0,
              productId: json['product_id'] ?? 0,
              price: double.tryParse((json['price'] ?? json['unit_price'] ?? 0).toString()) ?? 0.0,
              variantName: json['variants'].toString(),
            ) : null),
      variants: json['variants']?.toString() ?? json['variant_details']?.toString(),
      platform: json['platform']?.toString(),
      url: json['url']?.toString(),
      importedDate: json['imported_date']?.toString(),
    );
  }
}

class EcommerceCartModel {
  final List<EcommerceCartItemModel> items;
  final double grandTotal;
  final String currency;
  final int totalItemsCount;
  final bool isAllSelected;

  EcommerceCartModel({
    required this.items,
    required this.grandTotal,
    this.currency = 'Nu. ',
    this.totalItemsCount = 0,
    this.isAllSelected = false,
  });

  factory EcommerceCartModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCartModel(
      items: (json['items'] as List?)?.map((e) => EcommerceCartItemModel.fromJson(e)).toList() ?? [],
      grandTotal: double.tryParse((json['summary']?['grand_total'] ?? json['grand_total'] ?? 0).toString()) ?? 0.0,
      currency: json['currency']?.toString() ?? 'Nu. ',
      totalItemsCount: json['total_items_count'] ?? 0,
      isAllSelected: json['is_all_selected'] ?? false,
    );
  }
}
