# Quick Reference Guide

## Essential Commands (Run these first!)

```powershell
# 1. Install all dependencies
flutter pub get

# 2. Run code generation (important!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

## Code Generation Commands

```powershell
# One-time build (use this most of the time)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Development Commands

```powershell
# Run app on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>

# Hot reload (in running app)
# Press 'r' in terminal

# Hot restart (in running app)
# Press 'R' in terminal

# Clean build files
flutter clean

# Analyze code for issues
flutter analyze

# Format code
dart format lib/
```

## Build Commands

```powershell
# Build Android APK (Debug)
flutter build apk --debug

# Build Android APK (Release)
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release
```

## Package Management

```powershell
# Get packages
flutter pub get

# Upgrade packages
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Add a new package
# Edit pubspec.yaml then run:
flutter pub get
```

## Testing Commands

```powershell
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/feature_test.dart
```

## Troubleshooting Commands

```powershell
# Clean everything
flutter clean
flutter pub get

# Fix Gradle issues (Android)
cd android
./gradlew clean
cd ..

# Check Flutter setup
flutter doctor

# Fix Flutter doctor issues
flutter doctor --android-licenses

# Clear pub cache
flutter pub cache clean
flutter pub get
```

## VS Code Shortcuts (if using VS Code)

- `Ctrl + Shift + P` → "Flutter: New Project"
- `Ctrl + Shift + P` → "Flutter: Hot Reload"
- `Ctrl + Shift + P` → "Flutter: Hot Restart"
- `F5` → Start Debugging
- `Shift + F5` → Stop Debugging

## Android Studio Shortcuts

- `Shift + F10` → Run
- `Ctrl + F5` → Hot Reload
- `Ctrl + Shift + F10` → Hot Restart

## When You Make Changes To:

### Models (*.dart files with @JsonSerializable)
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependencies (pubspec.yaml)
```powershell
flutter pub get
```

### Native code (Android/iOS)
```powershell
flutter clean
flutter pub get
flutter run
```

### Assets (images, fonts, etc.)
```powershell
# Just hot restart (R) in running app
# Or rebuild the app
```

## Common Workflow

1. **Start Development:**
   ```powershell
   flutter pub get
   flutter run
   ```

2. **Make Code Changes:**
   - Edit Dart files
   - Press `r` for hot reload (UI changes)
   - Press `R` for hot restart (state reset)

3. **Add New Model/DataSource:**
   ```powershell
   # Create the file with annotations
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Add New Package:**
   ```powershell
   # Edit pubspec.yaml
   flutter pub get
   # Then hot restart
   ```

5. **Before Committing:**
   ```powershell
   flutter analyze
   dart format lib/
   flutter test
   ```

6. **Build for Production:**
   ```powershell
   flutter build apk --release
   # Or for Play Store:
   flutter build appbundle --release
   ```

## Quick Fixes

### "Target of URI doesn't exist" errors
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Failed to resolve dependencies"
```powershell
flutter clean
flutter pub get
```

### "No connected devices"
```powershell
# Check connected devices
flutter devices

# Start Android emulator from command line
emulator -avd <avd_name>
```

### App not updating
```powershell
# Hot restart
# Press R in terminal

# Or full rebuild
flutter clean
flutter run
```

## Project-Specific Notes

### Your Project Uses:
- ✅ flutter_bloc (State Management)
- ✅ get_it + injectable (Dependency Injection)
- ✅ dio + retrofit (API Calls)
- ✅ json_serializable (JSON Serialization)
- ✅ dartz (Functional Programming)

### After Creating New Files:
```powershell
# Always run if you create:
# - New models with @JsonSerializable
# - New data sources with @RestApi
# - New injectable classes with @injectable
flutter pub run build_runner build --delete-conflicting-outputs
```

## Need Help?

```powershell
# Get Flutter version
flutter --version

# Check environment setup
flutter doctor -v

# Get help on any command
flutter help <command>
```

---

**Pro Tip:** Keep code generation running in watch mode while developing:
```powershell
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate code whenever you save changes! 🚀
