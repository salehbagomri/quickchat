# 🧪 QuickChat Testing & Code Quality Guide

## Test Coverage

### Current Test Files
1. **widget_test.dart** - Main app widget tests
2. **services_test.dart** - Service layer unit tests
3. **whatsapp_service_test.dart** - WhatsApp integration tests

---

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget_test.dart
flutter test test/services_test.dart
flutter test test/whatsapp_service_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate Coverage Report (HTML)
```bash
# Install lcov first (if not installed)
# Windows: choco install lcov
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
# Windows: start coverage/html/index.html
# Mac: open coverage/html/index.html
# Linux: xdg-open coverage/html/index.html
```

---

## Test Structure

### Widget Tests
- App initialization
- Theme support (light/dark)
- Localization support (en/ar)
- Configuration tests

### Service Tests
- PreferencesService
  - Initialization
  - Language management
  - Theme management
  - First launch detection
  
- TemplateService
  - Template CRUD operations
  - Default templates
  - Template regeneration
  
- WhatsAppService
  - URL generation
  - Phone validation
  - Phone formatting
  - Launch functionality

### Model Tests
- MessageTemplate
  - Creation
  - Equality
  - Serialization

---

## Code Quality Tools

### Static Analysis
```bash
# Run analyzer
flutter analyze

# Fix formatting issues
dart format lib/ test/ -l 100

# Fix analysis issues automatically (where possible)
dart fix --apply
```

### Linting Rules
- **analysis_options.yaml** configured with strict rules
- 50+ lint rules enabled
- Enforces:
  - Const constructors
  - Final variables
  - Proper imports
  - Code style consistency
  - Error prevention

---

## Code Coverage Goals

### Target Coverage
- **Overall**: 80%+
- **Services**: 90%+
- **Models**: 95%+
- **Widgets**: 70%+

### Current Coverage
Run `flutter test --coverage` to check current coverage.

---

## Performance Optimization

### ProGuard Configuration
- Enabled in release builds
- R8 shrinking and obfuscation
- Removes unused code
- Optimizes bytecode
- Reduces APK size by ~30-40%

### Build Optimization
```bash
# Build optimized release
flutter build appbundle --release

# Build with split ABIs (smaller)
flutter build apk --release --split-per-abi

# Analyze bundle size
flutter build appbundle --release --analyze-size

# Check for large files
flutter build appbundle --release --tree-shake-icons
```

---

## Size Reduction Strategies

### 1. Asset Optimization
- ✅ Use SVG instead of PNG where possible
- ✅ Remove unused assets
- ✅ Compress images
- ✅ Use Google Fonts (downloaded on-demand)

### 2. Code Optimization
- ✅ Tree-shaking enabled
- ✅ ProGuard/R8 enabled
- ✅ Split ABIs
- ✅ Remove debug code

### 3. Dependencies
- ✅ Use only necessary packages
- ✅ Avoid large libraries
- ✅ Check package sizes before adding

### Target Sizes
- **APK**: < 15 MB (per ABI)
- **AAB**: < 20 MB
- **Universal APK**: < 45 MB

---

## Continuous Integration

### Pre-commit Checklist
- [ ] Run `flutter analyze` (no issues)
- [ ] Run `flutter test` (all pass)
- [ ] Run `dart format` (code formatted)
- [ ] Check file sizes
- [ ] Update version if needed

### Pre-release Checklist
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No analyzer warnings
- [ ] ProGuard rules tested
- [ ] Size optimizations applied
- [ ] Release notes updated

---

## Best Practices

### Code Style
1. Use `const` constructors where possible
2. Prefer `final` over `var`
3. Use single quotes for strings
4. Keep functions small (<50 lines)
5. Document public APIs
6. Use meaningful variable names

### Testing
1. Test happy paths
2. Test error cases
3. Test edge cases
4. Mock external dependencies
5. Keep tests fast (<1s each)

### Performance
1. Avoid unnecessary rebuilds
2. Use `const` widgets
3. Lazy load data
4. Cache expensive operations
5. Profile before optimizing

---

## Debugging

### Performance Profiling
```bash
# Run with performance overlay
flutter run --profile

# Record trace
flutter run --trace-startup --profile
```

### Memory Profiling
```bash
# Run with memory tracking
flutter run --track-widget-creation
```

### Build Analysis
```bash
# Analyze what's in your app bundle
flutter build appbundle --analyze-size --target-platform android-arm64
```

---

## Metrics

### Code Metrics
- **Total Lines**: ~5,000+
- **Files**: 50+
- **Test Files**: 3
- **Test Cases**: 40+
- **Coverage**: 80%+ (target)

### Build Metrics
- **Build Time**: ~30-45s (release)
- **APK Size**: ~10-15 MB (per ABI)
- **AAB Size**: ~42 MB (before optimization)
- **Install Size**: ~50-60 MB

---

## Tools & Commands

### Flutter Commands
```bash
flutter doctor          # Check Flutter setup
flutter devices         # List connected devices
flutter pub get         # Get dependencies
flutter pub upgrade     # Upgrade dependencies
flutter clean           # Clean build
flutter build           # Build release
```

### Dart Commands
```bash
dart analyze           # Analyze code
dart format           # Format code
dart fix              # Apply fixes
dart pub outdated     # Check outdated packages
```

### Useful Scripts
```bash
# Full rebuild
flutter clean && flutter pub get && flutter build appbundle --release

# Test with coverage
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# Analyze size
flutter build appbundle --release --analyze-size
```

---

## Resources

### Documentation
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Dart Testing](https://dart.dev/guides/testing)
- [Code Coverage](https://github.com/flutter/flutter/wiki/Test-coverage-for-package:flutter)
- [ProGuard](https://developer.android.com/studio/build/shrink-code)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [lcov](https://github.com/linux-test-project/lcov)

---

## Maintenance

### Weekly Tasks
- [ ] Run full test suite
- [ ] Check for package updates
- [ ] Review code coverage
- [ ] Monitor crash reports

### Monthly Tasks
- [ ] Dependency audit
- [ ] Performance profiling
- [ ] Size optimization review
- [ ] Security updates

---

**Last Updated**: November 9, 2025
**Version**: 1.0.0
**Maintained by**: Saleh Bagomri

