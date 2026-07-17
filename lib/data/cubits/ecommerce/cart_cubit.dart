import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/cart_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CartState {}

class CartInitial extends CartState {}
class CartInProgress extends CartState {}
class CartSuccess extends CartState {
  final EcommerceCartModel cart;
  CartSuccess(this.cart);
}
class CartFailure extends CartState {
  final String errorMessage;
  CartFailure(this.errorMessage);
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  Future<void> fetchCart() async {
    try {
      emit(CartInProgress());
      
      final response = await Api.get(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart', 
        useBaseUrl: false,
      );
      
      if (response['success'] == true || response['error'] == false) {
        EcommerceCartModel cart = EcommerceCartModel.fromJson(response['data']);
        emit(CartSuccess(cart));
      } else {
        emit(CartFailure("Failed to fetch cart"));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> addToCart(int productId, int productVariantId, int qty) async {
    try {
      emit(CartInProgress());
      final response = await Api.post(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart/add', 
        useBaseUrl: false,
        useJson: true,
        parameter: {
          'product_id': productId,
          'product_varient_id': productVariantId,
          'qty': qty,
        }
      );
      
      if (response['success'] == true || response['error'] == false) {
        await fetchCart(); // Refresh cart after adding
      } else {
        emit(CartFailure("Failed to add to cart"));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> updateCartItem(int cartItemId, int qty) async {
    try {
      // We use Dio directly since Api doesn't have PUT
      final Dio dio = Dio();
      final response = await dio.put(
        'https://ecommerce.thebhutanmarket.com/api/cart/update/$cartItemId',
        data: {'qty': qty},
        options: Options(headers: Api.headers()),
      );
      
      if (response.statusCode == 200 && 
          (response.data['success'] == true || response.data['error'] == false)) {
        await fetchCart(); // Refresh cart
      } else {
        emit(CartFailure("Failed to update cart item"));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> removeCartItem(int cartItemId) async {
    try {
      final response = await Api.delete(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart/remove/$cartItemId', 
        useBaseUrl: false,
      );
      
      if (response['success'] == true || response['error'] == false) {
        await fetchCart(); // Refresh cart
      } else {
        emit(CartFailure("Failed to remove cart item"));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }
}
