import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

class ScorePanel extends StatelessWidget {
  const ScorePanel({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
    required this.highScore,
    required this.isSmallScreen,
  });

  final int score;
  final int level;
  final int lines;
  final int highScore;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final labelSize = isSmallScreen ? 10.0 : 12.0;
    final valueSize = isSmallScreen ? 12.0 : 16.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreItem(
          label: 'SCORE',
          value: score.toString(),
          color: Colors.white,
          labelSize: labelSize,
          valueSize: valueSize,
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        _ScoreItem(
          label: 'LEVEL',
          value: level.toString(),
          color: GameConstants.primaryCyan,
          labelSize: labelSize,
          valueSize: valueSize,
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        _ScoreItem(
          label: 'LINES',
          value: lines.toString(),
          color: GameConstants.primaryGreen,
          labelSize: labelSize,
          valueSize: valueSize,
        ),
        if (highScore > 0) ...[
          SizedBox(height: isSmallScreen ? 8 : 12),
          _ScoreItem(
            label: 'HIGH',
            value: highScore.toString(),
            color: GameConstants.primaryYellow,
            labelSize: labelSize,
            valueSize: valueSize,
          ),
        ],
      ],
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({
    required this.label,
    required this.value,
    required this.color,
    required this.labelSize,
    required this.valueSize,
  });

  final String label;
  final String value;
  final Color color;
  final double labelSize;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: labelSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
