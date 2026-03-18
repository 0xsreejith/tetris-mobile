import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';
import '../../domain/tetromino.dart';

class NextPiecePreview extends StatelessWidget {
  const NextPiecePreview({
    super.key,
    required this.nextPiece,
    required this.isSmallScreen,
  });

  final Tetromino? nextPiece;
  final bool isSmallScreen;

  static const int _previewGridSize = 4;

  @override
  Widget build(BuildContext context) {
    final previewSize = isSmallScreen ? 48.0 : 64.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'NEXT',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Container(
          width: previewSize,
          height: previewSize,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: GameConstants.primaryCyan, width: 1),
            color: GameConstants.boardBackgroundColor,
            borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
          ),
          child: nextPiece == null
              ? const SizedBox.shrink()
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _previewGridSize,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ _previewGridSize;
                    final col = index % _previewGridSize;

                    final hasCell =
                        row < nextPiece!.height &&
                        col < nextPiece!.width &&
                        nextPiece!.shape[row][col] == 1;

                    return Container(
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: hasCell
                            ? nextPiece!.color
                            : GameConstants.cellEmptyColor,
                        borderRadius: BorderRadius.circular(1),
                        border: hasCell
                            ? Border.all(
                                color: Colors.black.withValues(alpha: 0.3),
                                width: 0.5,
                              )
                            : null,
                      ),
                    );
                  },
                  itemCount: _previewGridSize * _previewGridSize,
                ),
        ),
      ],
    );
  }
}
