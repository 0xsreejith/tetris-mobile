import 'package:flutter/material.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  final TetrominoType type;
  final int x;
  final int y;
  final List<List<int>> shape;
  final Color color;

  Tetromino({
    required this.type,
    required this.x,
    required this.y,
    required this.shape,
    required this.color,
  });

  static Tetromino create(TetrominoType type, int x, int y) {
    switch (type) {
      case TetrominoType.I:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [1, 1, 1, 1],
          ],
          color: Colors.cyan,
        );
      case TetrominoType.O:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [1, 1],
            [1, 1],
          ],
          color: Colors.yellow,
        );
      case TetrominoType.T:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [0, 1, 0],
            [1, 1, 1],
          ],
          color: Colors.purple,
        );
      case TetrominoType.S:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [0, 1, 1],
            [1, 1, 0],
          ],
          color: Colors.green,
        );
      case TetrominoType.Z:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [1, 1, 0],
            [0, 1, 1],
          ],
          color: Colors.red,
        );
      case TetrominoType.J:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [1, 0, 0],
            [1, 1, 1],
          ],
          color: Colors.blue,
        );
      case TetrominoType.L:
        return Tetromino(
          type: type,
          x: x,
          y: y,
          shape: [
            [0, 0, 1],
            [1, 1, 1],
          ],
          color: Colors.orange,
        );
    }
  }

  Tetromino copyWith({int? x, int? y, List<List<int>>? shape}) {
    return Tetromino(
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      shape: shape ?? this.shape,
      color: color,
    );
  }

  Tetromino rotate() {
    List<List<int>> rotated = List.generate(
      shape[0].length,
      (i) => List.generate(shape.length, (j) => shape[shape.length - 1 - j][i]),
    );
    return copyWith(shape: rotated);
  }

  int get width => shape[0].length;
  int get height => shape.length;
}
