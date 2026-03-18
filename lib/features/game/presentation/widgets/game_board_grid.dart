import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/game_constants.dart';
import '../../domain/tetromino.dart';

class GameBoardGrid extends StatelessWidget {
  const GameBoardGrid({
    super.key,
    required this.board,
    required this.currentPiece,
    required this.ghostPiece,
    required this.rows,
    required this.cols,
    required this.acceptsInput,
    required this.clearingLines,
    required this.lineClearAnimation,
    required this.onRotate,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onSoftDrop,
  });

  final List<List<Color?>> board;
  final Tetromino? currentPiece;
  final Tetromino? ghostPiece;
  final int rows;
  final int cols;
  final bool acceptsInput;
  final List<int> clearingLines;
  final Animation<double> lineClearAnimation;
  final VoidCallback onRotate;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onSoftDrop;

  @override
  Widget build(BuildContext context) {
    final clearingRows = clearingLines.toSet();

    return GestureDetector(
      onTap: () {
        if (!acceptsInput) return;
        HapticFeedback.lightImpact();
        onRotate();
      },
      onPanEnd: (details) {
        if (!acceptsInput) return;

        final velocity = details.velocity.pixelsPerSecond;
        final threshold = GameConstants.swipeThreshold;

        if (velocity.dx.abs() > velocity.dy.abs()) {
          if (velocity.dx > threshold) {
            HapticFeedback.selectionClick();
            onMoveRight();
          } else if (velocity.dx < -threshold) {
            HapticFeedback.selectionClick();
            onMoveLeft();
          }
        } else if (velocity.dy > threshold) {
          HapticFeedback.lightImpact();
          onSoftDrop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: GameConstants.boardBorderColor, width: 2),
          color: GameConstants.boardBackgroundColor,
          borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
          boxShadow: [
            BoxShadow(
              color: GameConstants.primaryCyan.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ cols;
            final col = index % cols;
            return _Cell(
              row: row,
              col: col,
              cellColor: board[row][col],
              currentPiece: currentPiece,
              ghostPiece: ghostPiece,
              isClearingLine: clearingRows.contains(row),
              lineClearAnimation: lineClearAnimation,
            );
          },
          itemCount: rows * cols,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.row,
    required this.col,
    required this.cellColor,
    required this.currentPiece,
    required this.ghostPiece,
    required this.isClearingLine,
    required this.lineClearAnimation,
  });

  final int row;
  final int col;
  final Color? cellColor;
  final Tetromino? currentPiece;
  final Tetromino? ghostPiece;
  final bool isClearingLine;
  final Animation<double> lineClearAnimation;

  @override
  Widget build(BuildContext context) {
    var resolvedColor = cellColor;
    var isGhostCell = false;

    if (currentPiece != null) {
      final pieceRow = row - currentPiece!.y;
      final pieceCol = col - currentPiece!.x;
      if (pieceRow >= 0 &&
          pieceRow < currentPiece!.height &&
          pieceCol >= 0 &&
          pieceCol < currentPiece!.width &&
          currentPiece!.shape[pieceRow][pieceCol] == 1) {
        resolvedColor = currentPiece!.color;
      }
    }

    if (resolvedColor == null && ghostPiece != null) {
      final ghostRow = row - ghostPiece!.y;
      final ghostCol = col - ghostPiece!.x;
      if (ghostRow >= 0 &&
          ghostRow < ghostPiece!.height &&
          ghostCol >= 0 &&
          ghostCol < ghostPiece!.width &&
          ghostPiece!.shape[ghostRow][ghostCol] == 1) {
        resolvedColor = GameConstants.ghostPieceColor;
        isGhostCell = true;
      }
    }

    return AnimatedBuilder(
      animation: lineClearAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: GameConstants.pieceAnimationDuration,
          margin: const EdgeInsets.all(GameConstants.cellMargin),
          decoration: BoxDecoration(
            color: isClearingLine
                ? (resolvedColor ?? GameConstants.cellEmptyColor).withValues(
                    alpha: lineClearAnimation.value,
                  )
                : (resolvedColor ?? GameConstants.cellEmptyColor),
            border: Border.all(
              color: isGhostCell
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.3),
              width: GameConstants.cellBorderWidth,
            ),
            borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
            boxShadow: resolvedColor != null && !isGhostCell
                ? [
                    BoxShadow(
                      color: resolvedColor.withValues(alpha: 0.3),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
