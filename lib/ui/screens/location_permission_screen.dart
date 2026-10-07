import 'dart:io';

import 'package:eClassify/app/routes.dart';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  LocationPermissionScreenState createState() =>
      LocationPermissionScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const LocationPermissionScreen());
  }
}

class LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _openedAppSettings = false;
  bool _isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _openedAppSettings) {
      _openedAppSettings = false;
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (Platform.isAndroid) {
          await Geolocator.openLocationSettings();
        }
        _showLocationServiceInstructions();
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _getCurrentLocationAndNavigate();
      } else {
        await setDefaultLocationAndNavigate();
      }
    } catch (e) {
      print("Error in _getCurrentLocation: $e");
      await setDefaultLocationAndNavigate();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> setDefaultLocationAndNavigate() async {
    try {
      double latitude = double.tryParse(Constant.defaultLatitude) ?? 27.5142;
      double longitude = double.tryParse(Constant.defaultLongitude) ?? 90.4336;

      String city = "Thimphu";
      String state = "Thimphu";
      String country = "Bhutan";
      String? area;

      try {
        await setLocaleIdentifier("en_US");
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        ).timeout(const Duration(seconds: 4));

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          city = placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea ??
              city;
          state = placemark.administrativeArea ??
              placemark.locality ??
              state;
          country = placemark.country ?? country;
          area = placemark.subLocality ?? placemark.name;
        }
      } catch (e) {
        print("Reverse geocoding default coordinates failed: $e");
      }

      if (Constant.isDemoModeOn) {
        UiUtils.setDefaultLocationValue(
            isCurrent: false, isHomeUpdate: false, context: context);
      } else {
        HiveUtils.setLocation(
          area: area,
          city: city,
          state: state,
          country: country,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      print("Error in setDefaultLocationAndNavigate: $e");
      UiUtils.setDefaultLocationValue(
          isCurrent: false, isHomeUpdate: false, context: context);
    }

    if (mounted) {
      HelperUtils.killPreviousPages(context, Routes.main, {"from": "login"});
    }
  }

  void _showLocationServiceInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
            'pleaseEnableLocationServicesManually'.translate(context)),
        action: SnackBarAction(
          label: 'ok'.translate(context),
          textColor: context.color.secondaryColor,
          onPressed: () {
            openAppSettings();
            setState(() {
              _openedAppSettings = true;
            });
          },
        ),
      ),
    );
    // Also navigate with default location so user isn't stuck forever
    setDefaultLocationAndNavigate();
  }

  Future<void> _getCurrentLocationAndNavigate() async {
    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        print("getCurrentPosition failed or timed out: $e");
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        print("Location position is null, using default location");
        await setDefaultLocationAndNavigate();
        return;
      }

      String city = "Thimphu";
      String state = "Thimphu";
      String country = "Bhutan";
      String? area;

      try {
        await setLocaleIdentifier("en_US");
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 4));

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          city = placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea ??
              city;
          state = placemark.administrativeArea ??
              placemark.locality ??
              state;
          country = placemark.country ?? country;
          area = placemark.subLocality ?? placemark.name;
        }
      } catch (e) {
        print("Reverse geocoding current position failed: $e");
      }

      if (Constant.isDemoModeOn) {
        UiUtils.setDefaultLocationValue(
            isCurrent: false, isHomeUpdate: false, context: context);
      } else {
        HiveUtils.setLocation(
          area: area,
          city: city,
          state: state,
          country: country,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      if (mounted) {
        HelperUtils.killPreviousPages(context, Routes.main, {"from": "login"});
      }
    } catch (e) {
      print("Error in _getCurrentLocationAndNavigate: $e");
      await setDefaultLocationAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UiUtils.getSvg(AppIcons.locationAccessIcon),
              const SizedBox(height: 19),
              CustomText(
                "whatsYourLocation".translate(context),
                fontSize: context.font.extraLarge,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomText(
                  'enjoyPersonalizedSellingAndBuyingLocationLbl'
                      .translate(context),
                  fontSize: context.font.larger,
                  color: context.color.textDefaultColor.withValues(alpha: 0.65),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 58),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: UiUtils.buildButton(
                  context,
                  showElevation: false,
                  buttonColor: context.color.territoryColor,
                  textColor: context.color.secondaryColor,
                  disabled: _isLoading,
                  onPressed: () {
                    _getCurrentLocation();
                  },
                  radius: 8,
                  height: 46,
                  buttonTitle: _isLoading
                      ? "loading".translate(context)
                      : "next".translate(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
