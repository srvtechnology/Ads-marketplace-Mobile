import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  int _start = 60;
  bool isResendEnabled = false;
  String otp = '';

  @override
  void initState() {
    super.initState();
    startResendOtpTimer();
  }

  void startResendOtpTimer() {
    setState(() {
      _start = 60;
      isResendEnabled = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOTP() {
    if (otp.trim().length < 6) {
      HelperUtils.showSnackBarMessage(
          context, "pleaseEnterSixDigits".translate(context));
      return;
    }

    // Set the OTP and trigger verification
    context.read<AuthenticationCubit>().setData(
          payload: EmailLoginPayload(
            email: widget.email,
            password: widget.password,
            type: EmailLoginType.verifyOtp,
            otp: otp.trim(),
          ),
          type: AuthenticationType.email,
        );
    context.read<AuthenticationCubit>().authenticate();
  }

  void _resendOTP() {
    // Resend OTP by calling signup again
    context.read<AuthenticationCubit>().setData(
          payload: EmailLoginPayload(
            email: widget.email,
            password: widget.password,
            type: EmailLoginType.signup,
          ),
          type: AuthenticationType.email,
        );
    context.read<AuthenticationCubit>().authenticate();
    startResendOtpTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.color.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.color.textColorDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, loginState) {
            if (loginState is LoginSuccess) {
              Widgets.hideLoder(context);

              // Navigate based on profile completion
              if (loginState.isProfileCompleted) {
                HiveUtils.setUserIsAuthenticated(true);
                if (HiveUtils.getCityName() != null &&
                    HiveUtils.getCityName() != "") {
                  HelperUtils.killPreviousPages(
                      context, Routes.main, {"from": "login"});
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.locationPermissionScreen, (route) => false);
                }
              } else {
                Navigator.pushNamed(
                  context,
                  Routes.completeProfile,
                  arguments: {
                    "from": "login",
                    "popToCurrent": false,
                  },
                );
              }
            }

            if (loginState is LoginFailure) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(
                  context, loginState.errorMessage.toString());
            }

            if (loginState is LoginInProgress) {
              Widgets.showLoader(context);
            }
          },
          child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationSuccess) {
                Widgets.hideLoder(context);

                // Check if OTP verification was successful
                var credential = state.credential as Map<String, dynamic>;
                if (credential['token'] != null) {
                  // OTP verified successfully, proceed with login
                  context.read<LoginCubit>().loginWithTwilio(
                      phoneNumber: '',
                      firebaseUserId: credential['id']?.toString() ?? '',
                      type: state.type.name,
                      credential: credential,
                      countryCode: '');
                } else if (credential['success'] == true) {
                  // OTP resent successfully
                  HelperUtils.showSnackBarMessage(context,
                      credential['message'] ?? 'OTP sent successfully');
                }
              }

              if (state is AuthenticationFail) {
                Widgets.hideLoder(context);
                HelperUtils.showSnackBarMessage(
                    context, state.error.toString());
              }

              if (state is AuthenticationInProcess) {
                Widgets.showLoader(context);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    CustomText(
                      "verifyEmail".translate(context),
                      fontSize: context.font.extraLarge,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      widget.email,
                      fontSize: context.font.large,
                      color: context.color.textColorDark,
                    ),
                    const SizedBox(height: 24),
                    CustomText(
                      "enterOtpSentToEmail".translate(context),
                      fontSize: context.font.normal,
                      color: context.color.textLightColor,
                    ),
                    const SizedBox(height: 32),
                    // OTP Input
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: (value) {
                        otp = value;
                      },
                      onCompleted: (value) {
                        otp = value;
                      },
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        activeFillColor: context.color.secondaryColor,
                        inactiveFillColor: context.color.secondaryColor,
                        selectedFillColor: context.color.secondaryColor,
                        activeColor: context.color.territoryColor,
                        inactiveColor:
                            context.color.textLightColor.withValues(alpha: 0.3),
                        selectedColor: context.color.territoryColor,
                      ),
                      cursorColor: context.color.textColorDark,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: context.color.textColorDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Resend OTP
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: isResendEnabled
                          ? MaterialButton(
                              onPressed: _resendOTP,
                              child: CustomText(
                                "resendOTP".translate(context),
                                color: context.color.territoryColor,
                              ),
                            )
                          : CustomText(
                              "${"resendOtpIn".translate(context)} 0:${_start.toString().padLeft(2, '0')}",
                              color: context.color.textColorDark
                                  .withValues(alpha: 0.7),
                            ),
                    ),
                    const SizedBox(height: 32),
                    // Verify Button
                    UiUtils.buildButton(
                      context,
                      onPressed: _verifyOTP,
                      buttonTitle: "verify".translate(context),
                      radius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
