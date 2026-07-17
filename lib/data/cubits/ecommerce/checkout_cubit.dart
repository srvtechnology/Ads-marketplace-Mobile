import 'package:eClassify/data/model/ecommerce/checkout_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}
class CheckoutInProgress extends CheckoutState {}
class CheckoutSuccess extends CheckoutState {
  final EcommerceCheckoutModel checkoutResponse;
  CheckoutSuccess(this.checkoutResponse);
}
class CheckoutFailure extends CheckoutState {
  final String errorMessage;
  CheckoutFailure(this.errorMessage);
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<void> checkout({
    required String name,
    required String mobile,
    required String shippingAddress,
    required String paymentMode,
    String? email,
    String? shippingZipcode,
    String? shippingLandmark,
    String? billingAddress,
    String? billingZipcode,
    String? billingLandmark,
    String? remarks,
  }) async {
    try {
      emit(CheckoutInProgress());
      
      Map<String, dynamic> params = {
        'name': name,
        'mobile': mobile,
        'shipping_address': shippingAddress,
        'payment_mode': paymentMode,
      };
      
      if (email != null && email.isNotEmpty) params['email'] = email;
      if (shippingZipcode != null && shippingZipcode.isNotEmpty) params['shipping_zipcode'] = shippingZipcode;
      if (shippingLandmark != null && shippingLandmark.isNotEmpty) params['shipping_landmark'] = shippingLandmark;
      if (billingAddress != null && billingAddress.isNotEmpty) params['billing_address'] = billingAddress;
      if (billingZipcode != null && billingZipcode.isNotEmpty) params['billing_zipcode'] = billingZipcode;
      if (billingLandmark != null && billingLandmark.isNotEmpty) params['billing_landmark'] = billingLandmark;
      if (remarks != null && remarks.isNotEmpty) params['remarks'] = remarks;

      final response = await Api.post(
        url: 'https://ecommerce.thebhutanmarket.com/api/checkout', 
        useBaseUrl: false,
        parameter: params,
      );
      
      if (response['success'] == true || response['error'] == false) {
        EcommerceCheckoutModel data = EcommerceCheckoutModel.fromJson(response['data']);
        emit(CheckoutSuccess(data));
      } else {
        emit(CheckoutFailure(response['message']?.toString() ?? "Checkout failed"));
      }
    } catch (e) {
      emit(CheckoutFailure(e.toString()));
    }
  }
}
