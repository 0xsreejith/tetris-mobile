import 'package:flutter/material.dart';

import '../../features/game/presentation/screens/game_board_screen.dart';
import '../../features/home/presentation/home_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String game = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case game:
        return MaterialPageRoute<void>(
          builder: (_) => const GameBoard(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: const RouteSettings(name: home),
        );
    }
  }
}
