import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/data/repositories/auth_repository.dart';

class PhoneLogin extends LoginSystem {
  String? verificationId;
  String? phoneNumber;

  @override
  Future<Map<String, dynamic>?> login() async {
    try {
      emit(MProgress());

      String phoneNumber = (payload as PhoneLoginPayload).phoneNumber;
      String otp = (payload as PhoneLoginPayload).getOTP() ?? '';

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Call the API to verify OTP
      Map<String, dynamic> response = await AuthRepository().verifyOTP(
        phoneNumber: phoneNumber,
        otp: otp,
        fcmToken: fcmToken,
      );

      emit(MSuccess());

      return response;
    } catch (e) {
      emit(MFail(e));
    }
    return null;
  }

  @override
  Future<void> requestVerification() async {
    emit(MOtpSendInProgress());

    if (Constant.otpServiceProvider == 'twilio') {
      try {
        await getTwilioOtp();
        super.requestVerification();
      } on ApiException catch (e) {
        emit(MFail(e.errorMessage));
      } catch (e) {
        emit(MFail("Something went wrong"));
      }
      return;
    }

    try {
      // Use the new API-based OTP sending
      await AuthRepository().sendOTP(
        phoneNumber: (payload as PhoneLoginPayload).phoneNumber,
        countryCode: (payload as PhoneLoginPayload).countryCode,
        onCodeSent: (String verificationId, Map<String, dynamic> userDetails) {
          super.requestVerification();
          this.verificationId = verificationId;
          phoneNumber = (payload as PhoneLoginPayload).phoneNumber;
        },
        onError: (error) {
          emit(MFail(error));
        },
      );
    } catch (e) {
      emit(MFail(e));
    }
  }

  Future<Map<String, dynamic>> getTwilioOtp() async {
    phoneNumber = (payload as PhoneLoginPayload).countryCode +
        (payload as PhoneLoginPayload).phoneNumber;
    final parameters = {
      'number':
          "${(payload as PhoneLoginPayload).countryCode}${(payload as PhoneLoginPayload).phoneNumber}",
    };
    final response =
        await Api.get(url: Api.getTwilioOtp, queryParameters: parameters);

    return response;
  }

  @override
  void onEvent(MLoginState state) {}
}
