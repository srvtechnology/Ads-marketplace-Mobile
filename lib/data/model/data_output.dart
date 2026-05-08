import 'package:eClassify/data/model/category_banner_model.dart';
import 'package:flutter/material.dart';

class DataOutput<T> {
  final int total;
  final List<T> modelList;
  final ExtraData? extraData;
  final int? page;
  final CategoryBannerModel? banner;

  DataOutput({
    required this.total,
    required this.modelList,
    this.extraData,
    this.page,
    this.banner,
  });

  DataOutput<T> copyWith({
    int? total,
    List<T>? modelList,
    ExtraData? extraData,
    int? page,
    CategoryBannerModel? banner,
  }) {
    return DataOutput<T>(
      total: total ?? this.total,
      modelList: modelList ?? this.modelList,
      extraData: extraData ?? this.extraData,
      page: page ?? this.page,
      banner: banner ?? this.banner,
    );
  }
}

@protected
class ExtraData<T> {
  final T data;

  ExtraData({
    required this.data,
  });
}
