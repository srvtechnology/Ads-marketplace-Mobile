import 'package:eClassify/data/model/bfs_model.dart';
import 'package:eClassify/utils/api.dart';

enum BfsPaymentType {
  featuredAd,
  offer,
}

class BfsPaymentRepository {
  Future<BfsArResponse> initiatePayment({
    required BfsPaymentType paymentType,
    String? itemId,
    String? offerId,
    required String email,
    double? amount,
  }) async {
    String url;
    Map<String, dynamic> params;

    if (paymentType == BfsPaymentType.featuredAd) {
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

    final result = await Api.post(url: url, parameter: params);
    return BfsArResponse.fromJson(result);
  }

  Future<BfsAeResponse> verifyAccount({
    required String orderNo,
    required String bankId,
    required String accountNo,
  }) async {
    final result = await Api.post(
      url: Api.bfsAeApi,
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
    String url = paymentType == BfsPaymentType.featuredAd
        ? Api.bfsDrApi
        : Api.bfsOfferDrApi;

    final result = await Api.post(
      url: url,
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
      parameter: {
        'order_no': orderNo,
      },
    );
    return result;
  }
}
