import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';

class EmailLogin extends LoginSystem {
  String? verificationEmail;
  String? verificationPassword;
  bool needsOtpVerification = false;
  bool needsMfaVerification = false;

  @override
  Future<Map<String, dynamic>?> login() async {
    Map<String, dynamic>? result;
    if (payload is EmailLoginPayload) {
      var payloadData = (payload as EmailLoginPayload);

      try {
        if (payloadData.type == EmailLoginType.signup) {
          // Signup flow - call email signup API
          emit(MProgress());
          result = await AuthRepository().emailSignup(
            email: payloadData.email,
            password: payloadData.password,
          );

          // Store email for OTP verification
          verificationEmail = payloadData.email;
          needsOtpVerification = true;

          emit(MSuccess());
        } else if (payloadData.type == EmailLoginType.login) {
          // Login flow - call email login API
          // MFA is enabled: token NOT issued here, only after OTP verification
          emit(MProgress());
          result = await AuthRepository().emailLogin(
            email: payloadData.email,
            password: payloadData.password,
          );

          // MFA is required - store credentials for OTP verification
          if (result['requires_mfa'] == true) {
            verificationEmail = payloadData.email;
            verificationPassword = payloadData.password;
            needsMfaVerification = true;
          }

          emit(MSuccess());
        } else if (payloadData.type == EmailLoginType.verifyOtp) {
          // Signup OTP verification flow
          emit(MProgress());
          String otp = payloadData.otp ?? '';
          result = await AuthRepository().verifyEmailOTP(
            email: verificationEmail ?? payloadData.email,
            otp: otp,
          );

          needsOtpVerification = false;
          emit(MSuccess());
        } else if (payloadData.type == EmailLoginType.loginVerifyOtp) {
          // MFA OTP verification flow - TOKEN IS ISSUED HERE ONLY
          emit(MProgress());
          String otp = payloadData.otp ?? '';

          String? fcmToken = await FirebaseMessaging.instance.getToken();

          result = await AuthRepository().emailLoginVerifyOtp(
            email: verificationEmail ?? payloadData.email,
            otp: otp,
            fcmToken: fcmToken,
          );

          // MFA verified successfully - token is now available
          needsMfaVerification = false;
          emit(MSuccess());
        }
      } on Exception catch (e) {
        emit(MFail(e));
      }
    }
    return result;
  }

  @override
  void onEvent(MLoginState state) {}
}
