import 'package:eClassify/utils/api.dart';

class BankDetailsRepository {
  Future<Map<String, dynamic>> getBankAccountDetails() async {
    try {
      final response = await Api.get(
        url: Api.getBankAccountDetailsApi,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBankAccountDetails({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      final parameters = {
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_holder_name': accountHolderName,
      };

      final response = await Api.post(
        url: Api.updateBankAccountDetailsApi,
        parameter: parameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
