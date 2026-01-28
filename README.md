# 🎮 Tetris Mobile

A modern, mobile-first Tetris game built with Flutter. Featuring responsive design, smooth animations, and intuitive touch controls optimized for mobile devices.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

## ✨ Features

### 🎯 Core Gameplay
- **Classic Tetris mechanics** with modern enhancements
- **7 different Tetromino pieces** (I, O, T, S, Z, J, L)
- **Line clearing** with smooth animations
- **Level progression** with increasing speed
- **Scoring system** with bonus points for Tetris (4-line clears)
- **Ghost piece preview** showing where pieces will land
- **Enhanced wall kick system** for better piece rotation

### 📱 Mobile-First Design
- **Fully responsive** for all mobile screen sizes
- **Portrait-only orientation** optimized for mobile gameplay
- **Adaptive layouts** using MediaQuery and LayoutBuilder
- **Safe area handling** for devices with notches
- **No overflow or UI stretching** on any device

### 🎮 Touch Controls
- **Intuitive gesture controls**:
  - Tap board → Rotate piece
  - Swipe left/right → Move piece horizontally
  - Swipe down → Soft drop
- **On-screen buttons** with visual feedback:
  - ROTATE (Purple) → Rotate piece
  - DROP (Orange) → Hard drop
  - PAUSE (Cyan) → Pause/Resume game
  - LEFT/RIGHT (Blue) → Move piece
  - DOWN (Green) → Soft drop
- **Haptic feedback** for enhanced mobile experience
- **Button debouncing** to prevent spam tapping

### 🎨 Visual Polish
- **Clean dark theme** with vibrant accent colors
- **Smooth animations**:
  - Line clearing with fade effects
  - Game over with scale animation
  - Button press feedback
  - Piece movement transitions
- **Glowing effects** and shadows for visual appeal
- **Responsive typography** that scales with screen size

### 🚀 Performance
- **Optimized rendering** with efficient widget rebuilds
- **Memory management** with proper resource disposal
- **Stable 60 FPS** on low-end devices
- **Minimal battery usage** with optimized game loop



## 🛠️ Installation

### Prerequisites
- Flutter SDK (>=3.10.4)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/0xsreejith/tetris-mobile.git
   cd tetris-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎮 How to Play

### Controls
| Action | Gesture | Button |
|--------|---------|--------|
| Rotate piece | Tap board | ROTATE |
| Move left | Swipe left | LEFT |
| Move right | Swipe right | RIGHT |
| Soft drop | Swipe down | DOWN |
| Hard drop | - | DROP |
| Pause/Resume | - | PAUSE |

### Scoring
- **Single line**: 100 × level
- **Double line**: 300 × level  
- **Triple line**: 500 × level
- **Tetris (4 lines)**: 800 × level
- **Hard drop bonus**: +2 points per cell

### Gameplay
- Clear horizontal lines by filling them completely
- Game speed increases every 10 lines cleared
- Game ends when pieces reach the top
- Beat your high score!

## 🏗️ Project Structure

```
lib/
├── main.dart           # App entry point and configuration
├── constants.dart      # Game constants and responsive values
├── home_screen.dart    # Main menu with animations
├── board.dart          # Game board and responsive layout
├── game_logic.dart     # Core game mechanics and state
├── controls.dart       # Touch controls and buttons
└── tetromino.dart      # Tetromino piece definitions
```

## 🎯 Technical Highlights

### Responsive Design
- **Breakpoint-based layouts** for different screen sizes
- **Dynamic sizing** using screen ratios instead of fixed pixels
- **Flexible widgets** (Expanded, Flexible) for adaptive layouts
- **MediaQuery integration** for screen-aware components

### State Management
- **ChangeNotifier pattern** for game state
- **Efficient rebuilds** with targeted widget updates
- **Memory leak prevention** with proper disposal
- **App lifecycle handling** for pause/resume

### Performance Optimizations
- **Timer management** with automatic restart on level changes
- **Animation controllers** with proper disposal
- **Debounced input handling** to prevent spam
- **Optimized collision detection**

### Mobile UX
- **Haptic feedback** for tactile responses
- **Visual button states** with press animations
- **System UI integration** (status bar, navigation bar)
- **Orientation locking** to portrait mode

## 🔧 Development

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### Testing
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## 📦 Dependencies

- **flutter**: SDK
- **shared_preferences**: ^2.2.2 - High score persistence
- **cupertino_icons**: ^1.0.8 - iOS-style icons

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Classic Tetris game mechanics by Alexey Pajitnov
- Flutter team for the amazing framework
- Material Design for UI inspiration

## 📞 Support

If you encounter any issues or have questions:
- Open an [issue](https://github.com/0xsreejith/tetris-mobile/issues)
- Check the [Flutter documentation](https://docs.flutter.dev/)

---

**Made with ❤️ and Flutter**
