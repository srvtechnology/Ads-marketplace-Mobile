class ConditionModel {
  int? id;
  String? name;
  String? status;
  String? createdAt;
  String? updatedAt;

  ConditionModel({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ConditionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
