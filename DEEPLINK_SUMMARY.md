# Deep Link Configuration Summary

## Quick Reference

### 🔗 Deep Link Patterns

| Type | Custom Scheme | HTTPS URL |
|------|--------------|-----------|
| **Product** | `bhutanmarket://admin.thebhutanmarket.com/product-details/{slug}` | `https://admin.thebhutanmarket.com/product-details/{slug}?share=true` |
| **Seller** | `bhutanmarket://admin.thebhutanmarket.com/seller/{sellerId}` | `https://admin.thebhutanmarket.com/seller/{sellerId}?share=true` |

---

## 📱 Platform Configuration Files

### Android
- **File**: `android/app/src/main/AndroidManifest.xml`
- **Key Lines**: 88-109
- **Features**:
  - ✅ Flutter deep linking enabled
  - ✅ Auto-verify for App Links
  - ✅ Custom scheme: `bhutanmarket`
  - ✅ Host: `admin.thebhutanmarket.com`
  - ✅ Path patterns: `/product-details/*` and `/seller/*`

### iOS
- **File**: `ios/Runner/Info.plist`
- **Key Lines**: 25-51
- **Features**:
  - ✅ Custom URL scheme: `bhutanmarket`
  - ✅ Firebase Auth scheme
  - ✅ Google Sign-In scheme
  - ✅ Query schemes for external apps

---

## 🔧 Code Implementation

### Key Files

| File | Purpose | Key Functions |
|------|---------|---------------|
| `lib/utils/helper_utils.dart` | Deep link URL generation | `nativeDeepLinkUrl()`, `shareItem()` |
| `lib/app/routes.dart` | Deep link routing | `onGenerateRouted()` |
| `lib/ui/screens/splash_screen.dart` | Cold start handling | `navigateToScreen()` |
| `lib/ui/screens/main_activity.dart` | Warm start handling | `initState()` |
| `lib/settings.dart` | Configuration | `shareNavigationWebUrl` constant |

---

## 🌊 Deep Link Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    User Clicks Deep Link                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────┐
         │   Is App Running?       │
         └──────┬──────────┬───────┘
                │          │
        ┌───────┘          └────────┐
        │ NO                      YES│
        ▼                            ▼
┌───────────────┐          ┌─────────────────┐
│ App Launches  │          │ App Receives    │
│ (Cold Start)  │          │ Intent          │
└───────┬───────┘          │ (Warm Start)    │
        │                  └────────┬─────────┘
        ▼                           │
┌───────────────┐                   │
│ Routes.       │◄──────────────────┘
│ onGenerate    │
│ Routed()      │
└───────┬───────┘
        │
        ▼
┌───────────────────────────┐
│ Parse URL Path Segments   │
│ type = pathSegments[0]    │
│ value = pathSegments[1]   │
└───────┬───────────────────┘
        │
        ▼
    ┌───────────────┐
    │ previousRoute │
    │ isEmpty?      │
    └───┬───────┬───┘
        │       │
    YES │       │ NO
        │       │
        ▼       ▼
┌───────────┐ ┌──────────────┐
│ Splash    │ │ Navigate     │
│ Screen    │ │ Directly to  │
│ with      │ │ Target Screen│
│ params    │ └──────────────┘
└─────┬─────┘
      │
      ▼
┌─────────────┐
│ MainActivity│
│ with params │
└──────┬──────┘
       │
       ▼
