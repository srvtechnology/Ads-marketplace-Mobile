import 'package:dio/dio.dart';
import 'package:eClassify/data/model/ecommerce/cart_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/network_request_interseptor.dart';
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

  Future<void> fetchCart({bool isSilent = false}) async {
    try {
      if (!isSilent) {
        emit(CartInProgress());
      }
      
      final response = await Api.get(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart', 
        useBaseUrl: false,
      );
      
      if (response['success'] == true || response['error'] == false) {
        EcommerceCartModel cart = EcommerceCartModel.fromJson(response['data']);
        emit(CartSuccess(cart));
      } else {
        if (!isSilent) {
          emit(CartFailure("Failed to fetch cart"));
        }
      }
    } catch (e) {
      if (!isSilent) {
        emit(CartFailure(e.toString()));
      }
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
        await fetchCart();
      } else {
        emit(CartFailure("Failed to add to cart"));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<bool> addScrapedProductToCart(Map<String, dynamic> productData, {int quantity = 1}) async {
    try {
      emit(CartInProgress());

      dynamic rawPrice = productData['price'];
      double parsedPrice = 0.0;
      if (rawPrice is num) {
        parsedPrice = rawPrice.toDouble();
      } else if (rawPrice != null) {
        String cleanStr = rawPrice.toString().replaceAll(RegExp(r'[^0-9.]'), '');
        parsedPrice = double.tryParse(cleanStr) ?? 0.0;
      }

      String title = (productData['title'] ?? '').toString().trim();
      if (title.isEmpty) title = 'Imported Product';

      String brand = (productData['brand'] ?? '').toString().trim();
      if (brand.isEmpty) brand = 'Amazon';

      String image = (productData['image'] ?? '').toString().trim();
      String url = (productData['url'] ?? '').toString().trim();
      String variants = (productData['variants'] ?? '').toString().trim();

      final response = await Api.post(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart/add', 
        useBaseUrl: false,
        useJson: true,
        parameter: {
          'title': title,
          'price': parsedPrice,
          'brand': brand,
          'image': image,
          'url': url,
          'variants': variants,
          'quantity': quantity,
        }
      );
      
      if (response['success'] == true || response['error'] == false) {
        await fetchCart();
        return true;
      } else {
        String msg = response['message']?.toString() ?? "Failed to add to cart";
        emit(CartFailure(msg));
        return false;
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
      return false;
    }
  }

  Future<EcommerceCartItemBreakdownModel?> fetchCartItemDetails(int cartItemId) async {
    try {
      final response = await Api.get(
        url: 'https://ecommerce.thebhutanmarket.com/api/cart/items/$cartItemId/details',
        useBaseUrl: false,
      );
      if (response['success'] == true && response['data'] != null) {
        return EcommerceCartItemBreakdownModel.fromJson(response['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateCartItem(int cartItemId, int qty, {bool? isSelected}) async {
    if (state is CartSuccess) {
      final currentCart = (state as CartSuccess).cart;
      final updatedItems = currentCart.items.map((item) {
        if (item.id == cartItemId) {
          double newSubtotal = item.price * qty;
          return EcommerceCartItemModel(
            id: item.id,
            productId: item.productId,
            productVariantId: item.productVariantId,
            price: item.price,
            qty: qty,
            subtotal: newSubtotal,
            isSelected: isSelected ?? item.isSelected,
            product: item.product,
            variant: item.variant,
            platform: item.platform,
            url: item.url,
            importedDate: item.importedDate,
          );
        }
        return item;
      }).toList();

      double newGrandTotal = updatedItems.fold(0, (sum, item) => sum + (item.subtotal > 0 ? item.subtotal : (item.price * item.qty)));
      emit(CartSuccess(EcommerceCartModel(
        items: updatedItems,
        grandTotal: newGrandTotal,
        currency: currentCart.currency,
      )));
    }

    bool success = false;

    // 1. Try PUT /api/cart/items/{cart_item_id}
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterceptor());
      final response = await dio.put(
        'https://ecommerce.thebhutanmarket.com/api/cart/items/$cartItemId',
        data: {
          'quantity': qty,
          if (isSelected != null) 'is_selected': isSelected,
        },
        options: Options(
          headers: Api.headers(),
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        success = true;
      }
    } catch (_) {}

    // 2. Fallback POST /api/cart/update/$cartItemId
    if (!success) {
      try {
        final response = await Api.post(
          url: 'https://ecommerce.thebhutanmarket.com/api/cart/update/$cartItemId',
          useBaseUrl: false,
          useJson: true,
          parameter: {
            'cart_item_id': cartItemId,
            'quantity': qty,
            'qty': qty,
            if (isSelected != null) 'is_selected': isSelected,
          },
        );
        if (response['success'] == true || response['error'] == false) {
          success = true;
        }
      } catch (_) {}
    }

    await fetchCart(isSilent: true);
  }

  Future<void> removeCartItem(int cartItemId) async {
    await deleteCartItems([cartItemId]);
  }

  Future<void> deleteCartItems(List<int> cartItemIds) async {
    if (cartItemIds.isEmpty) return;

    if (state is CartSuccess) {
      final currentCart = (state as CartSuccess).cart;
      final updatedItems = currentCart.items.where((item) => !cartItemIds.contains(item.id)).toList();
      double newGrandTotal = updatedItems.fold(0, (sum, item) => sum + (item.subtotal > 0 ? item.subtotal : (item.price * item.qty)));
      emit(CartSuccess(EcommerceCartModel(
        items: updatedItems,
        grandTotal: newGrandTotal,
        currency: currentCart.currency,
      )));
    }

    bool success = false;

    // 1. Try DELETE /api/cart/items with payload {"cart_item_ids": [...]}
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterceptor());
      final response = await dio.delete(
        'https://ecommerce.thebhutanmarket.com/api/cart/items',
        data: {
          'cart_item_ids': cartItemIds,
        },
        options: Options(
          headers: Api.headers(),
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        success = true;
      }
    } catch (_) {}

    // 2. Fallback single delete endpoint
    if (!success && cartItemIds.length == 1) {
      try {
        final response = await Api.delete(
          url: 'https://ecommerce.thebhutanmarket.com/api/cart/remove/${cartItemIds.first}', 
          useBaseUrl: false,
        );
        if (response['success'] == true || response['error'] == false) {
          success = true;
        }
      } catch (_) {}
    }

    await fetchCart(isSilent: true);
  }
}
