# 🚀 Android Release Build - Play Store Deployment

**Build Date:** December 16, 2025  
**App Name:** Kora (Bhutan Market)  
**Package:** com.bhutanmarket.srvtech  
**Version:** 2.5.0 (Build 28)

---

## ✅ Build Status: SUCCESS

### 📦 Release App Bundle Details

- **File:** `app-release.aab`
- **Location:** `/Users/pranab/workspace/Ads-marketplace-Mobile/build/app/outputs/bundle/release/app-release.aab`
- **Size:** 76 MB (79.3 MB uncompressed)
- **Format:** Android App Bundle (AAB) - **Play Store Ready**
- **Signed:** ✅ Yes, with upload keystore
- **Build Tool:** Flutter (via fvm)

---

## 🔐 Keystore Details

**IMPORTANT:** Keep this information secure and backed up!

- **Keystore File:** `/Users/pranab/upload-keystore.jks`
- **Key Alias:** `upload`
- **Certificate Owner:** CN=pranbesh sarkar, OU=srv, O=srv, L=siliguri
- **Signature Algorithm:** SHA384withRSA (2048-bit RSA)
- **Validity:** December 16, 2025 to May 3, 2053 (10,000 days)

**⚠️ Security Notes:**
- The keystore password is stored in `android/key.properties` (gitignored)
- **BACKUP YOUR KEYSTORE:** Store `upload-keystore.jks` securely
- Never commit the keystore or key.properties to version control
- If you lose the keystore, you cannot update the app on Play Store

---

## 📋 Configuration Files Modified

### 1. `android/app/build.gradle`
- ✅ Added keystoreProperties loading
- ✅ Configured release signing configuration
- ✅ Updated buildTypes to use release signing

### 2. `android/key.properties`
- ✅ Created and configured with keystore credentials
- ✅ Properly gitignored for security

---

## 🎯 Next Steps: Upload to Google Play Store

### 1. **Create/Access Google Play Console Account**
   - Go to: https://play.google.com/console
   - Create a developer account (one-time $25 fee if new)

### 2. **Create a New App**
   - Click "Create app"
   - Fill in app details:
     - App name: **Kora** (or your preferred name)
     - Default language: English
     - App or game: App
     - Free or paid: (Your choice)
   - Accept Play Console policies

### 3. **Upload the App Bundle**
   - Navigate to: **Production** → **Create new release**
   - Upload: `/Users/pranab/workspace/Ads-marketplace-Mobile/build/app/outputs/bundle/release/app-release.aab`
   - Fill in release notes

### 4. **Complete Store Listing**
   - Add app description
   - Upload screenshots (phone, tablet)
   - Add app icon (512x512 PNG)
   - Add feature graphic (1024x500)
   - Set content rating
   - Set target audience

### 5. **Set Pricing & Distribution**
   - Select countries
   - Confirm content guidelines
   - Set up privacy policy URL

### 6. **Submit for Review**
   - Google will review your app
   - Typically takes 1-7 days
   - You'll receive notification when approved

---

## 🔄 Future Release Builds

To create subsequent releases:

```bash
# Update version in pubspec.yaml or build.gradle
# Then run:
fvm flutter clean
fvm flutter build appbundle --release
```

The signed AAB will be at the same location:
`build/app/outputs/bundle/release/app-release.aab`

---

## 📱 Testing the Release Build

### Option 1: Internal Testing
Upload the AAB to Play Console's Internal Testing track first.

### Option 2: Build and Install APK
For direct device testing:
```bash
fvm flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🐛 Troubleshooting

### If build fails with signing error:
1. Verify `android/key.properties` exists and has correct values
2. Verify keystore file exists at specified location
3. Run: `fvm flutter clean` and rebuild

### If Play Store rejects the AAB:
1. Check that all required permissions are justified
2. Ensure privacy policy is provided
3. Verify target SDK version (currently: 35)

---

## 📞 Important Contacts & Resources

- **Flutter Android Deployment Docs:** https://docs.flutter.dev/deployment/android
- **Google Play Console:** https://play.google.com/console
- **Play Store Policies:** https://play.google/developer-content-policy

---

## ✅ Checklist for Play Store Submission

- [ ] App bundle built and signed
- [ ] App tested thoroughly
- [ ] Screenshots prepared (minimum 2, different screen sizes)
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500)
- [ ] Privacy policy URL
- [ ] App description and short description
- [ ] Content rating questionnaire completed
- [ ] Target countries selected
- [ ] Pricing set
- [ ] Review and submit

---

**Build completed successfully on:** December 16, 2025, 12:57 PM IST  
**Ready for Google Play Store submission** 🎉
