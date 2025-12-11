import 'dart:async';
import 'package:eClassify/data/cubits/payment/bfs_payment_cubit.dart';
import 'package:eClassify/data/model/bfs_model.dart';
import 'package:eClassify/data/repositories/bfs_payment_repository.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialog_box.dart';

class BfsPaymentScreen extends StatefulWidget {
  final BfsPaymentType paymentType;
  final String? itemId;
  final String? offerId;
  final double price;
  final String packageName;

  const BfsPaymentScreen({
    Key? key,
    this.paymentType = BfsPaymentType.featuredAd,
    this.itemId,
    this.offerId,
    required this.price,
    required this.packageName,
  }) : super(key: key);

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => BfsPaymentScreen(
        paymentType: arguments['paymentType'] ?? BfsPaymentType.featuredAd,
        itemId: arguments['itemId'],
        offerId: arguments['offerId'],
        price: arguments['price'],
        packageName: arguments['packageName'],
      ),
    );
  }

  @override
  State<BfsPaymentScreen> createState() => _BfsPaymentScreenState();
}

class _BfsPaymentScreenState extends State<BfsPaymentScreen> {
  int _currentStep = 0; // 0: Loading/AR, 1: Bank Selection, 2: OTP, 3: Success
  BfsArResponse? _arResponse;
  String? _selectedBankId;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  Timer? _otpTimer;
  int _otpSecondsRemaining = 50;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _accountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpSecondsRemaining = 50;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining > 0) {
        setState(() {
          _otpSecondsRemaining--;
        });
      } else {
        _otpTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BfsPaymentCubit(BfsPaymentRepository())
        ..initiatePayment(
          paymentType: widget.paymentType,
          itemId: widget.itemId,
          offerId: widget.offerId,
          email: HiveUtils.getUserDetails().email ?? "customer@gmail.com",
          amount: widget.price,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: CustomText("Secure Payment",
              color: context.color.textDefaultColor),
          backgroundColor: context.color.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.color.textDefaultColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: context.color.backgroundColor,
        body: BlocConsumer<BfsPaymentCubit, BfsPaymentState>(
          listener: (context, state) {
            if (state is BfsPaymentFailure) {
              HelperUtils.showSnackBarMessage(context, state.errorMessage,
                  type: MessageType.error);
            } else if (state is BfsPaymentArSuccess) {
              setState(() {
                _arResponse = state.response;
                _currentStep = 1;
              });
            } else if (state is BfsPaymentAeSuccess) {
              HelperUtils.showSnackBarMessage(context, state.response.message,
                  type: MessageType.success);
              setState(() {
                _currentStep = 2;
                if (state.response.otp != null &&
                    state.response.otp!.isNotEmpty) {
                  _otpController.text = state.response.otp!;
                }
                _startOtpTimer();
              });
            } else if (state is BfsPaymentDrSuccess) {
              if (state.response.errorType == BfsErrorType.success) {
                _otpTimer?.cancel();
                setState(() {
                  _currentStep = 3;
                });
              } else {
                String errorMsg = "Payment Failed";
                switch (state.response.errorType) {
                  case BfsErrorType.bankDeclined:
                    errorMsg =
                        "Insufficient funds or withdrawal limit exceeded.";
                    break;
                  case BfsErrorType.validation:
                    errorMsg = "Transaction cancelled/Validation error.";
                    break;
                  case BfsErrorType.timeout:
                    errorMsg = "Transaction timed out.";
                    break;
                  case BfsErrorType.unknown:
                  default:
                    errorMsg =
                        "Unknown error occurred. Code: ${state.response.status}";
                    break;
                }

                UiUtils.showBlurredDialoge(
                  context,
                  dialoge: BlurredDialogBox(
                      title: "Payment Error",
                      content: CustomText(errorMsg),
                      isAcceptContainerPush: true,
                      acceptButtonName: "Back",
                      onAccept: () => Future.value().then((_) {
                            Navigator.pop(context);
                            return;
                          })),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is BfsPaymentLoading) {
              return Center(child: UiUtils.progress());
            }

            if (_currentStep == 1 && _arResponse != null) {
              return _buildBankSelectionStep(context);
            } else if (_currentStep == 2) {
              return _buildOtpStep(context);
            } else if (_currentStep == 3) {
              return _buildSuccessStep(context);
            }

            return Center(child: CustomText("Initializing Payment..."));
          },
        ),
      ),
    );
  }

  Widget _buildBankSelectionStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "Order #${_arResponse!.orderNo}",
            color: context.color.textDefaultColor.withOpacity(0.6),
          ),
          SizedBox(height: 10),
          CustomText(
            widget.packageName,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          CustomText(
            "BTN ${_arResponse!.amount.toStringAsFixed(2)}",
            fontSize: 20,
            color: context.color.territoryColor,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 30),
          CustomText("Select Your Bank", fontWeight: FontWeight.bold),
          SizedBox(height: 10),
          ..._arResponse!.banks.map((bank) => RadioListTile<String>(
                title: CustomText(bank.name),
                value: bank.id,
                groupValue: _selectedBankId,
                activeColor: context.color.territoryColor,
                onChanged: (value) {
                  setState(() {
                    _selectedBankId = value;
                  });
                },
              )),
          SizedBox(height: 20),
          CustomText("Account Number", fontWeight: FontWeight.bold),
          SizedBox(height: 10),
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              hintText: "Enter your account number",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: context.color.secondaryColor,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 30),
          UiUtils.buildButton(
            context,
            onPressed: () {
              if (_selectedBankId == null) {
                HelperUtils.showSnackBarMessage(context, "Please select a bank",
                    type: MessageType.warning);
                return;
              }
              if (_accountController.text.isEmpty) {
                HelperUtils.showSnackBarMessage(
                    context, "Please enter account number",
                    type: MessageType.warning);
                return;
              }
              context.read<BfsPaymentCubit>().verifyAccount(
                    orderNo: _arResponse!.orderNo,
                    bankId: _selectedBankId!,
                    accountNo: _accountController.text,
                  );
            },
            buttonTitle: "Verify Account",
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: 60, color: context.color.territoryColor),
          SizedBox(height: 20),
          CustomText("Enter OTP", fontSize: 20, fontWeight: FontWeight.bold),
          SizedBox(height: 10),
          CustomText(
            "An OTP has been sent to your registered mobile number",
            textAlign: TextAlign.center,
            color: context.color.textDefaultColor.withOpacity(0.7),
          ),
          SizedBox(height: 30),
          SizedBox(height: 30),
          TextField(
            controller: _otpController,
            decoration: InputDecoration(
              hintText: "Enter OTP",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: context.color.secondaryColor,
              counterText: "",
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, letterSpacing: 5),
          ),
          SizedBox(height: 20),
          CustomText(
            "Time remaining: $_otpSecondsRemaining sec",
            color: _otpSecondsRemaining > 10
                ? context.color.textDefaultColor
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 30),
          UiUtils.buildButton(
            context,
            onPressed: () {
              if (_otpSecondsRemaining == 0) return;

              if (_otpController.text.isEmpty) {
                HelperUtils.showSnackBarMessage(context, "Please enter OTP",
                    type: MessageType.warning);
                return;
              }
              context.read<BfsPaymentCubit>().submitOtp(
                    orderNo: _arResponse!.orderNo,
                    otp: _otpController.text,
                  );
            },
            buttonTitle: "Submit Payment",
            disabledColor: _otpSecondsRemaining == 0 ? Colors.grey : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green),
          SizedBox(height: 20),
          CustomText("Payment Successful!",
              fontSize: 24, fontWeight: FontWeight.bold),
          SizedBox(height: 10),
          CustomText("Your transaction has been completed."),
          SizedBox(height: 40),
          UiUtils.buildButton(
            context,
            onPressed: () {
              Navigator.pop(context, true); // Return success
            },
            buttonTitle: "Continue",
          ),
        ],
      ),
    );
  }
}
