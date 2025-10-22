# PulseNote - AI Coding Agent Instructions

## Project Overview
PulseNote is a cross-platform Flutter health tracking application for monitoring pulse and blood pressure. The app uses Firebase (Firestore) for cloud data persistence and integrates with Apple Health and Google Health Connect. It supports Android, iOS, Web, Windows, macOS, and Linux platforms.

**Tech Stack**: Flutter 3.9.2+, Firebase (Firestore, Auth, Core), Provider, GetIt, Health, Material Design 3

## Architecture: MVVM with Dependency Injection

The app follows a Model-View-ViewModel (MVVM) architecture to promote separation of concerns, testability, and maintainability.

- **Model (`lib/models/`)**: Defines the data structures, like `HealthEntry`, and business logic. Includes `Result` class for handling operation states (loading, success, error).
- **View (`lib/views/`)**: Contains the UI components. The `HomePage` is the main screen, composed of widgets from `lib/views/widgets/` like `HealthEntryForm` and `HealthEntryCard`. Views are responsible for displaying data from the ViewModel and capturing user input.
- **ViewModel (`lib/viewmodels/`)**: `HealthViewModel` acts as the bridge between the View and the Model/Repositories. It holds the application's state, exposes data to the UI via `ChangeNotifier`, and handles user actions.
- **Repository (`lib/data/repositories/`)**: The repository pattern abstracts data sources. 
  - `FirestoreHealthRepository` manages data persistence with Firebase Firestore.
  - `DeviceHealthRepository` handles reading from and writing to the native health platforms (Apple Health/Google Health Connect) via the `health` package.
- **Dependency Injection (`lib/di/`)**: `get_it` is used to set up a service locator for injecting dependencies like repositories into the ViewModels. This is configured in `lib/di/service_locator.dart`.

### Data Flow
1. **UI Event**: A widget in the View (e.g., a button press in `HealthEntryForm`) calls a method on the `HealthViewModel`.
2. **ViewModel**: The ViewModel processes the request, interacts with one or more repositories (`FirestoreHealthRepository`, `DeviceHealthRepository`) to fetch or save data.
3. **Repository**: The repository communicates with the data source (Firestore or the native health service).
4. **State Update**: The ViewModel updates its state based on the result from the repository. Because it's a `ChangeNotifier`, it calls `notifyListeners()`.
5. **UI Update**: `Consumer` or `Provider.of` widgets in the View listen for changes and rebuild the UI to reflect the new state.

## Development Workflows

### Running the App
```powershell
# Ensure Firebase is configured (firebase_options.dart exists)
flutter run                    # Default device
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop
flutter run --release          # Production build
```

### Testing
- Default test in `test/widget_test.dart` is **outdated** (references non-existent counter).
- Run tests: `flutter test`
- **No integration or ViewModel/Repository tests configured yet.**

### Firebase & Health Integration
- **Firebase Project ID**: `pulsenoter`
- **Firebase Config**: Managed by FlutterFire CLI (`flutterfire configure`). Do not edit `lib/firebase_options.dart`.
- **Apple Health**: Requires `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` keys in `ios/Runner/Info.plist`.
- **Google Health Connect**: Requires `minSdk = 26` in `android/app/build.gradle.kts` and health permissions in `android/app/src/main/AndroidManifest.xml`.

### Dependencies
```powershell
flutter pub get              # Install dependencies
flutter pub upgrade          # Update packages
flutter pub outdated         # Check for updates
```

## Code Conventions

### State Management
- **Provider** with `ChangeNotifier` for state management.
- `HealthViewModel` is the central point for UI state.
- Use `Consumer<HealthViewModel>` to rebuild parts of the UI.
- Use `context.read<HealthViewModel>()` for one-off function calls in event handlers.

### Error Handling & Async
- `Result<T>` class is used to wrap outcomes of operations, capturing loading, success, and error states.
- The ViewModel exposes `Result` objects (e.g., `saveState`) that the UI can react to.
- All async operations use `async/await`. Loading states are managed via the `Result` state.

### Code Style
- **Material 3** (`useMaterial3: true`) with a teal seed color.
- Follows standard Flutter linting rules (`package:flutter_lints`).
- Widgets are broken down into smaller, reusable components in `lib/views/widgets/`.

## Known TODOs & Limitations

1. **"View Charts" button**: Shows placeholder SnackBar, `fl_chart` dependency unused.
2. **No authentication**: Firebase Auth imported but no sign-in flow.
3. **Widget test broken**: References counter app, not health tracker.
4. **Production signing**: Android uses debug keystore for release builds.
5. **Application IDs**: Still using `com.example.*` namespace.

## When Adding Features

### New Feature Workflow
1. **Model**: If new data is needed, update or create a model in `lib/models/`.
2. **Repository**: Add methods to the appropriate repository interface in `lib/data/repositories/` and implement them.
3. **ViewModel**: Add state properties and methods to `HealthViewModel` to handle the new feature's logic.
4. **View**: Create or update widgets in `lib/views/` to display the new state and call ViewModel methods.
5. **DI**: If adding a new repository or service, register it in `lib/di/service_locator.dart`.

### AI Agent Best Practices
- **Adhere to MVVM**: Do not put business logic in Views. All state changes and data operations must go through the `HealthViewModel`.
- **Use DI**: Fetch dependencies from `getIt` instead of instantiating them directly.
- **Immutable Models**: Models should be immutable. Use the `copyWith` method to create modified instances.
- **Check for Mounted**: When showing UI elements like SnackBars after an async operation, always check `if (context.mounted)`.
- **Platform Config**: Be aware that changes to health integration might require modifications to `Info.plist` (iOS) or `AndroidManifest.xml` (Android).
