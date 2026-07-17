import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchProductDetailsState {}

class FetchProductDetailsInitial extends FetchProductDetailsState {}
class FetchProductDetailsInProgress extends FetchProductDetailsState {}
class FetchProductDetailsSuccess extends FetchProductDetailsState {
  final EcommerceProductModel product;
  FetchProductDetailsSuccess(this.product);
}
class FetchProductDetailsFailure extends FetchProductDetailsState {
  final String errorMessage;
  FetchProductDetailsFailure(this.errorMessage);
}

class FetchProductDetailsCubit extends Cubit<FetchProductDetailsState> {
  FetchProductDetailsCubit() : super(FetchProductDetailsInitial());

  Future<void> fetchProductDetails(int productId) async {
    try {
      emit(FetchProductDetailsInProgress());
      final Dio dio = Dio();
      final response = await dio.get('https://ecommerce.thebhutanmarket.com/api/ecommerce/products/$productId');
      
      if (response.statusCode == 200 && 
          (response.data['success'] == true || response.data['error'] == false)) {
        var dataObj = response.data['data'];
        EcommerceProductModel product = EcommerceProductModel.fromJson(dataObj);
        emit(FetchProductDetailsSuccess(product));
      } else {
        emit(FetchProductDetailsFailure("Failed to fetch product details"));
      }
    } catch (e) {
      emit(FetchProductDetailsFailure(e.toString()));
    }
  }
}
