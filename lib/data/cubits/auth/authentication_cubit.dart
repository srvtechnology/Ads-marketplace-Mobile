import 'dart:developer';
import 'dart:io';

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/login/apple_login/apple_login.dart';
import 'package:eClassify/utils/login/email_login/email_login.dart';
import 'package:eClassify/utils/login/google_login/google_login.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/login/phone_login/phone_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationType {
  email,
  google,
  apple,
  phone;
}

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationInProcess extends AuthenticationState {
  final AuthenticationType type;

  AuthenticationInProcess(this.type);
}

class AuthenticationSuccess extends AuthenticationState {
  final AuthenticationType type;
  final dynamic credential;
  final LoginPayload payload;
  final String? authId;

  AuthenticationSuccess(this.type, this.credential, this.payload, this.authId);
}

class AuthenticationFail extends AuthenticationState {
  final dynamic error;

  AuthenticationFail(this.error);
}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());
  AuthenticationType? type;
  LoginPayload? payload;
  MMultiAuthentication mMultiAuthentication = MMultiAuthentication({
    "google": GoogleLogin(),
    "email": EmailLogin(),
    if (Platform.isIOS) "apple": AppleLogin(),
    "phone": PhoneLogin()
  });

  void init() {
    mMultiAuthentication.init();
  }

  void setData(
      {required LoginPayload payload, required AuthenticationType type}) {
    this.type = type;
    this.payload = payload;
  }

  void authenticate() async {
    if (type == null && payload == null) {
      return;
    }

    try {
      emit(AuthenticationInProcess(type!));
      mMultiAuthentication.setActive(type!.name);
      mMultiAuthentication.payload = MultiLoginPayload({
        type!.name: payload!,
      });

      if (Constant.otpServiceProvider == 'twilio' &&
          payload is PhoneLoginPayload) {
        final twilio = await verifyTwilioOtp();
        if (twilio['error'] == true) {
          emit(AuthenticationFail(twilio['message']));
          return;
        }
        final token = twilio['token']?.toString() ?? '';
        final credentials = twilio['data'];

        emit(AuthenticationSuccess(type!, credentials, payload!, token));
      } else if (type == AuthenticationType.phone) {
        // For API-based phone authentication
        dynamic loginResult = await mMultiAuthentication.login();

        if (loginResult == null) {
          return;
        } else if (loginResult is Map<String, dynamic>) {
          // API-based phone authentication returns a Map
          final token = loginResult['token']?.toString() ?? '';
          final credentials = loginResult;

          emit(AuthenticationSuccess(type!, credentials, payload!, token));
        } else {
          emit(
              AuthenticationFail("Invalid response from phone authentication"));
        }
      } else if (type == AuthenticationType.email) {
        // For API-based email authentication with MFA
        dynamic loginResult = await mMultiAuthentication.login();

        if (loginResult == null) {
          return;
        } else if (loginResult is Map<String, dynamic>) {
          // API-based email authentication returns a Map

          // Check if this is a signup response (needs OTP verification)
          if (loginResult['success'] == true &&
              loginResult['user_details'] != null &&
              loginResult['requires_mfa'] != true) {
            // Signup successful, needs OTP verification
            emit(AuthenticationSuccess(type!, loginResult, payload!, null));
          }
          // Check if MFA is required (login step 1 - no token yet)
          else if (loginResult['requires_mfa'] == true) {
            // MFA required - OTP sent to email, no token issued yet
            emit(AuthenticationSuccess(type!, loginResult, payload!, null));
          }
          // Check if MFA verification successful (login step 2 - token issued)
          else if (loginResult['mfa_verified'] == true &&
              loginResult['token'] != null) {
            // MFA verified - token NOW issued
            final token = loginResult['token']?.toString() ?? '';
            emit(AuthenticationSuccess(type!, loginResult, payload!, token));
          }
          // Check if this is a successful login with token (legacy/fallback)
          else if (loginResult['token'] != null) {
            final token = loginResult['token']?.toString() ?? '';
            emit(AuthenticationSuccess(type!, loginResult, payload!, token));
          } else {
            emit(AuthenticationFail(
                "Invalid response from email authentication"));
          }
        } else {
          emit(
              AuthenticationFail("Invalid response from email authentication"));
        }
      } else {
        // For Google/Apple authentication (Firebase-based)
        UserCredential? credential = await mMultiAuthentication.login();

        if (credential == null) {
          return;
        } else {
          LoginPayload? payloadData = (payload);

          if (payloadData is EmailLoginPayload &&
              payloadData.type == EmailLoginType.login) {
            User? user = credential.user;
            if (user != null && !user.emailVerified) {
              // Handle the case when the user's email is not verified
              emit(AuthenticationFail("Please verify your email first."));
            } else {
              emit(AuthenticationSuccess(type!, credential, payload!, null));
            }
          } else {
            emit(AuthenticationSuccess(type!, credential, payload!, null));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              "There is no user record corresponding to this identifier. The user may have been deleted.";
          break;
        case 'wrong-password':
          errorMessage =
              "The password is invalid or the user does not have a password.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is badly formatted.";
          break;
        case 'user-disabled':
          errorMessage =
              "The user account has been disabled by an administrator.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many requests. Try again later.";
          break;
        case 'operation-not-allowed':
          errorMessage =
              "This operation is not allowed. Please contact support.";
          break;
        default:
          errorMessage = "An unexpected error occurred. Please try again.";
          break;
      }
      emit(AuthenticationFail(errorMessage));
    } catch (e, stack) {
      log(e.toString());
      log('$stack');
      emit(AuthenticationFail(e));
    }
  }

  Future<Map<String, dynamic>> verifyTwilioOtp() async {
    final parameters = {
      'number':
          "+${(payload as PhoneLoginPayload).countryCode}${(payload as PhoneLoginPayload).phoneNumber}",
      'otp': (payload as PhoneLoginPayload).getOTP(),
    };

    final response =
        await Api.get(url: Api.verifyTwilioOtp, queryParameters: parameters);

    return response;
  }

  void listen(Function(MLoginState state) fn) {
    mMultiAuthentication.listen(fn);
  }

  void verify() {
    mMultiAuthentication.setActive(type!.name);
    mMultiAuthentication.payload = MultiLoginPayload({
      type!.name: payload!,
    });
    mMultiAuthentication.requestVerification();
  }

  Future<void> signOut() async {
    try {
      // Disconnect from all systems
      for (var system in mMultiAuthentication.systems.values) {
        await system.signOut();
      }
    } catch (e) {
      log("Error during provider sign out: $e");
    }
    emit(AuthenticationInitial());
  }
}
