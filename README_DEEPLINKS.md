# Deep Link Documentation Index

Welcome to the comprehensive deep link documentation for the **Kora (Ads-marketplace-Mobile)** application.

---

## 📚 Documentation Files

This documentation is split into multiple files for easy navigation:

### 1. **DEEPLINK_DOCUMENTATION.md** - Complete Technical Documentation
   - **Purpose**: Comprehensive deep link implementation guide
   - **Contents**:
     - Deep link architecture overview
     - Platform-specific configurations (Android & iOS)
     - Flutter implementation details
     - Flow diagrams
     - Testing instructions
     - Missing components analysis
     - Recommendations for improvements
   - **Best For**: Developers who need to understand or modify the deep link system
   - **Read Time**: ~15 minutes

### 2. **DEEPLINK_SUMMARY.md** - Quick Reference Guide
   - **Purpose**: Fast lookup for common deep link tasks
   - **Contents**:
     - Quick reference tables
     - Testing commands (copy-paste ready)
     - Configuration matrix
     - Implementation checklist
     - Code examples
     - Debugging tips
   - **Best For**: Quick lookups and testing
   - **Read Time**: ~5 minutes

### 3. **DEEPLINK_FILE_LOCATIONS.md** - Code Location Guide
   - **Purpose**: Find specific code and understand file structure
   - **Contents**:
     - Complete file structure
     - Exact line numbers for all deep link code
     - Code snippets with context
     - File impact matrix
     - Common tasks with code examples
   - **Best For**: Navigating the codebase and making targeted changes
   - **Read Time**: ~10 minutes

### 4. **deeplink_architecture.png** - Visual Diagram
   - **Purpose**: Visual representation of deep link flow
   - **Contents**: Architecture diagram showing the complete deep link flow from user click to destination screen
   - **Best For**: Understanding the overall system at a glance

---

## 🚀 Quick Start Guide

### For First-Time Readers:
1. Start with **DEEPLINK_SUMMARY.md** to get an overview
2. Look at **deeplink_architecture.png** for visual understanding
3. Read **DEEPLINK_DOCUMENTATION.md** for complete details
4. Use **DEEPLINK_FILE_LOCATIONS.md** when you need to modify code

### For Testing Deep Links:
1. Go to **DEEPLINK_SUMMARY.md** → "Testing Commands" section
2. Copy the appropriate command for your platform
3. Run it in your terminal

### For Adding New Deep Link Types:
1. Check **DEEPLINK_FILE_LOCATIONS.md** → "To Add New Deep Link Type"
2. Follow the three-step process
3. Refer to **DEEPLINK_DOCUMENTATION.md** for detailed examples

### For Debugging Issues:
1. Check **DEEPLINK_SUMMARY.md** → "Debugging Tips"
2. Review **DEEPLINK_FILE_LOCATIONS.md** → "Code Flow Summary"
3. Add breakpoints at locations mentioned in the flow

---

## 🎯 Common Use Cases

### Use Case 1: "I want to test if deep links work"
**Solution**: 
- Go to: **DEEPLINK_SUMMARY.md** → Testing Commands
- Run the Android or iOS test command
- Expected result: App opens to product/seller screen

### Use Case 2: "I need to add a new deep link pattern"
**Solution**:
- Go to: **DEEPLINK_FILE_LOCATIONS.md** → "To Add New Deep Link Type"
- Follow the modification steps
- Test using commands from **DEEPLINK_SUMMARY.md**

### Use Case 3: "Deep links aren't working on production"
**Solution**:
- Check: **DEEPLINK_DOCUMENTATION.md** → "Missing Components"
- Likely issue: Missing web verification files
- Action: Create assetlinks.json and apple-app-site-association files

### Use Case 4: "I want to share a product via deep link"
**Solution**:
- Code: `HelperUtils.shareItem(context, 'product-details', productSlug);`
- Details in: **DEEPLINK_FILE_LOCATIONS.md** → "Quick Reference: Common Tasks"

