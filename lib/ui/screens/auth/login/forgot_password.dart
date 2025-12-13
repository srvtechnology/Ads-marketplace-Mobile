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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static MaterialPageRoute route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => const ForgotPasswordScreen(),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Api.post(
        url: Api.forgetPasswordApi,
        parameter: {
          'type': 'E', // E for Email, P for Phone
          'email_phone': _emailController.text.trim(),
        },
      );

      log('Forgot Password Response: $response');

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // Success - navigate to reset password screen
        HelperUtils.showSnackBarMessage(
          context,
          response['message'] ?? 'OTP sent successfully'.translate(context),
          type: MessageType.success,
        );

        Navigator.pushNamed(
          context,
          Routes.resetPasswordScreen,
          arguments: {
            'email_phone': _emailController.text.trim(),
            'type': 'E',
          },
        );
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          response['message'] ?? 'Failed to send OTP'.translate(context),
          type: MessageType.error,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error sending OTP: $e');
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
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: MaterialButton(
                          onPressed: () {
                            HelperUtils.killPreviousPages(context, Routes.main,
                                {"from": "login", "isSkipped": true});
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color:
                              context.color.forthColor.withValues(alpha: 0.102),
                          elevation: 0,
                          height: 28,
                          minWidth: 64,
                          child: CustomText(
                            "skip".translate(context),
                            color: context.color.forthColor,
                          )),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 66,
                ),
                CustomText(
                  "forgotPassword".translate(context),
                  fontSize: context.font.extraLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomText(
                  "forgotHeadingTxt".translate(context),
                  fontSize: context.font.large,
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomText(
                  "forgotSubHeadingTxt".translate(context),
                  fontSize: context.font.small,
                  color: context.color.textLightColor,
                ),
                const SizedBox(
                  height: 24,
                ),
                CustomTextFormField(
                    controller: _emailController,
                    keyboard: TextInputType.emailAddress,
                    hintText: "emailAddress".translate(context),
                    validator: CustomTextFieldValidator.email),
                const SizedBox(
                  height: 25,
                ),
                ListenableBuilder(
                    listenable: _emailController,
                    builder: (context, child) {
                      log('build');
                      return UiUtils.buildButton(
                        context,
                        disabled: _emailController.text.isEmpty || _isLoading,
                        disabledColor: const Color.fromARGB(255, 104, 102, 106),
                        buttonTitle: "submitBtnLbl".translate(context),
                        radius: 8,
                        onPressed: () async {
                          FocusScope.of(context).unfocus(); //dismiss keyboard
                          await _sendOTP();
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
