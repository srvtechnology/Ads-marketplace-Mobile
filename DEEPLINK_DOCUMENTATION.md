# Deep Link Configuration Documentation

## Overview
This document provides a comprehensive overview of the deep link implementation in the Ads-marketplace-Mobile (Kora) application.

## Deep Link Architecture

### 1. **Deep Link Scheme**
- **Custom Scheme**: `bhutanmarket://`
- **Web Domain**: `admin.thebhutanmarket.com`
- **Protocol**: HTTPS (for universal/app links)

### 2. **Supported Deep Link Patterns**

#### Pattern 1: Product Details
```
bhutanmarket://admin.thebhutanmarket.com/product-details/{slug}
https://admin.thebhutanmarket.com/product-details/{slug}?share=true
```
- **Purpose**: Navigate to a specific product/item details page
- **Parameter**: `slug` - Unique identifier for the product

#### Pattern 2: Seller Profile
```
bhutanmarket://admin.thebhutanmarket.com/seller/{sellerId}
https://admin.thebhutanmarket.com/seller/{sellerId}?share=true
```
- **Purpose**: Navigate to a specific seller's profile page
- **Parameter**: `sellerId` - Unique identifier for the seller

---

## Platform-Specific Configuration

### Android Configuration

#### File: `android/app/src/main/AndroidManifest.xml`

**1. Deep Link Enabled Flag** (Line 88)
```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
```

**2. Intent Filter Configuration** (Lines 105-125)
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <!-- Product Details Deep Link -->
    <data
        android:host="admin.thebhutanmarket.com"
        android:pathPattern="/product-details/.*"
        android:scheme="bhutanmarket" />
    
    <!-- Seller Profile Deep Link -->
    <data
        android:host="admin.thebhutanmarket.com"
        android:pathPattern="/seller/.*"
        android:scheme="bhutanmarket" />
</intent-filter>
```

**Key Features:**
- `android:autoVerify="true"` - Enables Android App Links (verified deep links)
- `BROWSABLE` category - Allows links to be opened from web browsers
- Path patterns use regex `.*` to match any slug/ID after the base path

**3. Additional Schemes** (Lines 32, 40, 45)
```xml
<!-- HTTPS scheme for web links -->
<data android:scheme="https" />

<!-- SMS scheme -->
<data android:scheme="sms" />

<!-- Telephone scheme -->
<data android:scheme="tel" />
```

---

### iOS Configuration

#### File: `ios/Runner/Info.plist`

**CFBundleURLTypes Configuration** (Lines 25-51)
```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Firebase Auth URL Scheme -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>app-1-160192430600-ios-3baa7e5273363df41647bd</string>
        </array>
    </dict>
    
    <!-- Google Sign-In URL Scheme -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.160192430600-8co6vdd9p9n696rc64mq2a2tqsass9o8</string>
        </array>
    </dict>
    
    <!-- Custom App Deep Link Scheme -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bhutanmarket</string>
        </array>
    </dict>
</array>
```

**LSApplicationQueriesSchemes** (Lines 60-68)
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sms</string>
    <string>tel</string>
    <string>mailto</string>
    <string>items-beta</string>
    <string>https</string>
    <string>http</string>
</array>
```

---

## Flutter Implementation

### 1. **Deep Link URL Generation**

#### File: `lib/utils/helper_utils.dart` (Lines 96-98)

```dart
static String nativeDeepLinkUrl(String type, String value) {
  return "https://${AppSettings.shareNavigationWebUrl}/$type/$value?share=true";
}
```

**Usage:**
- Generates shareable deep links for products and sellers
- Format: `https://admin.thebhutanmarket.com/{type}/{value}?share=true`
- Types: `product-details`, `seller`

**Share Functionality** (Lines 100-144)
```dart
static void shareItem(BuildContext context, String type, String slug) {
  // Shows bottom sheet with:
  // 1. Copy Link option - Copies deep link to clipboard
  // 2. Share option - Opens native share dialog
}
```