### Use Case 5: "I need to understand the complete flow"
**Solution**:
- Read: **DEEPLINK_DOCUMENTATION.md** → "Deep Link Flow Diagrams"
- Visual: **deeplink_architecture.png**
- Code flow: **DEEPLINK_FILE_LOCATIONS.md** → "Code Flow Summary"

---

## 📊 Current Implementation Status

| Feature | Status | Details |
|---------|--------|---------|
| **Custom Scheme** | ✅ Working | `bhutanmarket://` |
| **HTTPS Deep Links** | ✅ Working | `https://eclassifyweb.wrteam.me` |
| **Product Deep Links** | ✅ Working | `/product-details/{slug}` |
| **Seller Deep Links** | ✅ Working | `/seller/{sellerId}` |
| **Share Functionality** | ✅ Working | Copy & Share options |
| **Cold Start Handling** | ✅ Working | Via SplashScreen |
| **Warm Start Handling** | ✅ Working | Via MainActivity |
| **Android App Links** | ⚠️ Partial | Needs assetlinks.json |
| **iOS Universal Links** | ⚠️ Partial | Needs apple-app-site-association |
| **Deep Link Listener** | ❌ Not Implemented | app_links package commented out |
| **Analytics** | ❌ Not Implemented | No tracking |
| **Error Handling** | ⚠️ Basic | No validation of parameters |

---

## 🔧 Key Configuration Values

### Deep Link Scheme
```
bhutanmarket://
```

### Web Domain
```
eclassifyweb.wrteam.me
```

### Package Name
```
Android: com.bhutanmarket.srvtech
iOS: com.bhutanmarket.srvtech
```

### Supported Patterns
```
/product-details/{slug}
/seller/{sellerId}
```

---

## 📝 Important Notes

### 1. Web Verification Files Required
For production deep links to work properly, you must host these files:

**Android App Links:**
```
https://eclassifyweb.wrteam.me/.well-known/assetlinks.json
```

**iOS Universal Links:**
```
https://eclassifyweb.wrteam.me/.well-known/apple-app-site-association
```

See **DEEPLINK_DOCUMENTATION.md** for file templates.

### 2. Commented Out Package
The `app_links` package is commented out in `pubspec.yaml`. This package would provide:
- Active deep link listening
- Better background handling
- Stream-based deep link events

Consider enabling it for production use.

### 3. Testing Environment
Deep links work differently in development vs production:
- **Development**: Custom scheme works immediately
- **Production**: HTTPS links require web verification files

---

## 🛠️ Maintenance Checklist

### Monthly:
- [ ] Test deep links on latest Android version
- [ ] Test deep links on latest iOS version
- [ ] Verify web verification files are accessible
- [ ] Check deep link analytics (if implemented)

### When Adding New Features:
- [ ] Update deep link patterns if needed
- [ ] Update documentation
- [ ] Test all existing deep link patterns
- [ ] Update web verification files

### Before Production Release:
- [ ] Verify assetlinks.json is deployed
- [ ] Verify apple-app-site-association is deployed
- [ ] Test deep links from email, SMS, browser
- [ ] Test both cold start and warm start scenarios
- [ ] Verify share functionality works

---

## 🆘 Troubleshooting Guide

### Problem: Deep links not working on Android
**Check**:
1. Is `flutter_deeplinking_enabled` set to true? → **DEEPLINK_FILE_LOCATIONS.md** Line reference
2. Is assetlinks.json accessible? → Test with curl command in **DEEPLINK_SUMMARY.md**
3. Is app installed with correct package name?

### Problem: Deep links not working on iOS
**Check**:
1. Is URL scheme registered? → Check **DEEPLINK_FILE_LOCATIONS.md** iOS section
2. Is apple-app-site-association accessible?
3. Are associated domains configured in Xcode?

