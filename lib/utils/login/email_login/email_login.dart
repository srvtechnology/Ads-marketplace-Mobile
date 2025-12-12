import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';

class EmailLogin extends LoginSystem {
  String? verificationEmail;
  bool needsOtpVerification = false;

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
          emit(MProgress());
          result = await AuthRepository().emailLogin(
            email: payloadData.email,
            password: payloadData.password,
          );

          // Check if email verification is needed
          if (result['email_verified'] == false) {
            verificationEmail = payloadData.email;
            needsOtpVerification = true;
          }

          emit(MSuccess());
        } else if (payloadData.type == EmailLoginType.verifyOtp) {
          // OTP verification flow
          emit(MProgress());
          String otp = payloadData.otp ?? '';
          result = await AuthRepository().verifyEmailOTP(
            email: verificationEmail ?? payloadData.email,
            otp: otp,
          );

          needsOtpVerification = false;
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
