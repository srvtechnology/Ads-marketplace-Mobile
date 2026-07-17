import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchEcommerceOrderDetailsState {}

class FetchEcommerceOrderDetailsInitial extends FetchEcommerceOrderDetailsState {}

class FetchEcommerceOrderDetailsInProgress extends FetchEcommerceOrderDetailsState {}

class FetchEcommerceOrderDetailsSuccess extends FetchEcommerceOrderDetailsState {
  final EcommerceOrderModel order;

  FetchEcommerceOrderDetailsSuccess(this.order);
}

class FetchEcommerceOrderDetailsFailure extends FetchEcommerceOrderDetailsState {
  final String errorMessage;

  FetchEcommerceOrderDetailsFailure(this.errorMessage);
}

class FetchEcommerceOrderDetailsCubit extends Cubit<FetchEcommerceOrderDetailsState> {
  FetchEcommerceOrderDetailsCubit() : super(FetchEcommerceOrderDetailsInitial());

  void fetchOrderDetails(int orderId) async {
    try {
      emit(FetchEcommerceOrderDetailsInProgress());

      final String baseUrl = Constant.isDemoModeOn
          ? 'http://127.0.0.1:8000/api'
          : 'https://ecommerce.thebhutanmarket.com/api';
          
      final result = await Api.get(
        url: '$baseUrl/orders/$orderId',
        useBaseUrl: false,
      );

      if (result['error'] == false) {
        if (result['data'] != null) {
          EcommerceOrderModel order = EcommerceOrderModel.fromJson(result['data']);
          emit(FetchEcommerceOrderDetailsSuccess(order));
        } else {
          emit(FetchEcommerceOrderDetailsFailure("Order details not found"));
        }
      } else {
        emit(FetchEcommerceOrderDetailsFailure(result['message'].toString()));
      }
    } catch (e) {
      emit(FetchEcommerceOrderDetailsFailure(e.toString()));
    }
  }
}
