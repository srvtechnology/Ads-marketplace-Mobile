class EcommerceVariantModel {
  final int id;
  final int productId;
  final double price;
  final String? variantName;

  EcommerceVariantModel({
    required this.id,
    required this.productId,
    required this.price,
    this.variantName,
  });

  factory EcommerceVariantModel.fromJson(Map<String, dynamic> json) {
    return EcommerceVariantModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      variantName: json['variant_name'] is String 
          ? json['variant_name'] 
          : (json['name'] is String ? json['name'] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'price': price,
      'variant_name': variantName,
    };
  }
}

class EcommerceProductModel {
  final int id;
  final String name;
  final String? description;
  final int ecommerceCategoryId;
  final int ecommerceSubcategoryId;
  final int platformId;
  final List<String> images;
  final String imageUrl;
  final List<EcommerceVariantModel> variants;

  EcommerceProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.ecommerceCategoryId,
    required this.ecommerceSubcategoryId,
    required this.platformId,
    required this.images,
    required this.imageUrl,
    required this.variants,
  });

  factory EcommerceProductModel.fromJson(Map<String, dynamic> json) {
    return EcommerceProductModel(
      id: json['id'] ?? 0,
      name: json['name'] is String ? json['name'] : '',
      description: json['description']?.toString(),
      ecommerceCategoryId: json['ecommerce_category_id'] ?? 0,
      ecommerceSubcategoryId: json['ecommerce_subcategory_id'] ?? 0,
      platformId: json['platform_id'] ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      imageUrl: json['image_url'] is String 
          ? json['image_url'] 
          : (json['image'] is String ? json['image'] : ''),
      variants: (json['variants'] as List?)?.map((e) => EcommerceVariantModel.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ecommerce_category_id': ecommerceCategoryId,
      'ecommerce_subcategory_id': ecommerceSubcategoryId,
      'platform_id': platformId,
      'images': images,
      'image_url': imageUrl,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}
