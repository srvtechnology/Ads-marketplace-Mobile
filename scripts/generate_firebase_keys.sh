#!/bin/bash
# generate_firebase_keys.sh
# This script extracts SHA-1 and SHA-256 fingerprints from the Android debug keystore.
# It is useful for adding the keys to Firebase console for Android app authentication.

# Default debug keystore location and credentials
KEYSTORE="$HOME/.android/debug.keystore"
ALIAS="androiddebugkey"
STOREPASS="android"
KEYPASS="android"

if [ ! -f "$KEYSTORE" ]; then
  echo "Error: Keystore not found at $KEYSTORE"
  exit 1
fi

# Use keytool to list the certificate details
OUTPUT=$(keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$STOREPASS" -keypass "$KEYPASS" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "Error: Failed to read keystore. Ensure keytool is installed and the credentials are correct."
  exit 1
fi

# Extract SHA-1 and SHA-256 fingerprints
SHA1=$(echo "$OUTPUT" | grep "SHA1:" | awk '{print $2}')
SHA256=$(echo "$OUTPUT" | grep "SHA256:" | awk '{print $2}')

if [ -z "$SHA1" ] || [ -z "$SHA256" ]; then
  echo "Error: Could not extract SHA fingerprints."
  exit 1
fi

echo "SHA-1:   $SHA1"
echo "SHA-256: $SHA256"

# Optionally, you can copy the values to clipboard (macOS)
if command -v pbcopy >/dev/null 2>&1; then
  echo "$SHA1" | pbcopy
  echo "SHA-1 fingerprint copied to clipboard."
fi
