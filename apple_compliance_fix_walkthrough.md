# Apple Location Permission Compliance Fix

## Overview
Alignment with Apple's Guideline 5.1.1 regarding Location Permission requests. Apple flagged that our custom pre-permission dialog had:
1. A button labeled "Find My Location" (should be "Next" or "Continue").
2. An "Other Location" button that allowed exiting/delaying the permission request (user must proceed to permission request).

## Changes

### `lib/ui/screens/location_permission_screen.dart`
- Changed the primary button title from `"findMyLocation".translate(context)` to `"next".translate(context)`.
- Removed the secondary button `"otherLocation"`.
- This ensures the user flows directly from the explanation screen to the system permission prompt (or default location fallback if they deny system permission), satisfying the requirement to "always proceed to the permission request".

## Verification
- User login/signup -> Redirects to `LocationPermissionScreen`.
- Screen shows "Next" button.
- User clicks "Next" -> `_getCurrentLocation()` is triggered.
    - Requests system permission.
    - If allowed -> Navigate to Home.
    - If denied -> Sets default location and Navigate to Home.
- No option to "Other Location" to bypass the flow.
