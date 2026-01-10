import 'dart:io';

import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/ui/screens/auth/sign_up/email_verification_screen.dart';

import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';

import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/security_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  final String? emailId;

  const SignupScreen({super.key, this.emailId});

  static MaterialPageRoute route(RouteSettings settings) {
    Map? args = settings.arguments as Map?;
    return MaterialPageRoute(
      builder: (context) {
        return SignupScreen(
          emailId: args!['emailId'],
        );
      },
    );
  }

  @override
  CloudState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends CloudState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;

  // Password strength tracking
  String _passwordStrength = '';
  double _passwordStrengthValue = 0.0;
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Listen to password changes for real-time validation
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthValue = 0.0;
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    // Calculate password strength
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Weak';
          _passwordStrengthValue = 0.25;
          _passwordStrengthColor = Colors.red;
          break;
        case 2:
          _passwordStrength = 'Fair';
          _passwordStrengthValue = 0.5;
          _passwordStrengthColor = Colors.orange;
          break;
        case 3:
          _passwordStrength = 'Good';
          _passwordStrengthValue = 0.75;
          _passwordStrengthColor = Colors.blue;
          break;
        case 4:
        case 5:
          _passwordStrength = 'Strong';
          _passwordStrengthValue = 1.0;
          _passwordStrengthColor = Colors.green;
          break;
      }
    });
  }

  void onTapSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Additional password strength check
      if (!SecurityUtils.validatePasswordStrength(_passwordController.text)) {
        HelperUtils.showSnackBarMessage(
          context,
          SecurityUtils.getPasswordStrengthMessage(_passwordController.text),
        );
        return;
      }

      context.read<AuthenticationCubit>().setData(
          payload: EmailLoginPayload(
              email: _emailController.text,
              password: _passwordController.text,
              type: EmailLoginType.signup),
          type: AuthenticationType.email);
      context.read<AuthenticationCubit>().authenticate();
    }
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = widget.emailId!;
    return SafeArea(
      top: false,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.backgroundColor,
        ),
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          bottomNavigationBar: termAndPolicyTxt(),
          body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationSuccess) {
                if (state.type == AuthenticationType.email) {
                  // API-based email signup
                  var credential = state.credential as Map<String, dynamic>;

                  // Check if signup was successful (needs OTP verification)
                  if (credential['success'] == true ||
                      credential['email_verified'] == false) {
                    Navigator.push<dynamic>(context, MaterialPageRoute(
                      builder: (context) {
                        return EmailVerificationScreen(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                    ));
                  }
                }
              }

              if (state is AuthenticationFail) {
                HelperUtils.showSnackBarMessage(
                    context, state.error.toString());
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 18.0, right: 18, top: 23),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: MaterialButton(
                              onPressed: () {
                                HelperUtils.killPreviousPages(
                                    context,
                                    Routes.main,
                                    {"from": "login", "isSkipped": true});
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: context.color.forthColor
                                  .withValues(alpha: 0.102),
                              elevation: 0,
                              height: 28,
                              minWidth: 64,
                              child: CustomText(
                                "skip".translate(context),
                                color: context.color.forthColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 66,
                        ),
                        CustomText(
                          "welcome".translate(context),
                          fontSize: context.font.extraLarge,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomText(
                          "signUpToeClassify".translate(context),
                          fontSize: context.font.large,
                          color: context.color.textColorDark
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomTextFormField(
                          controller: _emailController,
                          isReadOnly: true,
                          fillColor: context.color.secondaryColor,
                          validator: CustomTextFieldValidator.email,
                          hintText: "emailAddress".translate(context),
                          borderColor: context.color.textLightColor
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        CustomTextFormField(
                          controller: _passwordController,
                          fillColor: context.color.secondaryColor,
                          obscureText: isObscure,
                          suffix: IconButton(
                            onPressed: () {
                              isObscure = !isObscure;
                              setState(() {});
                            },
                            icon: Icon(
                              !isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: context.color.textColorDark
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          hintText: "password".translate(context),
                          validator: CustomTextFieldValidator.password,
                          borderColor: context.color.textLightColor
                              .withValues(alpha: 0.3),
                        ),
                        // Password strength indicator
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrengthValue,
                              backgroundColor: context.color.textLightColor
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _passwordStrengthColor,
                              ),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Strength label
                          Row(
                            children: [
                              CustomText(
                                'Password strength: ',
                                fontSize: context.font.small,
                                color: context.color.textColorDark
                                    .withValues(alpha: 0.7),
                              ),
                              CustomText(
                                _passwordStrength,
                                fontSize: context.font.small,
                                color: _passwordStrengthColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Password requirements
                          CustomText(
                            'Must contain: 8+ chars, uppercase, lowercase, number, special char',
                            fontSize: context.font.smaller,
                            color: context.color.textColorDark
                                .withValues(alpha: 0.5),
                          ),
                        ],
                        const SizedBox(
                          height: 36,
                        ),
                        UiUtils.buildButton(context,
                            onPressed: onTapSignup,
                            buttonTitle:
                                "verifyEmailAddress".translate(context),
                            radius: 10,
                            disabled: false,
                            height: 46,
                            disabledColor:
                                const Color.fromARGB(255, 104, 102, 106)),
                        const SizedBox(
                          height: 36,
                        ),
                        if (Constant.mobileAuthentication == "1") mobileAuth(),
                        if (Constant.googleAuthentication == "1" ||
                            Constant.appleAuthentication == "1")
                          googleAndAppleAuth(),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText("alreadyHaveAcc".translate(context),
                                color: context.color.textColorDark
                                    .withValues(alpha: 0.7)),
                            const SizedBox(
                              width: 12,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, Routes.login);
                              },
                              child: CustomText(
                                "login".translate(context),
                                showUnderline: true,
                                color: context.color.territoryColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget mobileAuth() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText("signupWithLbl".translate(context),
            color: context.color.textColorDark.withValues(alpha: 0.7)),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.signupMainScreen);
          },
          child: CustomText(
            "mobileNumberLbl".translate(context),
            showUnderline: true,
            color: context.color.territoryColor,
          ),
        )
      ],
    );
  }

  Widget googleAndAppleAuth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 24,
        ),
        if (Constant.googleAuthentication == "1")
          UiUtils.buildButton(context,
              prefixWidget: Padding(
                padding: EdgeInsetsDirectional.only(end: 10.0),
                child:
                    UiUtils.getSvg(AppIcons.googleIcon, width: 22, height: 22),
              ),
              showElevation: false,
              buttonColor: secondaryColor_,
              border: context.watch<AppThemeCubit>().state.appTheme !=
                      AppTheme.dark
                  ? BorderSide(
                      color:
                          context.color.textDefaultColor.withValues(alpha: 0.5))
                  : null,
              textColor: textDarkColor, onPressed: () {
            context.read<AuthenticationCubit>().setData(
                payload: GoogleLoginPayload(), type: AuthenticationType.google);
            context.read<AuthenticationCubit>().authenticate();
          },
              radius: 8,
              height: 46,
              buttonTitle: "continueWithGoogle".translate(context)),
        if (Constant.appleAuthentication == "1" && Platform.isIOS) ...[
          const SizedBox(
            height: 12,
          ),
          if (Platform.isIOS)
            UiUtils.buildButton(context,
                prefixWidget: Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.0),
                  child:
                      UiUtils.getSvg(AppIcons.appleIcon, width: 22, height: 22),
                ),
                showElevation: false,
                buttonColor: secondaryColor_,
                border: context.watch<AppThemeCubit>().state.appTheme !=
                        AppTheme.dark
                    ? BorderSide(
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.5))
                    : null,
                textColor: textDarkColor, onPressed: () {
              context.read<AuthenticationCubit>().setData(
                  payload: AppleLoginPayload(), type: AuthenticationType.apple);
              context.read<AuthenticationCubit>().authenticate();
            },
                height: 46,
                radius: 8,
                buttonTitle: "continueWithApple".translate(context)),
        ]
      ],
    );
  }

  Widget termAndPolicyTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 15.0, start: 25.0, end: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText("bySigningUpLoggingIn".translate(context),
              color: context.color.textLightColor.withValues(alpha: 0.8),
              fontSize: context.font.small,
              textAlign: TextAlign.center),
          const SizedBox(
            height: 3,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                child: CustomText(
                  "termsOfService".translate(context),
                  showUnderline: true,
                  color: context.color.territoryColor,
                  fontSize: context.font.small,
                ),
                onTap: () => Navigator.pushNamed(context, Routes.webViewScreen,
                        arguments: {
                          'title': "termsConditions".translate(context),
                          'url': Constant.termsConditionsUrl
                        })),
            const SizedBox(
              width: 5.0,
            ),
            CustomText(
              "andTxt".translate(context),
              color: context.color.textLightColor.withValues(alpha: 0.8),
              fontSize: context.font.small,
            ),
            const SizedBox(
              width: 5.0,
            ),
            InkWell(
                child: CustomText(
                  "privacyPolicy".translate(context),
                  showUnderline: true,
                  color: context.color.territoryColor,
                  fontSize: context.font.small,
                ),
                onTap: () => Navigator.pushNamed(context, Routes.webViewScreen,
                        arguments: {
                          'title': "privacyPolicy".translate(context),
                          'url': Constant.privacyPolicyUrl
                        })),
          ]),
        ],
      ),
    );
  }
}
