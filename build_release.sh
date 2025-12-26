#!/bin/bash

# Quick Release Build Script for Play Store
# This script builds a signed release app bundle

echo "🚀 Building Release App Bundle for Play Store"
echo "=============================================="
echo ""

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo "❌ Error: android/key.properties not found!"
    echo "Please ensure your keystore is configured properly."
    exit 1
fi

# Check if keystore file exists
KEYSTORE_FILE=$(grep "storeFile=" android/key.properties | cut -d'=' -f2)
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo "❌ Error: Keystore file not found at: $KEYSTORE_FILE"
    exit 1
fi

echo "✅ Keystore configuration verified"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
fvm flutter clean
echo ""

# Build the release app bundle
echo "🔨 Building signed release app bundle..."
fvm flutter build appbundle --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =============================================="
    echo "✅ BUILD SUCCESSFUL!"
    echo "✅ =============================================="
    echo ""
    echo "📦 App Bundle Location:"
    echo "   $(pwd)/build/app/outputs/bundle/release/app-release.aab"
    echo ""
    
    # Get file size
    FILE_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    echo "📊 File Size: $FILE_SIZE"
    echo ""
    
    echo "🎯 Next Steps:"
    echo "   1. Go to Google Play Console: https://play.google.com/console"
    echo "   2. Upload the app-release.aab file"
    echo "   3. Fill in release notes and submit for review"
    echo ""
    echo "🔐 Don't forget to backup your keystore:"
    echo "   $KEYSTORE_FILE"
    echo ""
else
    echo ""
    echo "❌ =============================================="
    echo "❌ BUILD FAILED!"
    echo "❌ =============================================="
    echo ""
    echo "Check the error messages above for details."
    exit 1
fi
