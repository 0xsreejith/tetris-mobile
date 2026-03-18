import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.animation,
    required this.score,
    required this.isNewHighScore,
  });

  final Animation<double> animation;
  final int score;
  final bool isNewHighScore;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          color: GameConstants.backgroundColor.withValues(
            alpha: 0.95 * animation.value,
          ),
          child: Center(
            child: Transform.scale(
              scale: animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: GameConstants.primaryRed,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'NEW HIGH SCORE!',
                      style: TextStyle(
                        color: GameConstants.primaryYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
