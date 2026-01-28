import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/tetromino.dart';

void main() {
  group('Tetromino', () {
    test('create O piece', () {
      final t = Tetromino.create(TetrominoType.O, 0, 0);
      expect(t.type, TetrominoType.O);
      expect(t.shape, const [
        [1, 1],
        [1, 1],
      ]);
      expect(t.width, 2);
      expect(t.height, 2);
      expect(t.color, Colors.yellow);
    });

    test('rotation of I piece changes orientation', () {
      final iPiece = Tetromino.create(TetrominoType.I, 0, 0);
      expect(iPiece.width, 4);
      expect(iPiece.height, 1);

      final rotated = iPiece.rotate();
      expect(rotated.width, 1);
      expect(rotated.height, 4);

      // Rotating twice should give 4x1 again
      final rotatedTwice = rotated.rotate();
      expect(rotatedTwice.width, 4);
      expect(rotatedTwice.height, 1);
    });

    test('copyWith preserves type and color and overrides coordinates', () {
      final base = Tetromino.create(TetrominoType.T, 2, 3);
      final updated = base.copyWith(x: 5, y: 7);
      expect(updated.type, base.type);
      expect(updated.color, base.color);
      expect(updated.x, 5);
      expect(updated.y, 7);
      expect(updated.shape, base.shape);
    });
  });
}
