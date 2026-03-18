import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameConstants.backgroundColor.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: GameConstants.primaryCyan,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'RESUME',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
