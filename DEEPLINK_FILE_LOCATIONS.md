# Deep Link File Locations & Code Snippets

## 📂 File Structure Overview

```
Ads-marketplace-Mobile/
│
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml          ← Android Deep Link Config
│
├── ios/
│   └── Runner/
│       └── Info.plist                           ← iOS Deep Link Config
│
├── lib/
│   ├── app/
│   │   ├── app.dart                             ← App initialization
│   │   └── routes.dart                          ← Deep link routing logic ⭐
│   │
│   ├── ui/
│   │   └── screens/
│   │       ├── splash_screen.dart               ← Cold start handling ⭐
│   │       └── main_activity.dart               ← Warm start handling ⭐
│   │
│   ├── utils/
│   │   └── helper_utils.dart                    ← Deep link URL generation ⭐
│   │
│   └── settings.dart                            ← Configuration constants
│
├── pubspec.yaml                                 ← Dependencies (app_links commented)
│
├── DEEPLINK_DOCUMENTATION.md                    ← Full documentation (NEW)
├── DEEPLINK_SUMMARY.md                          ← Quick reference (NEW)
└── DEEPLINK_FILE_LOCATIONS.md                   ← This file (NEW)
```

⭐ = Critical files for deep link functionality

---

## 🔧 Configuration Files

### 1. Android Configuration
**File**: `android/app/src/main/AndroidManifest.xml`

**Line 88**: Enable Flutter deep linking
```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
```

**Lines 90-109**: Intent filter for deep links
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data
        android:host="eclassifyweb.wrteam.me"
        android:pathPattern="/product-details/.*"
        android:scheme="bhutanmarket" />
    
    <data
        android:host="eclassifyweb.wrteam.me"
        android:pathPattern="/seller/.*"
        android:scheme="bhutanmarket" />
</intent-filter>
```

---

### 2. iOS Configuration
**File**: `ios/Runner/Info.plist`

**Lines 43-50**: Custom URL scheme
```xml
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>bhutanmarket</string>
    </array>
</dict>
```

---

## 💻 Flutter Code Files

### 1. Deep Link URL Generation
**File**: `lib/utils/helper_utils.dart`

**Lines 96-98**: Generate deep link URL
```dart
static String nativeDeepLinkUrl(String type, String value) {
  return "https://${AppSettings.shareNavigationWebUrl}/$type/$value?share=true";
}
```

**Lines 100-144**: Share functionality
```dart
static void shareItem(BuildContext context, String type, String slug) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.color.backgroundColor,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: CustomText("copylink".translate(context)),
            onTap: () async {
              String deepLink = nativeDeepLinkUrl(type, slug);
              await Clipboard.setData(ClipboardData(text: deepLink));
              // ... show success message
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: CustomText("share".translate(context)),
            onTap: () async {
              String deepLink = nativeDeepLinkUrl(type, slug);
              String text = "${"shareDetailsMsg".translate(context)}:\n$deepLink.";
              await Share.share(text);
            },
          ),
        ],
      );
    },
  );
}
```

**Usage Example**:
```dart
// Generate a product deep link
String link = HelperUtils.nativeDeepLinkUrl('product-details', 'my-product-123');
// Result: https://eclassifyweb.wrteam.me/product-details/my-product-123?share=true

