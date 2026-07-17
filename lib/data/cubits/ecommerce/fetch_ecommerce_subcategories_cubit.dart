import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchEcommerceSubcategoriesState {}

class FetchEcommerceSubcategoriesInitial extends FetchEcommerceSubcategoriesState {}
class FetchEcommerceSubcategoriesInProgress extends FetchEcommerceSubcategoriesState {}
class FetchEcommerceSubcategoriesSuccess extends FetchEcommerceSubcategoriesState {
  final List<EcommerceCategoryModel> subcategories;
  FetchEcommerceSubcategoriesSuccess(this.subcategories);
}
class FetchEcommerceSubcategoriesFailure extends FetchEcommerceSubcategoriesState {
  final String errorMessage;
  FetchEcommerceSubcategoriesFailure(this.errorMessage);
}

class FetchEcommerceSubcategoriesCubit extends Cubit<FetchEcommerceSubcategoriesState> {
  FetchEcommerceSubcategoriesCubit() : super(FetchEcommerceSubcategoriesInitial());

  Future<void> fetchSubcategories(int categoryId) async {
    try {
      emit(FetchEcommerceSubcategoriesInProgress());
      print('Fetching subcategories from API for category: $categoryId...');
      final Dio dio = Dio();
      final response = await dio.get('https://ecommerce.thebhutanmarket.com/api/ecommerce/subcategories/$categoryId');
      print('Subcategories API Response: ${response.data}');
      
      if (response.statusCode == 200 && 
          (response.data['success'] == true || response.data['error'] == false)) {
        List data = response.data['data'] ?? [];
        List<EcommerceCategoryModel> subcategories = data.map((e) => EcommerceCategoryModel.fromJson(e)).toList();
        emit(FetchEcommerceSubcategoriesSuccess(subcategories));
      } else {
        emit(FetchEcommerceSubcategoriesFailure("Failed to fetch subcategories"));
      }
    } catch (e) {
      print('Subcategories API Error: $e');
      emit(FetchEcommerceSubcategoriesFailure(e.toString()));
    }
  }

  void clearSubcategories() {
    emit(FetchEcommerceSubcategoriesInitial());
  }
}
