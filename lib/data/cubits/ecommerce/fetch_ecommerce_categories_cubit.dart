import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_category_model.dart';
import 'package:eClassify/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchEcommerceCategoriesState {}

class FetchEcommerceCategoriesInitial extends FetchEcommerceCategoriesState {}
class FetchEcommerceCategoriesInProgress extends FetchEcommerceCategoriesState {}
class FetchEcommerceCategoriesSuccess extends FetchEcommerceCategoriesState {
  final List<EcommerceCategoryModel> categories;
  FetchEcommerceCategoriesSuccess(this.categories);
}
class FetchEcommerceCategoriesFailure extends FetchEcommerceCategoriesState {
  final String errorMessage;
  FetchEcommerceCategoriesFailure(this.errorMessage);
}

class FetchEcommerceCategoriesCubit extends Cubit<FetchEcommerceCategoriesState> {
  FetchEcommerceCategoriesCubit() : super(FetchEcommerceCategoriesInitial());

  Future<void> fetchCategories() async {
    try {
      emit(FetchEcommerceCategoriesInProgress());
      print('Fetching categories from API...');
      final Dio dio = Dio();
      final response = await dio.get('${AppSettings.ecommerceHostUrl}/api/ecommerce/categories');
      print('Categories API Response: ${response.data}');
      
      if (response.statusCode == 200 && 
          (response.data['success'] == true || response.data['error'] == false)) {
        List data = response.data['data'] ?? [];
        List<EcommerceCategoryModel> categories = data.map((e) => EcommerceCategoryModel.fromJson(e)).toList();
        emit(FetchEcommerceCategoriesSuccess(categories));
      } else {
        emit(FetchEcommerceCategoriesFailure("Failed to fetch categories"));
      }
    } catch (e) {
      print('Categories API Error: $e');
      emit(FetchEcommerceCategoriesFailure(e.toString()));
    }
  }
}
