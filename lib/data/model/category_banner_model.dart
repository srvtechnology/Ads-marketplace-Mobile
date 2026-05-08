class CategoryBannerModel {
  int? id;
  int? categoryId;
  String? image;
  String? endDate;
  bool? isActive;

  CategoryBannerModel({
    this.id,
    this.categoryId,
    this.image,
    this.endDate,
    this.isActive,
  });

  CategoryBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    image = json['image'];
    endDate = json['end_date'];
    isActive = json['is_active'] == true || json['is_active'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['image'] = image;
    data['end_date'] = endDate;
    data['is_active'] = isActive;
    return data;
  }
}
