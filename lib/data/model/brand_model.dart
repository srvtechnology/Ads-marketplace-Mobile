class BrandModel {
  final int id;
  final String name;
  final String description;
  final String image;
  final String status;

  BrandModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.status,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
