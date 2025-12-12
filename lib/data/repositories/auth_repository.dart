import 'dart:io';

import 'package:eClassify/utils/api.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  Future<Map<String, dynamic>> numberLoginWithApi(
      {String? phone,
      required String uid,
      required String type,
      String? fcmId,
      String? email,
      String? name,
      String? profile,
      String? countryCode}) async {
    Map<String, String> parameters = {
      if (phone != null) Api.mobile: phone,
      Api.firebaseId: uid,
      Api.type: type,
      Api.platformType: Platform.isAndroid ? "android" : "ios",
      if (fcmId != null) Api.fcmId: fcmId,
      if (email != null) Api.email: email,
      if (name != null) Api.name: name,
      if (countryCode != null) Api.countryCode: countryCode,
    };

    Map<String, dynamic> response = await Api.post(
      url: Api.loginApi,
      parameter: parameters,
    );

    return {"token": response['token'], "data": response['data']};
  }

  Future<dynamic> deleteUser() async {
    Map<String, dynamic> response = await Api.delete(
      url: Api.deleteUserApi,
    );

    return response;
  }

  void loginEmailUser() async {}

  Future<Map<String, dynamic>> sendOTP(
      {required String phoneNumber,
      required String countryCode,
      required Function(String verificationId, Map<String, dynamic> userDetails)
          onCodeSent,
      Function(dynamic e)? onError}) async {
    try {
      // Remove the '+' from country code if present
      String cleanCountryCode =
          countryCode.startsWith('+') ? countryCode : '+$countryCode';

      Map<String, String> parameters = {
        Api.mobile: phoneNumber,
        Api.countryCode: cleanCountryCode,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.mobileSignupApi,
        parameter: parameters,
      );

      if (response['status'] == true) {
        // Extract user details from response
        Map<String, dynamic> userDetails = response['user_details'];
        // Use the user ID as verification ID for consistency
        String verificationId = userDetails['id'].toString();

        onCodeSent.call(verificationId, userDetails);

        return {
          'verificationId': verificationId,
          'userDetails': userDetails,
        };
      } else {
        throw ApiException(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      onError?.call(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      Map<String, String> parameters = {
        Api.mobile: phoneNumber,
        Api.otp: otp,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.mobileSignupVerifyOtpApi,
        parameter: parameters,
      );

      if (response['error'] == false) {
        // Return the response data which includes user data and token
        return {
          'data': response['data'],
          'token': response['token'],
          'id': response['data']['id'].toString(),
        };
      } else {
        throw ApiException(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Email Authentication Methods

  /// Email Signup - Creates new user account with email and password
  Future<Map<String, dynamic>> emailSignup({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, String> parameters = {
        Api.email: email,
        'password': password,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.emailSignupApi,
        parameter: parameters,
      );

      // Check if email already exists
      if (response['status'] == false && response['email_exist'] == 'Y') {
        throw ApiException(response['message'] ?? 'Email already exists');
      }

      // Successful signup
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'],
          'user_details': response['user_details'],
          'email_exist': response['email_exist'],
        };
      } else {
        throw ApiException(response['message'] ?? 'Signup failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify Email OTP after signup
  Future<Map<String, dynamic>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      Map<String, String> parameters = {
        Api.email: email,
        Api.otp: otp,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.emailSignupVerifyOtpApi,
        parameter: parameters,
      );

      if (response['error'] == false) {
        return {
          'data': response['data'],
          'token': response['token'],
          'id': response['data']['id'].toString(),
        };
      } else {
        throw ApiException(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Email Login - Login existing user with email and password
  Future<Map<String, dynamic>> emailLogin({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, String> parameters = {
        Api.email: email,
        'password': password,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.emailLoginApi,
        parameter: parameters,
      );

      if (response['error'] == false) {
        // Check if email is not verified and OTP was sent
        if (response['data'] != null && response['data']['user'] != null) {
          // Email not verified case
          return {
            'email_verified': false,
            'user': response['data']['user'],
            'otp': response['data']['otp'],
            'message': response['message'],
          };
        } else {
          // Email verified, successful login
          return {
            'email_verified': true,
            'data': response['data'],
            'token': response['token'],
            'id': response['data']['id'].toString(),
          };
        }
      } else {
        throw ApiException(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class MultiAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> createUserWithEmail(
      {required String email, required String password}) async {
    try {
      UserCredential credentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credentials;
    } catch (e) {
      rethrow;
    }
  }
}
