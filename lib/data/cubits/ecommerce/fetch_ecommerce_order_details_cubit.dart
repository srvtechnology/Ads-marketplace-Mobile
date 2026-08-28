import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/settings.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
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
          : '${AppSettings.ecommerceHostUrl}/api';
          
      final result = await Api.get(
        url: '$baseUrl/orders/$orderId',
        useBaseUrl: false,
      );

      if (result['error'] == false || result['success'] == true) {
        if (result['data'] != null) {
          EcommerceOrderModel order = EcommerceOrderModel.fromJson(Map<String, dynamic>.from(result['data']));
          emit(FetchEcommerceOrderDetailsSuccess(order));
        } else {
          emit(FetchEcommerceOrderDetailsFailure("Order details not found"));
        }
      } else {
        emit(FetchEcommerceOrderDetailsFailure(result['message']?.toString() ?? "Failed to fetch order details"));
      }
    } catch (e) {
      emit(FetchEcommerceOrderDetailsFailure(e.toString()));
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId, String remarks) async {
    try {
      final String baseUrl = Constant.isDemoModeOn
          ? 'http://127.0.0.1:8000/api'
          : '${AppSettings.ecommerceHostUrl}/api';

      final result = await Api.post(
        url: '$baseUrl/orders/$orderId/cancel',
        useBaseUrl: false,
        useJson: true,
        parameter: {
          'remarks': remarks,
        },
      );

      if (result['success'] == true || result['error'] == false) {
        fetchOrderDetails(orderId);
        return {
          'success': true,
          'message': result['message']?.toString() ?? 'Order cancelled successfully',
        };
      } else {
        return {
          'success': false,
          'message': result['message']?.toString() ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