---

### 2. **Deep Link Routing**

#### File: `lib/app/routes.dart` (Lines 151-186)

**Route Handler:**
```dart
static Route onGenerateRouted(RouteSettings routeSettings) {
  // Check if route contains deep link patterns
  if (routeSettings.name!.contains('/product-details/') ||
      routeSettings.name!.contains('/seller/')) {
    
    final uri = Uri.parse(routeSettings.name!);
    final pathSegments = uri.pathSegments;
    
    final type = pathSegments[0]; // 'product-details' or 'seller'
    final value = pathSegments[1]; // slug or id
    
    HiveUtils.setUserSkip(); // Mark user as having interacted with app
    
    if (type == 'product-details') {
      if (previousRoute.isEmpty) {
        // App was terminated - go through splash screen
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
        // App was terminated - go through splash screen
        return MaterialPageRoute(
            builder: (_) => SplashScreen(sellerId: value));
      } else {
        // App is running - navigate directly
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

---

### 3. **Splash Screen Deep Link Handling**

#### File: `lib/ui/screens/splash_screen.dart` (Lines 18-24)

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.itemSlug, super.key, this.sellerId});

  // Used when the app is terminated and then is opened using deep link
  // The main route needs to be added to navigation stack
  final String? itemSlug;
  final String? sellerId;
}
```

**Navigation Logic** (Lines 92-156)
```dart
void navigateToScreen() async {
  // ... maintenance and onboarding checks ...
  
  if (HiveUtils.isUserAuthenticated()) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Pass slug/sellerId to MainActivity
        Navigator.of(context).pushReplacementNamed(Routes.main, arguments: {
          'from': "main",
          "slug": widget.itemSlug,
          "sellerId": widget.sellerId
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

### 4. **MainActivity Deep Link Handling**

#### File: `lib/ui/screens/main_activity.dart` (Lines 64-65, 135-142)

```dart
class MainActivity extends StatefulWidget {
  final String from;
  final String? itemSlug;
  final String? sellerId;
  // ...
}

@override
void initState() {
  super.initState();
  // ... other initialization ...
  
  // Handle deep link navigation after MainActivity is ready
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

### 5. **Configuration Settings**

#### File: `lib/settings.dart` (Line 45)

```dart
static const String shareNavigationWebUrl = "admin.thebhutanmarket.com";
```

This constant defines the domain used for generating shareable deep links.

---

## Deep Link Flow Diagrams

### Flow 1: App Terminated → Deep Link Opened

```
User clicks deep link
    ↓
Android/iOS system receives intent
    ↓
App launches
    ↓
Routes.onGenerateRouted() detects deep link pattern
    ↓
previousRoute.isEmpty = true
    ↓
Navigate to SplashScreen(itemSlug: value) or SplashScreen(sellerId: value)
    ↓
SplashScreen loads system settings
    ↓
Navigate to MainActivity with slug/sellerId parameters
    ↓
MainActivity.initState() detects parameters
    ↓
Navigate to AdDetailsScreen or SellerProfileScreen
```

### Flow 2: App Running → Deep Link Opened

```
User clicks deep link (app already running)
    ↓
Android/iOS system sends intent to running app
    ↓
Routes.onGenerateRouted() detects deep link pattern
    ↓
previousRoute.isNotEmpty = true
    ↓
Check if already on target screen → pop if needed
    ↓
Navigate directly to AdDetailsScreen or SellerProfileScreen
```

### Flow 3: Share Deep Link

```
User taps share button on product/seller
    ↓
HelperUtils.shareItem() called
    ↓
Bottom sheet appears with options
    ↓
User selects "Copy Link" or "Share"
    ↓
nativeDeepLinkUrl() generates link
    ↓
Format: https://admin.thebhutanmarket.com/{type}/{value}?share=true
    ↓
Link copied to clipboard or shared via native dialog
```

---

## Important Notes

### 1. **Commented Out Dependencies**
The following deep link packages are commented out in `pubspec.yaml`:
```yaml
#app_links: ^6.3.1
```

And in code files:
```dart
//import 'package:app_links/app_links.dart';  // main_activity.dart line 6
//import 'package:uni_links/uni_links.dart';  // home_screen.dart line 31
```

**Current Implementation**: Uses Flutter's built-in deep linking via route handling instead of third-party packages.

### 2. **Android App Links Verification**

For Android App Links to work properly, you need to host a Digital Asset Links JSON file at:
```
https://admin.thebhutanmarket.com/.well-known/assetlinks.json
```

**Required assetlinks.json format:**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.bhutanmarket.srvtech",
    "sha256_cert_fingerprints": [  "4D:47:BB:DD:AD:EE:3F:FB:06:A3:06:0E:87:05:64:DC:E0:FC:6B:CC:72:78:CF:73:EB:8F:53:C9:5D:23:2E:02"
    ]
  }
}]
```

### 3. **iOS Universal Links**

For iOS Universal Links, you need to host an Apple App Site Association file at:
```
https://admin.thebhutanmarket.com/.well-known/apple-app-site-association
```

**Required apple-app-site-association format:**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "S8FMPCAZUD.com.bhutanmarket.srvtech",
        "paths": [
          "/product-details/*",
          "/seller/*"
        ]
      }
    ]
  }
}
```

