import 'package:eClassify/data/model/bfs_model.dart';
import 'package:eClassify/utils/api.dart';

class BfsPaymentRepository {
  Future<BfsArResponse> initiatePayment({
    required String itemId,
    required String email,
  }) async {
    final result = await Api.post(
      url: Api.bfsArApi,
      parameter: {
        'item_id': itemId,
        'email': email,
      },
    );
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
  }) async {
    final result = await Api.post(
      url: Api.bfsDrApi,
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
