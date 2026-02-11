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
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          _passwordStrength = '';
          _passwordStrengthValue = 0.0;
          _passwordStrengthColor = Colors.grey;
        });
      }
      return;
    }

    // Calculate password strength
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (mounted) {
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
  }

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
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: context.color.textLightColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrengthValue,
                      backgroundColor:
                          context.color.textLightColor.withValues(alpha: 0.2),
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
                        color:
                            context.color.textColorDark.withValues(alpha: 0.7),
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
                    color: context.color.textColorDark.withValues(alpha: 0.5),
                  ),
                ],
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
                          ? Icons.visibility
                          : Icons.visibility_off,
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
