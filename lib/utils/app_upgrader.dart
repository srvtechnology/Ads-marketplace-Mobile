import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:eClassify/utils/constant.dart';

/// Custom App Store implementation that sanitizes non-standard version strings
/// like "2.9.20(91)" returned by the iTunes Search API into valid semantic versions.
class CustomUpgraderAppStore extends UpgraderAppStore {
  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    final info = await super.getVersionInfo(
      state: state,
      installedVersion: installedVersion,
      country: country,
      language: language,
    );

    // If UpgraderAppStore failed to parse the store version due to non-SemVer formats (e.g., "2.9.20(91)"):
    if (info.appStoreVersion == null && state.packageInfo != null) {
      try {
        final iTunes = ITunesSearchAPI();
        iTunes.debugLogging = state.debugLogging;
        iTunes.client = state.client;
        iTunes.clientHeaders = state.clientHeaders;

        final response = await iTunes.lookupByBundleId(
          state.packageInfo!.packageName,
          country: country,
          language: language,
        );

        if (response != null) {
          final rawVersion = iTunes.version(response);
          if (rawVersion != null) {
            Version? parsedVersion;
            // 1. Try stripping parentheses build metadata: "2.9.20(91)" -> "2.9.20"
            try {
              final clean =
                  rawVersion.replaceAll(RegExp(r'\(.*?\)'), '').trim();
              parsedVersion = Version.parse(clean);
            } catch (_) {
              // 2. Try converting to semver build: "2.9.20(91)" -> "2.9.20+91"
              try {
                final sanitized = rawVersion
                    .replaceAllMapped(
                      RegExp(r'\((.*?)\)'),
                      (match) => '+${match.group(1)}',
                    )
                    .replaceAll(' ', '');
                parsedVersion = Version.parse(sanitized);
              } catch (_) {}
            }

            if (parsedVersion != null) {
              return UpgraderVersionInfo(
                installedVersion: installedVersion,
                appStoreListingURL:
                    info.appStoreListingURL ?? iTunes.trackViewUrl(response),
                appStoreVersion: parsedVersion,
                isCriticalUpdate: info.isCriticalUpdate,
                minAppVersion:
                    info.minAppVersion ?? iTunes.minAppVersion(response),
                releaseNotes:
                    info.releaseNotes ?? iTunes.releaseNotes(response),
              );
            }
          }
        }
      } catch (e) {
        if (state.debugLogging) {
          debugPrint('upgrader: CustomUpgraderAppStore exception: $e');
        }
      }
    }

    return info;
  }
}

/// Centralized manager for Upgrader configuration and store update checks.
class AppUpgrader {
  AppUpgrader._();
  static final AppUpgrader _instance = AppUpgrader._();
  static AppUpgrader get instance => _instance;

  late final Upgrader upgrader = Upgrader(
    debugLogging: kDebugMode,
    durationUntilAlertAgain:
        kDebugMode ? Duration.zero : const Duration(days: 1),
    countryCode: 'BT',
    storeController: UpgraderStoreController(
      onAndroid: () => UpgraderPlayStore(),
      oniOS: () => CustomUpgraderAppStore(),
    ),
    willDisplayUpgrade: ({
      required bool display,
      String? installedVersion,
      UpgraderVersionInfo? versionInfo,
    }) {
      if (display) {
        Constant.isUpdateAvailable = true;
        if (versionInfo?.appStoreVersion != null) {
          Constant.newVersionNumber =
              versionInfo!.appStoreVersion.toString();
        }
      }
    },
  );

  /// Synchronize remote version & force-update requirements from backend system settings.
  void syncWithSettings({
    required String? remoteVersion,
    required String? forceUpdate,
  }) {
    if (remoteVersion != null && remoteVersion.trim().isNotEmpty) {
      if (forceUpdate == "1") {
        // Enforce mandatory update via Upgrader
        upgrader.minAppVersion = remoteVersion.trim();
      }
    }
  }

  /// Fallback handler for the update button in case Upgrader cannot determine store URL.
  bool handleUpdate() {
    final appStoreListingURL = upgrader.versionInfo?.appStoreListingURL;
    if (appStoreListingURL == null || appStoreListingURL.isEmpty) {
      final fallbackUrl = Platform.isIOS
          ? Constant.appstoreURLios
          : Constant.playstoreURLAndroid;
      if (fallbackUrl.isNotEmpty) {
        launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
        return false; // Handled via fallback URL
      }
    }
    return true; // Proceed with Upgrader's default store launch
  }
}