### 4. **Testing Deep Links**

**Android:**
```bash
# Test custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "bhutanmarket://admin.thebhutanmarket.com/product-details/test-slug"

# Test HTTPS (App Links)
adb shell am start -W -a android.intent.action.VIEW -d "https://admin.thebhutanmarket.com/product-details/test-slug"
```

**iOS:**
```bash
# Test custom scheme
xcrun simctl openurl booted "bhutanmarket://admin.thebhutanmarket.com/product-details/test-slug"

# Test HTTPS (Universal Links)
xcrun simctl openurl booted "https://admin.thebhutanmarket.com/product-details/test-slug"
```

---

## Missing Components

### 1. **No Active Deep Link Listener**
The app currently doesn't have an active listener for deep links when the app is already running in the background. The commented-out `app_links` package would provide this functionality.

### 2. **No Web Verification Files**
The `.well-known` directory files (assetlinks.json and apple-app-site-association) are not present in the repository. These need to be hosted on the web server at `admin.thebhutanmarket.com`.

### 3. **No Dynamic Link Handling**
There's no implementation for Firebase Dynamic Links, which could provide:
- Link analytics
- Link shortening
- Deferred deep linking (install attribution)
- Cross-platform link sharing

---

## Recommendations

### 1. **Enable app_links Package**
Uncomment and implement the `app_links` package for better deep link handling:
```yaml
app_links: ^6.3.1
```

### 2. **Add Web Verification Files**
Create and host the required verification files on your web server.

### 3. **Add Deep Link Analytics**
Track deep link usage for better insights:
- Which links are most clicked
- Conversion rates from deep links
- User journey after deep link entry

### 4. **Add Error Handling**
Implement fallback behavior when:
- Deep link points to non-existent content
- User is not authenticated but link requires auth
- Network issues prevent content loading

### 5. **Add Deep Link Preview**
Implement Open Graph meta tags on the web version for better link previews in social media and messaging apps.

---

## Summary

The app implements a **hybrid deep linking approach**:
- **Custom URL Scheme**: `bhutanmarket://` for direct app-to-app linking
- **Universal/App Links**: HTTPS URLs for web-to-app linking
- **Route-based handling**: Deep links are processed through Flutter's routing system
- **Deferred navigation**: Handles both cold start (app terminated) and warm start (app running) scenarios

The implementation is functional but could be enhanced with proper web verification files and active deep link listeners for a more robust experience.
