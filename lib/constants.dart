import 'package:flutter/material.dart';

class GameConstants {
  // Board dimensions
  static const int rows = 20;
  static const int cols = 10;

  // Scoring system
  static const Map<int, int> lineClearScores = {
    1: 100, // Single line
    2: 300, // Double line
    3: 500, // Triple line
    4: 800, // Tetris (4 lines)
  };

  // Game speed calculations (milliseconds per level)
  static const int baseDropTime = 800;
  static const int minDropTime = 50;
  static const int speedIncrement = 50;

  // UI constants - Responsive
  static const double minCellSize = 12.0;
  static const double maxCellSize = 24.0;
  static const double boardPadding = 2.0;
  static const double cellMargin = 0.5;
  static const double cellBorderWidth = 0.5;
  static const double cellBorderRadius = 2.0;
  
  // Control button sizing - Responsive
  static const double minButtonSize = 48.0;
  static const double maxButtonSize = 72.0;
  static const double buttonSpacing = 12.0;

  // Animation durations
  static const Duration pieceAnimationDuration = Duration(milliseconds: 100);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 150);
  static const Duration overlayAnimationDuration = Duration(milliseconds: 300);
  static const Duration lineClearAnimationDuration = Duration(milliseconds: 400);
  static const Duration gameOverAnimationDuration = Duration(milliseconds: 600);

  // Colors - Enhanced dark theme
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color boardBorderColor = Color(0xFF00BCD4); // Cyan
  static const Color cellEmptyColor = Color(0xFF1A1A1A);
  static const Color boardBackgroundColor = Color(0xFF121212);
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryYellow = Color(0xFFFFEB3B);
  static const Color primaryRed = Color(0xFFF44336);
  static const Color ghostPieceColor = Color(0x40FFFFFF);

  // SharedPreferences keys
  static const String highScoreKey = 'high_score';

  // Touch gesture thresholds
  static const double swipeThreshold = 200.0; // pixels per second
  static const double tapThreshold = 100.0; // milliseconds

  // Prevent button spam
  static const int buttonDebounceMs = 80;
  
  // Responsive breakpoints
  static const double smallScreenWidth = 360.0;
  static const double mediumScreenWidth = 400.0;
  static const double largeScreenWidth = 480.0;
  
  // Layout ratios
  static const double boardWidthRatio = 0.65;
  static const double sidebarWidthRatio = 0.15;
  static const double controlsHeightRatio = 0.25;
}