// Show share dialog
HelperUtils.shareItem(context, 'product-details', 'my-product-123');
```

---

### 2. Deep Link Routing
**File**: `lib/app/routes.dart`

**Lines 151-186**: Route generation with deep link handling
```dart
static Route onGenerateRouted(RouteSettings routeSettings) {
  previousRoute = currentRoute;
  currentRoute = routeSettings.name ?? "";

  // Check for deep link patterns
  if (routeSettings.name!.contains('/product-details/') ||
      routeSettings.name!.contains('/seller/')) {
    
    final uri = Uri.parse(routeSettings.name!);
    final pathSegments = uri.pathSegments;
    
    final type = pathSegments[0]; // 'product-details' or 'seller'
    final value = pathSegments[1]; // slug or id
    
    HiveUtils.setUserSkip();
    
    if (type == 'product-details') {
      if (previousRoute.isEmpty) {
        // App was terminated - go through splash
        return MaterialPageRoute(
            builder: (_) => SplashScreen(itemSlug: value));
      } else {
        // App is running - navigate directly
        if (currentRoute == adDetailsScreen) {
          Constant.navigatorKey.currentState?.pop();
        }
        return AdDetailsScreen.route(
          RouteSettings(arguments: {"slug": value}),
        );
      }
    } else if (type == 'seller') {
      if (previousRoute.isEmpty) {
        return MaterialPageRoute(
            builder: (_) => SplashScreen(sellerId: value));
      } else {
        if (currentRoute == sellerProfileScreen) {
          Constant.navigatorKey.currentState?.pop();
        }
        return SellerProfileScreen.route(
          RouteSettings(arguments: {"sellerId": int.parse(value)}),
        );
      }
    }
  }
  
  // ... rest of routing logic
}
```

**Key Variables**:
- `previousRoute`: Tracks the previous route name
- `currentRoute`: Tracks the current route name
- Used to determine if app was terminated (previousRoute.isEmpty)

---

### 3. Splash Screen (Cold Start)
**File**: `lib/ui/screens/splash_screen.dart`

**Lines 18-24**: Constructor with deep link parameters
```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.itemSlug, super.key, this.sellerId});

  // Used when the app is terminated and then is opened using deep link
  final String? itemSlug;
  final String? sellerId;
}
```

**Lines 130-156**: Navigation with deep link parameters
```dart
void navigateToScreen() async {
  // ... maintenance and onboarding checks ...
  
  if (HiveUtils.isUserAuthenticated()) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.main, arguments: {
          'from': "main",
          "slug": widget.itemSlug,      // ← Pass deep link slug
          "sellerId": widget.sellerId    // ← Pass deep link seller ID
        });
      }
    });
  } else {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (HiveUtils.isUserSkip() == true) {
          Navigator.of(context).pushReplacementNamed(Routes.main, arguments: {
            'from': "main",
            "slug": widget.itemSlug,
            "sellerId": widget.sellerId
          });
        } else {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      }
    });
  }
}
```

---

### 4. MainActivity (Warm Start)
**File**: `lib/ui/screens/main_activity.dart`

**Lines 64-65**: Constructor parameters
```dart
class MainActivity extends StatefulWidget {
  final String from;
  final String? itemSlug;     // ← Deep link product slug
  final String? sellerId;     // ← Deep link seller ID
}
```

**Lines 75-83**: Route factory
```dart
static Route route(RouteSettings routeSettings) {
  Map arguments = routeSettings.arguments as Map;
  return MaterialPageRoute(
      builder: (_) => MainActivity(
            from: arguments['from'] as String,
            itemSlug: arguments['slug'] as String?,
            sellerId: arguments['sellerId'] as String?,
          ));
}
```

**Lines 135-142**: Handle deep link navigation
```dart
@override
void initState() {
  super.initState();
  // ... other initialization ...
  
  if (widget.itemSlug != null) {
    Navigator.of(context).pushNamed(Routes.adDetailsScreen,
        arguments: {"slug": widget.itemSlug!});
  }
  if (widget.sellerId != null) {
    Navigator.pushNamed(context, Routes.sellerProfileScreen,
        arguments: {"sellerId": int.parse(widget.sellerId!)});
  }
}
```

---

### 5. Settings Configuration
**File**: `lib/settings.dart`

**Line 45**: Deep link domain
```dart
static const String shareNavigationWebUrl = "eclassifyweb.wrteam.me";
```

**Usage**: This constant is used in `HelperUtils.nativeDeepLinkUrl()` to generate shareable links.

---

## 📦 Dependencies

### Current Dependencies
**File**: `pubspec.yaml`

**Line 34**: Share functionality
```yaml
share_plus: ^10.0.0
```

**Line 33**: URL launching
```yaml
url_launcher: ^6.3.0
```

### Commented Out (Not Currently Used)
**Line 60**: Deep link package
```yaml
#app_links: ^6.3.1
```

**In Code**:
- `lib/ui/screens/main_activity.dart` Line 6: `//import 'package:app_links/app_links.dart';`
- `lib/ui/screens/home/home_screen.dart` Line 31: `//import 'package:uni_links/uni_links.dart';`

---

## 🔍 Where to Find Specific Functionality

### To Modify Deep Link Patterns:
1. **Android**: Edit `android/app/src/main/AndroidManifest.xml` lines 98-106
2. **iOS**: Edit `ios/Runner/Info.plist` lines 43-50
3. **Flutter**: Edit `lib/app/routes.dart` lines 151-152

