import 'package:eClassify/utils/helper_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PaymentGateway {
  final String name;
  final String? key;
  final String? currency;
  final int status;
  final String type;
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankIfscSwiftCode;

  PaymentGateway({
    required this.name,
    this.key,
    this.currency,
    required this.status,
    required this.type,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscSwiftCode,
    this.bankName,
  });
}

class AppSettings {
  /// Basic Settings
  static const String applicationName = 'Kora';
  static const String packageName = 'com.eclassify.wrteam';
  static const String shareAppText = "Share this App";

  static const String hostUrl = "https://ecommerce.thebhutanmarket.com";

  ///API Setting

  static const int apiDataLoadLimit = 20;
  static const int maxCategoryShowLengthInHomeScreen = 5;

  static final String baseUrl = "${HelperUtils.checkHost(hostUrl)}api/";

  static const int hiddenAPIProcessDelay = 1;

  static const String shareNavigationWebUrl = "admin.thebhutanmarket.com";

  static const MapType googleMapType = MapType.normal;

  static const int otpResendSecond = 60;
  static const int otpTimeOutSecond = 60;

  static const String defaultCountryCode = "975";
  static const bool disableCountrySelection = false;

  static const String successLoadingLottieFile = "loading_success.json";
  static const String successCheckLottieFile = "success_check.json";
  static const String progressLottieFileWhite = "loading_white.json";

  static const String maintenanceModeLottieFile = "maintenancemode.json";

  static const bool useLottieProgress = true;

  static const String notificationChannel = "basic_channel";
  static int uploadImageQuality = 20;
  static const Set additionalRTLlanguages = {};

  static const String riveAnimationFile = "rive_animation.riv";

  static const Map<String, dynamic> riveAnimationConfigurations = {
    "add_button": {
      "artboard_name": "Add",
      "state_machine": "click",
      "boolean_name": "isReverse",
      "boolean_initial_value": true,
      "add_button_shape_name": "shape",
    },
  };
}