┌──────────────┐
│ Target Screen│
│ (Ad Details  │
│ or Seller    │
│ Profile)     │
└──────────────┘
```

---

## 📊 Configuration Matrix

| Component | Android | iOS | Status |
|-----------|---------|-----|--------|
| **Custom Scheme** | `bhutanmarket` | `bhutanmarket` | ✅ Configured |
| **Host Domain** | `admin.thebhutanmarket.com` | `admin.thebhutanmarket.com` | ✅ Configured |
| **Product Pattern** | `/product-details/*` | - | ✅ Configured |
| **Seller Pattern** | `/seller/*` | - | ✅ Configured |
| **Auto Verify** | ✅ Enabled | N/A | ⚠️ Needs web file |
| **Universal Links** | N/A | - | ⚠️ Needs web file |
| **Deep Link Listener** | - | - | ❌ Not implemented |
| **Web Verification** | assetlinks.json | apple-app-site-association | ❌ Missing |

---

## 🧪 Testing Commands

### Android Testing

```bash
# Test Product Deep Link (Custom Scheme)
adb shell am start -W -a android.intent.action.VIEW \
  -d "bhutanmarket://admin.thebhutanmarket.com/product-details/test-product-123"

# Test Seller Deep Link (Custom Scheme)
adb shell am start -W -a android.intent.action.VIEW \
  -d "bhutanmarket://admin.thebhutanmarket.com/seller/456"

# Test Product Deep Link (HTTPS - App Links)
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://admin.thebhutanmarket.com/product-details/test-product-123?share=true"

# Test Seller Deep Link (HTTPS - App Links)
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://admin.thebhutanmarket.com/seller/456?share=true"
```

### iOS Testing

```bash
# Test Product Deep Link (Custom Scheme)
xcrun simctl openurl booted \
  "bhutanmarket://admin.thebhutanmarket.com/product-details/test-product-123"

# Test Seller Deep Link (Custom Scheme)
xcrun simctl openurl booted \
  "bhutanmarket://admin.thebhutanmarket.com/seller/456"

# Test Product Deep Link (HTTPS - Universal Links)
xcrun simctl openurl booted \
  "https://admin.thebhutanmarket.com/product-details/test-product-123?share=true"

# Test Seller Deep Link (HTTPS - Universal Links)
xcrun simctl openurl booted \
  "https://admin.thebhutanmarket.com/seller/456?share=true"
```

---

## ⚠️ Current Limitations

1. **No Active Deep Link Listener**
   - App doesn't listen for deep links when running in background
   - Commented out: `app_links` package in pubspec.yaml

2. **Missing Web Verification Files**
   - No `assetlinks.json` for Android App Links
   - No `apple-app-site-association` for iOS Universal Links
   - These must be hosted at: `https://admin.thebhutanmarket.com/.well-known/`

3. **No Dynamic Links**
   - No Firebase Dynamic Links implementation
   - No link analytics or attribution

4. **Limited Error Handling**
   - No fallback for invalid deep links
   - No handling for non-existent content

---

## 🚀 Quick Implementation Checklist

### To Enable Full Deep Linking:

- [ ] **Create assetlinks.json**
  ```json
  [{
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.bhutanmarket.srvtech",
      "sha256_cert_fingerprints": ["YOUR_SHA256_HERE"]
    }
  }]
  ```

- [ ] **Create apple-app-site-association**
  ```json
  {
    "applinks": {
      "apps": [],
      "details": [{
        "appID": "TEAM_ID.com.bhutanmarket.srvtech",
        "paths": ["/product-details/*", "/seller/*"]
      }]
    }
  }
  ```

- [ ] **Host files on web server**
  - Upload to: `https://admin.thebhutanmarket.com/.well-known/`
  - Ensure HTTPS is enabled
  - Verify files are accessible

- [ ] **Enable app_links package** (Optional but recommended)
  ```yaml
  dependencies:
    app_links: ^6.3.1
  ```

- [ ] **Test deep links on physical devices**
  - Test from SMS, email, web browser
  - Test both cold start and warm start
  - Verify both custom scheme and HTTPS URLs

---

## 📝 Code Examples

### Generate Deep Link
```dart
// In your code
String productLink = HelperUtils.nativeDeepLinkUrl('product-details', 'my-product-slug');
// Returns: https://admin.thebhutanmarket.com/product-details/my-product-slug?share=true

String sellerLink = HelperUtils.nativeDeepLinkUrl('seller', '123');
// Returns: https://admin.thebhutanmarket.com/seller/123?share=true
```

### Share Deep Link
```dart
// Show share dialog
HelperUtils.shareItem(context, 'product-details', 'my-product-slug');
// User can copy link or share via native dialog
```

### Handle Deep Link in Routes
```dart
// Automatically handled in Routes.onGenerateRouted()
// No manual code needed - just ensure route names match patterns:
// - /product-details/{slug}
// - /seller/{sellerId}
```

---

## 🔍 Debugging Tips

1. **Check if deep link is received:**
   - Add breakpoint in `Routes.onGenerateRouted()`
   - Check `routeSettings.name` value

2. **Verify Android App Links:**
   ```bash
   adb shell pm get-app-links com.bhutanmarket.srvtech
   ```

3. **Check iOS Universal Links:**
   - Settings → Your App → Associated Domains
   - Should show: `applinks:admin.thebhutanmarket.com`

4. **Test web verification files:**
   ```bash
   curl https://admin.thebhutanmarket.com/.well-known/assetlinks.json
   curl https://admin.thebhutanmarket.com/.well-known/apple-app-site-association
   ```

---

## 📚 Additional Resources

- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [iOS Universal Links Documentation](https://developer.apple.com/ios/universal-links/)
- [Flutter Deep Linking Guide](https://docs.flutter.dev/ui/navigation/deep-linking)
- [app_links Package](https://pub.dev/packages/app_links)

---

**Last Updated**: January 31, 2026
**App Version**: 2.5.0+34
**Package**: com.bhutanmarket.srvtech
