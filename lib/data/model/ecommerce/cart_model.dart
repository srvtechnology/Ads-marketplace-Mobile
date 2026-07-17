import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';

class EcommerceCartItemModel {
  final int id;
  final int productId;
  final int productVariantId;
  final double price;
  final int qty;
  final double subtotal;
  final EcommerceProductModel? product;
  final EcommerceVariantModel? variant;

  EcommerceCartItemModel({
    required this.id,
    required this.productId,
    required this.productVariantId,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.product,
    this.variant,
  });

  factory EcommerceCartItemModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCartItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productVariantId: json['product_varient_id'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      qty: json['qty'] ?? 1,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      product: json['product'] != null && json['product'] is Map 
          ? EcommerceProductModel.fromJson(json['product']) 
          : null,
      variant: json['variant'] != null && json['variant'] is Map 
          ? EcommerceVariantModel.fromJson(json['variant']) 
          : null,
    );
  }
}

class EcommerceCartModel {
  final List<EcommerceCartItemModel> items;
  final double grandTotal;

  EcommerceCartModel({
    required this.items,
    required this.grandTotal,
  });

  factory EcommerceCartModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCartModel(
      items: (json['items'] as List?)?.map((e) => EcommerceCartItemModel.fromJson(e)).toList() ?? [],
      grandTotal: double.tryParse(json['grand_total'].toString()) ?? 0.0,
    );
  }
}
