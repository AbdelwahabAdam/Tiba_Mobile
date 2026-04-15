# 🚀 Action Plan - Quick Fix Priority

## Phase 1: CRITICAL (This Week) 🔴
**Do NOT merge code to production without fixing these**

### Week 1 Plan (Estimated 20-25 hours)

#### Task 1.1: Fix API Configuration (2 hours)
```dart
// lib/core/config/api_config.dart (CREATE NEW FILE)
class ApiConfig {
  static const String env = String.fromEnvironment(
    'DART_DEFINE_ENV',
    defaultValue: 'dev',
  );

  static String get baseUrl {
    switch (env) {
      case 'prod':
        return 'https://api.tiba.com';  // Production
      case 'staging':
        return 'https://staging-api.tiba.com';
      case 'dev':
      default:
        return 'http://192.168.1.8:6543';
    }
  }

  static const int connectTimeout = 10;
  static const int receiveTimeout = 10;
}

// Update lib/core/services/api_service.dart
class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
    ),
  )..interceptors.add(AuthInterceptor());

  // Same for authDio
}

// Build command:
// flutter build apk --dart-define=DART_DEFINE_ENV=prod
```

#### Task 1.2: Add Input Validation (3 hours)
```dart
// lib/core/validators/input_validator.dart (CREATE NEW FILE)
class InputValidator {
  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateCategoryName(String value) {
    if (value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name too short';
    if (value.length > 100) return 'Name too long';
    return null;
  }

  static String sanitizeSearch(String value) {
    // Remove dangerous characters for SQL injection
    return value
        .replaceAll(RegExp(r'[<>\"\'%;()&+]'), '')
        .trim()
        .substring(0, 100); // Max 100 chars
  }
}
```

#### Task 1.3: Add Logger Package + Remove Prints (2 hours)

```yaml
# pubspec.yaml
dependencies:
  logger: ^2.1.0
```

```dart
// lib/core/utils/logger.dart (CREATE NEW FILE)
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

// Or use simpler version:
final logger = Logger();

// Then replace ALL print() calls:
// OLD: print("try to refresh!!");
// NEW: logger.d("Attempting token refresh");

// OLD: print('USER JSON => $json');
// NEW: logger.d('UserModel created from JSON');
```

**Files to update**:
- lib/core/services/auth_service.dart
- lib/controllers/base_crud_controller.dart
- lib/controllers/category_controller.dart
- lib/models/user_model.dart

#### Task 1.4: Fix ProductModel Typo (30 min)

```dart
// lib/models/product_model.dart - CHANGE THIS:
// FROM:
manufacturerName: json['manfacturer_name'] ?? '',  // ❌ TYPO
arabicManufacturerName: json['arabic_manfacturer_name'] ?? '',  // ❌ TYPO

// TO:
manufacturerName: json['manufacturer_name'] ?? '',  // ✅ CORRECT
arabicManufacturerName: json['arabic_manufacturer_name'] ?? '',  // ✅ CORRECT
```

#### Task 1.5: Fix Auth Controller Error Handling (3 hours)

Before/After code provided in CODE_REVIEW.md issue #4

#### Task 1.6: Fix Missing Product Method (1 hour)

Add to lib/controllers/product_controller.dart:

```dart
Future<void> loadAllForLookup() async {
  try {
    final res = await ApiService.dio.get(
      endpoint,
      queryParameters: {'limit': 10000},
    );
    
    productById.clear();
    for (var item in res.data['items'] as List) {
      final product = fromJson(item);
      productById[product.id] = product;
    }
    
    logger.d('Loaded ${productById.length} products for lookup');
  } catch (e) {
    logger.e('Error loading products: $e');
  }
}
```

#### Task 1.7: Fix Image Upload Validation (2 hours)

Full code in CODE_REVIEW.md issue #13

#### Task 1.8: Add Global Error Handler (2 hours)

```dart
// lib/core/services/error_handler.dart (CREATE NEW FILE)
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e('Flutter Error', error: details.exception, stackTrace: details.stack);
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e('Platform Error', error: error, stackTrace: stack);
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };
  }

  static void handle(Object error, StackTrace stackTrace) {
    logger.e('Unhandled Error', error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    Get.snackbar(
      'Error',
      'Something went wrong',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// In main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handler FIRST
  ErrorHandler.initialize();
  
  // ... rest of initialization
}
```

---

## Phase 2: HIGH PRIORITY (Week 2) 🟠
**Estimated 15-20 hours**

- Fix auth interceptor with queue (Issue #2)
- Fix token race condition with locks (Issue #7)
- Fix BaseCrudController pagination (Issue #8)
- Fix AuthGateController timeout (Issue #9)
- Add proper login form validation + loading states (Issue #10)
- Add delete confirmation dialogs (Issue #22)

---

## Phase 3: MEDIUM PRIORITY (Week 3-4) 🟡
**Estimated 10-15 hours**

- Add logging interceptor
- Improve FCM error handling
- Better datetime parsing in models
- Add more null safety
- Extract constants

---

## Testing Checklist After Phase 1

- [ ] Login with valid credentials
- [ ] Login with invalid credentials → error shown
- [ ] Login with empty email/password → validation error
- [ ] Try login, then quickly switch networks → no infinite loop
- [ ] Token refresh works when token expires
- [ ] Can scroll product list to end without errors
- [ ] Image upload shows proper errors
- [ ] No more print() statements in console
- [ ] No hardcoded URLs for production build

---

## Deployment Checklist

Before going to production, ensure:

- [ ] All 🔴 CRITICAL issues fixed
- [ ] All 🟠 HIGH issues fixed
- [ ] Error tracking enabled (Firebase Crashlytics)
- [ ] Minimum 70% test coverage
- [ ] API uses HTTPS
- [ ] Secrets in environment variables, not code
- [ ] No debug print statements
- [ ] Crash reporting verified
- [ ] Performance monitoring active

---

## Estimated Total Timeline

| Phase | Priority | Time | Deadline |
|-------|----------|------|----------|
| 1 | CRITICAL | 20-25h | This week |
| 2 | HIGH | 15-20h | Next week |
| 3 | MEDIUM | 10-15h | Following week |
| 4 | Testing | 10h | QA |
| **TOTAL** | | **55-70h** | **~4 weeks** |

---

## Files to Create

1. ✅ `lib/core/config/api_config.dart`
2. ✅ `lib/core/validators/input_validator.dart`
3. ✅ `lib/core/utils/logger.dart`
4. ✅ `lib/core/services/error_handler.dart`

## Files to Modify (Phase 1)

1. `lib/core/services/api_service.dart`
2. `lib/controllers/auth_controller.dart`
3. `lib/models/product_model.dart`
4. `lib/core/services/upload_service.dart`
5. `lib/controllers/product_controller.dart`
6. `lib/core/services/auth_service.dart`
7. `lib/controllers/base_crud_controller.dart`
8. `lib/main.dart`
9. `pubspec.yaml`

---

## Quick Start Commands

```bash
# 1. Add logger
flutter pub add logger
flutter pub add firebase_crashlytics

# 2. Create new files (see above)

# 3. Run analysis
flutter analyze

# 4. Format code
dart format lib/

# 5. Test
flutter test

# 6. Build for testing
flutter build apk --dart-define=DART_DEFINE_ENV=staging

# 7. Build for production (after fixes)
flutter build apk --dart-define=DART_DEFINE_ENV=prod --release
```

---

Good luck! 🚀
