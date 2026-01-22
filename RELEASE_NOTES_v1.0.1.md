# Release v1.0.1 - Bug Fixes and Stability Improvements

## 🐛 Bug Fixes
- **Fixed critical crash on app startup**: Moved MainActivity to correct package (`com.ridepulse.app`)
- **Fixed signing configuration**: Added proper null handling for keystore properties
- **Fixed notification service**: Corrected icon reference and added error handling

## 🔧 Improvements
- Added global error handler in main.dart for better crash reporting
- Added try-catch in NotificationService initialization
- Improved error handling in signing configuration

## 📦 Technical Details
- **Version Code**: 3
- **Version Name**: 1.0.1
- **Package**: com.ridepulse.app
- **Min SDK**: 24
- **Target SDK**: 36

## 📲 Installation
Download the APK file and install on your Android device (Android 7.0 or higher).

**File**: `RidePulse-v1.0.1-release.apk`
**Size**: ~55.7 MB

## 🔍 Full Changelog
- f713d3a: Fix signing config to handle null storeFile property
- 89f9678: Fix app crash: move MainActivity to correct package and improve error handling
- 326f581: Bump version to 1.0.1