### To Change Deep Link Domain:
1. Edit `lib/settings.dart` line 45
2. Update `android/app/src/main/AndroidManifest.xml` lines 99, 104
3. Update web verification files (when created)

### To Add New Deep Link Type:
1. Add pattern in `android/app/src/main/AndroidManifest.xml`
2. Add handling in `lib/app/routes.dart` `onGenerateRouted()` method
3. Update `lib/utils/helper_utils.dart` `nativeDeepLinkUrl()` if needed

### To Debug Deep Links:
1. Add breakpoint in `lib/app/routes.dart` line 151
2. Check `routeSettings.name` value
3. Verify `pathSegments` parsing at line 154

---

## 🧪 Testing Locations

### Android Test Commands
Create a test script at: `scripts/test_deeplinks_android.sh`
```bash
#!/bin/bash
# Test product deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "bhutanmarket://eclassifyweb.wrteam.me/product-details/test-123"

# Test seller deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "bhutanmarket://eclassifyweb.wrteam.me/seller/456"
```

### iOS Test Commands
Create a test script at: `scripts/test_deeplinks_ios.sh`
```bash
#!/bin/bash
# Test product deep link
xcrun simctl openurl booted \
  "bhutanmarket://eclassifyweb.wrteam.me/product-details/test-123"

# Test seller deep link
xcrun simctl openurl booted \
  "bhutanmarket://eclassifyweb.wrteam.me/seller/456"
```

---

## 📝 Code Flow Summary

```
User clicks deep link
    ↓
OS receives intent/URL
    ↓
App launches (if not running)
    ↓
lib/app/routes.dart
  └─ onGenerateRouted() [Line 146]
      └─ Check for deep link pattern [Line 151]
          └─ Parse URI [Line 153]
              └─ Extract type & value [Lines 156-157]
                  ├─ If app terminated (previousRoute.isEmpty)
                  │   └─ lib/ui/screens/splash_screen.dart
                  │       └─ SplashScreen(itemSlug/sellerId) [Line 18]
                  │           └─ navigateToScreen() [Line 92]
                  │               └─ Navigate to MainActivity [Line 133]
                  │                   └─ lib/ui/screens/main_activity.dart
                  │                       └─ initState() [Line 107]
                  │                           └─ Navigate to target [Lines 135-142]
                  │
                  └─ If app running (previousRoute.isNotEmpty)
                      └─ Navigate directly to target screen [Lines 169, 181]
```

---

## 🎯 Quick Reference: Common Tasks

### Task: Share a Product
```dart
// Location: Anywhere in your app
HelperUtils.shareItem(context, 'product-details', productSlug);
```

### Task: Share a Seller Profile
```dart
// Location: Anywhere in your app
HelperUtils.shareItem(context, 'seller', sellerId.toString());
```

### Task: Generate Deep Link Programmatically
```dart
// Location: Anywhere in your app
String link = HelperUtils.nativeDeepLinkUrl('product-details', productSlug);
// Use this link for custom sharing, QR codes, etc.
```

### Task: Navigate to Product from Deep Link
```dart
// Location: Handled automatically by Routes.onGenerateRouted()
// No manual code needed - just ensure route name matches pattern
Navigator.pushNamed(context, '/product-details/$slug');
```

---

## 📊 File Impact Matrix

| File | Impact | Modification Frequency |
|------|--------|----------------------|
| `AndroidManifest.xml` | High | Rare (only when adding new patterns) |
| `Info.plist` | High | Rare (only when adding new schemes) |
| `routes.dart` | Critical | Medium (when adding new deep link types) |
| `helper_utils.dart` | Medium | Low (stable utility functions) |
| `splash_screen.dart` | Medium | Low (stable initialization) |
| `main_activity.dart` | Medium | Low (stable initialization) |
| `settings.dart` | Low | Rare (only when changing domain) |

---

## 🔐 Security Considerations

### Current Implementation:
- ✅ Uses HTTPS for shareable links
- ✅ Android `autoVerify="true"` for App Links
- ⚠️ No validation of deep link parameters
- ⚠️ No rate limiting on deep link handling

### Recommendations:
1. Add parameter validation in `routes.dart`
2. Implement error handling for invalid slugs/IDs
3. Add analytics to track deep link usage
4. Consider adding authentication checks for sensitive deep links

---

**Document Version**: 1.0  
**Last Updated**: January 29, 2026  
**App Version**: 2.5.0+34
