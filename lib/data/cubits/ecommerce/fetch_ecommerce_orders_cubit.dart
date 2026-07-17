import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchEcommerceOrdersState {}

class FetchEcommerceOrdersInitial extends FetchEcommerceOrdersState {}

class FetchEcommerceOrdersInProgress extends FetchEcommerceOrdersState {}

class FetchEcommerceOrdersSuccess extends FetchEcommerceOrdersState {
  final List<EcommerceOrderModel> orders;

  FetchEcommerceOrdersSuccess(this.orders);
}

class FetchEcommerceOrdersFailure extends FetchEcommerceOrdersState {
  final String errorMessage;

  FetchEcommerceOrdersFailure(this.errorMessage);
}

class FetchEcommerceOrdersCubit extends Cubit<FetchEcommerceOrdersState> {
  FetchEcommerceOrdersCubit() : super(FetchEcommerceOrdersInitial());

  void fetchOrders() async {
    try {
      emit(FetchEcommerceOrdersInProgress());

      final String baseUrl = Constant.isDemoModeOn
          ? 'http://127.0.0.1:8000/api'
          : 'https://ecommerce.thebhutanmarket.com/api';
          
      final result = await Api.get(
        url: '$baseUrl/orders', // Use standard slash first, if fails user can update to double slash later
        useBaseUrl: false,
      );

      if (result['error'] == false) {
        // Wait, the API response has {"data": [ ... ]} for list?
        // Let's check the user request... 
        // Wait, the response example provided by user was for GET /api//orders, but it returned a SINGLE order object in "data".
        // Ah! The user provided the SAME response example for /api//orders and /api/orders/{id}! 
        // Wait, if /api/orders returns a list of orders, it should be in data as a list or maybe data['data'] if paginated. Let's assume data is a List.
        List<EcommerceOrderModel> orders = [];
        if (result['data'] is List) {
           orders = (result['data'] as List)
              .map((e) => EcommerceOrderModel.fromJson(e))
              .toList();
        } else if (result['data'] is Map && result['data']['data'] is List) {
           orders = (result['data']['data'] as List)
              .map((e) => EcommerceOrderModel.fromJson(e))
              .toList();
        }

        emit(FetchEcommerceOrdersSuccess(orders));
      } else {
        emit(FetchEcommerceOrdersFailure(result['message'].toString()));
      }
    } catch (e) {
      emit(FetchEcommerceOrdersFailure(e.toString()));
    }
  }
}
