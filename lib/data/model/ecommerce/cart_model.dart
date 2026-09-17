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
  final String? checkoutProduct;
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
    this.checkoutProduct,
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

  EcommerceCartItemModel copyWith({
    int? id,
    int? productId,
    int? productVariantId,
    double? price,
    int? qty,
    double? subtotal,
    bool? isSelected,
    String? checkoutProduct,
    EcommerceProductModel? product,
    EcommerceVariantModel? variant,
    String? variants,
    String? platform,
    String? url,
    String? importedDate,
  }) {
    return EcommerceCartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productVariantId: productVariantId ?? this.productVariantId,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      isSelected: isSelected ?? this.isSelected,
      checkoutProduct: checkoutProduct ?? this.checkoutProduct,
      product: product ?? this.product,
      variant: variant ?? this.variant,
      variants: variants ?? this.variants,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      importedDate: importedDate ?? this.importedDate,
    );
  }

  factory EcommerceCartItemModel.fromJson(Map<String, dynamic> json) {
    bool selected = true;
    if (json['is_selected'] != null) {
      if (json['is_selected'] is bool) {
        selected = json['is_selected'];
      } else if (json['is_selected'] is num) {
        selected = json['is_selected'] == 1;
      } else {
        selected = json['is_selected'].toString().toLowerCase() == 'true' ||
            json['is_selected'].toString() == '1';
      }
    } else if (json['checkout_product'] != null) {
      selected = json['checkout_product'].toString().toUpperCase() == 'Y';
    }

    return EcommerceCartItemModel(
      id: json['id'] ?? json['cart_item_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productVariantId: json['product_varient_id'] ?? 0,
      price: double.tryParse((json['price'] ?? json['unit_price'] ?? 0).toString()) ?? 0.0,
      qty: json['qty'] ?? json['quantity'] ?? 1,
      subtotal: double.tryParse((json['subtotal'] ?? json['total_calculated_price'] ?? 0).toString()) ?? 0.0,
      isSelected: selected,
      checkoutProduct: json['checkout_product']?.toString(),
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
      platform: json['platform']?.toString() ?? json['brand']?.toString(),
      url: json['url']?.toString() ?? json['source_url']?.toString(),
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
  final int selectedItemsCount;

  EcommerceCartModel({
    required this.items,
    required this.grandTotal,
    this.currency = 'Nu. ',
    this.totalItemsCount = 0,
    this.isAllSelected = false,
    this.selectedItemsCount = 0,
  });

  List<int> get selectedIds =>
      items.where((e) => e.isSelected).map((e) => e.id).toList();

  bool get hasSelectedItems => items.any((e) => e.isSelected);

  EcommerceCartModel copyWith({
    List<EcommerceCartItemModel>? items,
    double? grandTotal,
    String? currency,
    int? totalItemsCount,
    bool? isAllSelected,
    int? selectedItemsCount,
  }) {
    return EcommerceCartModel(
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
      currency: currency ?? this.currency,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      selectedItemsCount: selectedItemsCount ?? this.selectedItemsCount,
    );
  }

  factory EcommerceCartModel.fromJson(Map<String, dynamic> json) {
    final parsedItems = (json['items'] as List?)
            ?.map((e) => EcommerceCartItemModel.fromJson(e))
            .toList() ??
        [];

    final int selectedCount = json['summary']?['selected_items_count'] ??
        parsedItems.where((e) => e.isSelected).length;

    final bool allSelected = json['is_all_selected'] ??
        (parsedItems.isNotEmpty && parsedItems.every((e) => e.isSelected));

    return EcommerceCartModel(
      items: parsedItems,
      grandTotal: double.tryParse((json['cart_grand_total'] ??
              json['summary']?['grand_total'] ??
              json['grand_total'] ??
              0)
          .toString()) ??
          0.0,
      currency: json['currency']?.toString() ?? 'Nu. ',
      totalItemsCount: json['total_items_count'] ?? parsedItems.length,
      isAllSelected: allSelected,
      selectedItemsCount: selectedCount,
    );
  }
}
