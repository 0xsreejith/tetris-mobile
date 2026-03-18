import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/game_constants.dart';
import 'core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only (mobile-first)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for better mobile experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris Mobile',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: GameConstants.backgroundColor,
          elevation: 0,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            animationDuration: GameConstants.buttonAnimationDuration,
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: GameConstants.boardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: GameConstants.primaryCyan,
          secondary: GameConstants.primaryPurple,
          surface: GameConstants.boardBackgroundColor,
        ),
      ),
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
