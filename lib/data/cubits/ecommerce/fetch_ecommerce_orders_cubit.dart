import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/utils/api.dart';
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

      final result = await Api.get(
        url: 'https://ecommerce.thebhutanmarket.com/api/orders',
        useBaseUrl: false,
      );

      if (result['error'] == false || result['success'] == true) {
        List<EcommerceOrderModel> orders = [];
        final dataJson = result['data'];
        if (dataJson is List) {
          orders = dataJson.map((e) => EcommerceOrderModel.fromJson(e)).toList();
        } else if (dataJson is Map && dataJson['data'] is List) {
          orders = (dataJson['data'] as List).map((e) => EcommerceOrderModel.fromJson(e)).toList();
        }

        emit(FetchEcommerceOrdersSuccess(orders));
      } else {
        emit(FetchEcommerceOrdersFailure(result['message']?.toString() ?? "Failed to fetch orders"));
      }
    } catch (e) {
      emit(FetchEcommerceOrdersFailure(e.toString()));
    }
  }

  Future<bool> cancelOrder(int orderId, String remarks) async {
    try {
      final result = await Api.post(
        url: 'https://ecommerce.thebhutanmarket.com/api/orders/$orderId/cancel',
        useBaseUrl: false,
        useJson: true,
        parameter: {
          'remarks': remarks,
        },
      );

      if (result['success'] == true || result['error'] == false) {
        fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
