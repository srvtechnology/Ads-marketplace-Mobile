import 'package:eClassify/data/model/bfs_model.dart';
import 'package:eClassify/utils/api.dart';

enum BfsPaymentType {
  featuredAd,
  offer,
  cartCheckout,
}

class BfsPaymentRepository {
  Future<BfsArResponse> initiatePayment({
    required BfsPaymentType paymentType,
    String? itemId,
    String? offerId,
    required String email,
    double? amount,
    Map<String, dynamic>? customerDetails,
  }) async {
    String url;
    Map<String, dynamic> params;

    if (paymentType == BfsPaymentType.cartCheckout) {
      url = Api.bfsCheckoutArApi;
      params = customerDetails ?? {
        'email': email,
      };
    } else if (paymentType == BfsPaymentType.featuredAd) {
      url = Api.bfsArApi;
      params = {
        'item_id': int.tryParse(itemId!) ?? 0,
        'email': email,
        if (amount != null && amount > 0) 'amount': amount.toInt(),
      };
    } else {
      // Offer payment
      url = Api.bfsOfferArApi;
      params = {
        'offer_id': int.tryParse(offerId!) ?? 0,
        'amount': amount!.toInt(),
      };
    }

    final result = await Api.post(url: url, parameter: params, useJson: true);
    return BfsArResponse.fromJson(result);
  }

  Future<BfsAeResponse> verifyAccount({
    required String orderNo,
    required String bankId,
    required String accountNo,
    BfsPaymentType paymentType = BfsPaymentType.featuredAd,
  }) async {
    String url = paymentType == BfsPaymentType.cartCheckout
        ? Api.bfsCheckoutAeApi
        : Api.bfsAeApi;

    final result = await Api.post(
      url: url,
      useJson: true,
      parameter: {
        'order_no': orderNo,
        'bank_id': bankId,
        'account_no': accountNo,
      },
    );
    return BfsAeResponse.fromJson(result);
  }

  Future<BfsDrResponse> submitOtp({
    required String orderNo,
    required String otp,
    required BfsPaymentType paymentType,
  }) async {
    String url;
    if (paymentType == BfsPaymentType.cartCheckout) {
      url = Api.bfsCheckoutDrApi;
    } else if (paymentType == BfsPaymentType.featuredAd) {
      url = Api.bfsDrApi;
    } else {
      url = Api.bfsOfferDrApi;
    }

    final result = await Api.post(
      url: url,
      useJson: true,
      parameter: {
        'order_no': orderNo,
        'otp': otp,
      },
    );
    return BfsDrResponse.fromJson(result);
  }

  Future<Map<String, dynamic>> checkStatus({required String orderNo}) async {
    final result = await Api.post(
      url: Api.bfsAsApi,
      useJson: true,
      parameter: {
        'order_no': orderNo,
      },
    );
    return result;
  }
}