### Problem: App opens but doesn't navigate to correct screen
**Debug**:
1. Add breakpoint in `routes.dart` line 151
2. Check if `routeSettings.name` contains expected pattern
3. Verify `pathSegments` parsing
4. Check if `itemSlug` or `sellerId` is passed correctly

### Problem: Share functionality not working
**Check**:
1. Is `share_plus` package installed? → Check **DEEPLINK_FILE_LOCATIONS.md** dependencies
2. Are permissions granted?
3. Test with simple text first

---

## 📞 Support & Resources

### Internal Documentation:
- **DEEPLINK_DOCUMENTATION.md** - Full technical guide
- **DEEPLINK_SUMMARY.md** - Quick reference
- **DEEPLINK_FILE_LOCATIONS.md** - Code locations
- **deeplink_architecture.png** - Visual diagram

### External Resources:
- [Android App Links Guide](https://developer.android.com/training/app-links)
- [iOS Universal Links Guide](https://developer.apple.com/ios/universal-links/)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)
- [app_links Package](https://pub.dev/packages/app_links)

### Code References:
- Main routing: `lib/app/routes.dart`
- URL generation: `lib/utils/helper_utils.dart`
- Android config: `android/app/src/main/AndroidManifest.xml`
- iOS config: `ios/Runner/Info.plist`

---

## 📈 Future Enhancements

### Recommended Improvements:
1. **Enable app_links package** for better deep link handling
2. **Add web verification files** for production App Links
3. **Implement analytics** to track deep link usage
4. **Add parameter validation** for security
5. **Create Firebase Dynamic Links** for advanced features
6. **Add error handling** for invalid deep links
7. **Implement deep link preview** with Open Graph tags

See **DEEPLINK_DOCUMENTATION.md** → "Recommendations" for detailed implementation guides.

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 29, 2026 | Initial documentation created |
| - | - | Documented existing implementation |
| - | - | Created comprehensive guides |
| - | - | Added testing commands |
| - | - | Identified missing components |

---

## 📄 Document Structure

```
Deep Link Documentation/
│
├── README_DEEPLINKS.md (This file)
│   └── Index and navigation guide
│
├── DEEPLINK_DOCUMENTATION.md
│   └── Complete technical documentation
│
├── DEEPLINK_SUMMARY.md
│   └── Quick reference and testing guide
│
├── DEEPLINK_FILE_LOCATIONS.md
│   └── Code locations and snippets
│
└── deeplink_architecture.png
    └── Visual architecture diagram
```

---

## ✅ Getting Started Checklist

For new developers working with deep links:

- [ ] Read **DEEPLINK_SUMMARY.md** (5 min)
- [ ] View **deeplink_architecture.png** (2 min)
- [ ] Test deep links using commands from summary (5 min)
- [ ] Read **DEEPLINK_DOCUMENTATION.md** sections relevant to your task (15 min)
- [ ] Bookmark **DEEPLINK_FILE_LOCATIONS.md** for quick code lookup
- [ ] Set up breakpoints in key files for debugging
- [ ] Test both cold start and warm start scenarios
- [ ] Verify understanding by explaining flow to a colleague

---

**Last Updated**: January 29, 2026  
**App Version**: 2.5.0+34  
**Documentation Version**: 1.0  
**Maintained By**: Development Team

---

## 🎓 Learning Path

### Beginner Level:
1. Read **DEEPLINK_SUMMARY.md** → Quick Reference
2. Run test commands
3. Understand the two deep link patterns (product & seller)

### Intermediate Level:
1. Read **DEEPLINK_DOCUMENTATION.md** → Flow Diagrams
2. Trace code flow using **DEEPLINK_FILE_LOCATIONS.md**
3. Modify a deep link pattern
4. Test your changes

### Advanced Level:
1. Read complete **DEEPLINK_DOCUMENTATION.md**
2. Implement missing components (web verification files)
3. Add new deep link type
4. Enable app_links package
5. Implement analytics

---

**Need Help?** Start with the appropriate documentation file based on your task, and refer to the troubleshooting guide if you encounter issues.
