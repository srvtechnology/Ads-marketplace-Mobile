import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';
import 'package:eClassify/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchEcommerceProductsState {}

class FetchEcommerceProductsInitial extends FetchEcommerceProductsState {}
class FetchEcommerceProductsInProgress extends FetchEcommerceProductsState {}
class FetchEcommerceProductsSuccess extends FetchEcommerceProductsState {
  final List<EcommerceProductModel> products;
  final int currentPage;
  final int total;
  final bool isLoadingMore;

  FetchEcommerceProductsSuccess({
    required this.products,
    required this.currentPage,
    required this.total,
    this.isLoadingMore = false,
  });

  FetchEcommerceProductsSuccess copyWith({
    List<EcommerceProductModel>? products,
    int? currentPage,
    int? total,
    bool? isLoadingMore,
  }) {
    return FetchEcommerceProductsSuccess(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
class FetchEcommerceProductsFailure extends FetchEcommerceProductsState {
  final String errorMessage;
  FetchEcommerceProductsFailure(this.errorMessage);
}

class FetchEcommerceProductsCubit extends Cubit<FetchEcommerceProductsState> {
  FetchEcommerceProductsCubit() : super(FetchEcommerceProductsInitial());

  int? currentPlatformId;
  int? currentCategoryId;
  int? currentSubcategoryId;

  Future<void> fetchProducts({int? platformId, int? categoryId, int? subcategoryId}) async {
    try {
      emit(FetchEcommerceProductsInProgress());
      currentPlatformId = platformId;
      currentCategoryId = categoryId;
      currentSubcategoryId = subcategoryId;
      
      final Dio dio = Dio();
      final response = await dio.get(
        '${AppSettings.ecommerceHostUrl}/api/ecommerce/products',
        queryParameters: {
          if (platformId != null) 'platform_id': platformId,
          if (categoryId != null) 'ecommerce_category_id': categoryId,
          if (subcategoryId != null) 'ecommerce_subcategory_id': subcategoryId,
          'page': 1,
        }
      );
      if (response.statusCode == 200 && 
          (response.data['success'] == true || response.data['error'] == false)) {
        var dataObj = response.data['data'];
        List data = dataObj['data'] ?? [];
        List<EcommerceProductModel> products = data.map((e) => EcommerceProductModel.fromJson(e)).toList();
        
        emit(FetchEcommerceProductsSuccess(
          products: products,
          currentPage: dataObj['current_page'] ?? 1,
          total: dataObj['total'] ?? 0,
        ));
      } else {
        emit(FetchEcommerceProductsFailure("Failed to fetch products"));
      }
    } catch (e) {
      emit(FetchEcommerceProductsFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is FetchEcommerceProductsSuccess) {
      final currentState = state as FetchEcommerceProductsSuccess;
      if (currentState.isLoadingMore || currentState.products.length >= currentState.total) return;

      try {
        emit(currentState.copyWith(isLoadingMore: true));
        final int nextPage = currentState.currentPage + 1;
        
        final Dio dio = Dio();
        final response = await dio.get(
          '${AppSettings.ecommerceHostUrl}/api/ecommerce/products',
          queryParameters: {
            if (currentPlatformId != null) 'platform_id': currentPlatformId,
            if (currentCategoryId != null) 'ecommerce_category_id': currentCategoryId,
            if (currentSubcategoryId != null) 'ecommerce_subcategory_id': currentSubcategoryId,
            'page': nextPage,
          }
        );
        
        if (response.statusCode == 200 && 
            (response.data['success'] == true || response.data['error'] == false)) {
          var dataObj = response.data['data'];
          List data = dataObj['data'] ?? [];
          List<EcommerceProductModel> newProducts = data.map((e) => EcommerceProductModel.fromJson(e)).toList();
          
          emit(FetchEcommerceProductsSuccess(
            products: [...currentState.products, ...newProducts],
            currentPage: dataObj['current_page'] ?? nextPage,
            total: dataObj['total'] ?? currentState.total,
          ));
        } else {
          emit(currentState.copyWith(isLoadingMore: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }
}
