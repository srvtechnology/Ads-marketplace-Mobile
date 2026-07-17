class EcommerceCategoryModel {
  final int id;
  final String name;
  final String status;
  final int? ecommerceCategoryId;

  EcommerceCategoryModel({
    required this.id,
    required this.name,
    required this.status,
    this.ecommerceCategoryId,
  });

  factory EcommerceCategoryModel.fromJson(Map<String, dynamic> json) {
    return EcommerceCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      ecommerceCategoryId: json['ecommerce_category_id'],
    );
  }
}
