import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.isSmallScreen,
    required this.onBack,
    required this.onReset,
  });

  final bool isSmallScreen;
  final VoidCallback onBack;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSmallScreen ? 50 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameConstants.backgroundColor,
            GameConstants.boardBackgroundColor,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: isSmallScreen ? 20 : 24,
            onPressed: onBack,
          ),
          Text(
            'TETRIS',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: GameConstants.primaryCyan.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            iconSize: isSmallScreen ? 20 : 24,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
