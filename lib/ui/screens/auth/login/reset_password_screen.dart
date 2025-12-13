import 'dart:developer';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String emailPhone;
  final String type;

  const ResetPasswordScreen({
    super.key,
    required this.emailPhone,
    required this.type,
  });

  static MaterialPageRoute route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => ResetPasswordScreen(
        emailPhone: args?['email_phone'] ?? '',
        type: args?['type'] ?? 'E',
      ),
    );
  }

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      HelperUtils.showSnackBarMessage(
        context,
        'Passwords do not match'.translate(context),
        type: MessageType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Api.post(
        url: Api.setNewPasswordApi,
        parameter: {
          'type': widget.type,
          'email_phone': widget.emailPhone,
          'otp': _otpController.text.trim(),
          'password': _passwordController.text,
        },
      );

      log('Reset Password Response: $response');

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // Success - navigate to login screen
        HelperUtils.showSnackBarMessage(
          context,
          response['message'] ??
              'Password reset successfully'.translate(context),
          type: MessageType.success,
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.login,
          (route) => false,
        );
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          response['message'] ?? 'Failed to reset password'.translate(context),
          type: MessageType.error,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error resetting password: $e');
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.color.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: context.color.textDefaultColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CustomText(
                  "resetPassword".translate(context),
                  fontSize: context.font.extraLarge,
                ),
                const SizedBox(height: 20),
                CustomText(
                  "resetPasswordHeading".translate(context),
                  fontSize: context.font.large,
                ),
                const SizedBox(height: 8),
                CustomText(
                  "resetPasswordSubHeading".translate(context),
                  fontSize: context.font.small,
                  color: context.color.textLightColor,
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  controller: _otpController,
                  keyboard: TextInputType.number,
                  hintText: "otpCode".translate(context),
                  validator: CustomTextFieldValidator.otpSix,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _passwordController,
                  keyboard: TextInputType.visiblePassword,
                  hintText: "newPassword".translate(context),
                  obscureText: _obscurePassword,
                  validator: CustomTextFieldValidator.password,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: context.color.textLightColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  keyboard: TextInputType.visiblePassword,
                  hintText: "confirmPassword".translate(context),
                  obscureText: _obscureConfirmPassword,
                  validator: CustomTextFieldValidator.password,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: context.color.textLightColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 25),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    _otpController,
                    _passwordController,
                    _confirmPasswordController,
                  ]),
                  builder: (context, child) {
                    return UiUtils.buildButton(
                      context,
                      disabled: _otpController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty ||
                          _isLoading,
                      disabledColor: const Color.fromARGB(255, 104, 102, 106),
                      buttonTitle: "resetPassword".translate(context),
                      radius: 8,
                      onPressed: () async {
                        FocusScope.of(context).unfocus(); //dismiss keyboard
                        await _resetPassword();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
