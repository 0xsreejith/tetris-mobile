Readme · MD
Copy

# Tetris Mobile
 
Production-grade mobile Tetris built with Flutter using an incremental MVVM architecture.
 
## Screenshots
 
| Home Screen | Gameplay |
|:-----------:|:--------:|
| ![Home Screen](screenshots/image1.png) | ![Gameplay](screenshots/image2.png) |
 
## Project Description
 
Tetris Mobile is a portrait-first, responsive game focused on predictable gameplay, smooth rendering, and release readiness. The codebase is structured for maintainability with clear separation between domain logic, presentation state, and UI widgets.
 
## Features
 
- Classic Tetris gameplay with 7 tetrominoes (I, O, T, S, Z, J, L)
- Ghost piece projection
- Level progression with dynamic drop speed
- Line-clear animation and game-over animation
- Persistent high score (`shared_preferences`)
- Explicit new-high-score detection (no tie false positives)
- Touch controls + on-screen controls
- Responsive layout for small and medium mobile screens
- App lifecycle-aware pause behavior
- Production routing with centralized route definitions
 
## Tech Stack
 
- Flutter (Dart)
- State management: `ChangeNotifier` (MVVM layering)
- Persistence: `shared_preferences`
- Platform targets: Android, iOS, Web/Desktop scaffolding present
 
## Architecture
 
This project uses an incremental MVVM structure:
 
- **Domain** — deterministic game engine and rules
- **ViewModel** — orchestration, timer lifecycle, app lifecycle, UI flags
- **Presentation Widgets** — reusable stateless/stateful UI components
 
## Folder Structure
 
```text
lib/
├── core/
│   ├── constants/
│   │   └── game_constants.dart
│   └── routing/
│       └── app_router.dart
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   ├── game_logic.dart
│   │   │   ├── game_state.dart
│   │   │   ├── score_manager.dart
│   │   │   └── tetromino.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── game_board_screen.dart
│   │       ├── viewmodel/
│   │       │   └── game_view_model.dart
│   │       └── widgets/
│   │           ├── game_board_grid.dart
│   │           ├── game_controls.dart
│   │           ├── game_header.dart
│   │           ├── game_over_dialog.dart
│   │           ├── game_over_overlay.dart
│   │           ├── next_piece_preview.dart
│   │           ├── pause_overlay.dart
│   │           └── score_panel.dart
│   └── home/
│       └── presentation/
│           └── home_screen.dart
└── main.dart
```
 
## Routing
 
Centralized in `lib/core/routing/app_router.dart`.
 
| Route | Screen |
|-------|--------|
| `/` | Home screen |
| `/game` | Game screen |
 
## Prerequisites
 
- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode (for mobile builds)
- Java 17 for Android builds
 
## Installation
 
```bash
git clone git@github.com:0xsreejith/tetris-mobile.git
cd tetris-mobile
flutter pub get
```
 
## Run
 
```bash
flutter run
```
 
## Testing & Quality
 
```bash
flutter analyze
flutter test
```
 
## Android Release Signing
 
1. Create or use an upload keystore.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill in the following values:
   - `storeFile`
   - `storePassword`
   - `keyAlias`
   - `keyPassword`
4. Ensure secrets are never committed — `android/key.properties` and keystore files are gitignored.
 
Example local keystore generation:
 
```bash
mkdir -p keystore
keytool -genkeypair \
  -v \
  -storetype PKCS12 \
  -keystore keystore/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```
 
## Build
 
### Android APK
 
```bash
flutter build apk --release
```
 
### Android App Bundle (Play Store)
 
```bash
flutter build appbundle --release
```
 
### iOS
 
Open `ios/Runner.xcworkspace` in Xcode, configure Signing & Capabilities with your Apple Team, verify the bundle identifier (`com.oxsreejith.tetrismobile`), then run:
 
```bash
flutter build ios --release
```
 
## Production Notes
 
- Android package/namespace: `com.oxsreejith.tetrismobile`
- iOS bundle identifier: `com.oxsreejith.tetrismobile`
- Release build fails fast if signing config is missing
 
## License
 
MIT
 
