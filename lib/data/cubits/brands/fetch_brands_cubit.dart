import 'package:dio/dio.dart';
import 'package:eClassify/data/model/brand_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchBrandsState {}

class FetchBrandsInitial extends FetchBrandsState {}

class FetchBrandsInProgress extends FetchBrandsState {}

class FetchBrandsSuccess extends FetchBrandsState {
  final List<BrandModel> brands;
  FetchBrandsSuccess(this.brands);
}

class FetchBrandsFailure extends FetchBrandsState {
  final String errorMessage;
  FetchBrandsFailure(this.errorMessage);
}

class FetchBrandsCubit extends Cubit<FetchBrandsState> {
  FetchBrandsCubit() : super(FetchBrandsInitial());

  Future<void> fetchBrands() async {
    try {
      emit(FetchBrandsInProgress());
      
      final Dio dio = Dio();
      final response = await dio.get('https://ecommerce.thebhutanmarket.com/api/ecommerce/platforms');
      
      if (response.statusCode == 200) {
        List data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'];
        }
        
        List<BrandModel> brands = data.map((e) => BrandModel.fromJson(e)).toList();
        emit(FetchBrandsSuccess(brands));
      } else {
        emit(FetchBrandsFailure("Failed to fetch brands"));
      }
    } catch (e) {
      emit(FetchBrandsFailure(e.toString()));
    }
  }
}
