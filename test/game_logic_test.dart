import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/constants.dart';
import 'package:tetris/game_logic.dart';
import 'package:tetris/tetromino.dart';

void main() {
  setUp(() async {
    // Ensure SharedPreferences works in tests
    SharedPreferences.setMockInitialValues({});
  });

  group('GameLogic - initialization', () {
    test('initial state', () async {
      final game = GameLogic();

      // Allow async high score load to complete
      await Future<void>.delayed(Duration.zero);

      expect(game.board.length, GameConstants.rows);
      expect(game.board.first.length, GameConstants.cols);

      expect(game.currentPiece, isNotNull);
      expect(game.nextPiece, isNotNull);
      expect(game.ghostPiece, isNotNull);

      expect(game.score, 0);
      expect(game.level, 1);
      expect(game.lines, 0);
      expect(game.gameOver, isFalse);
      expect(game.isPaused, isFalse);
      
      game.dispose();
    });
  });

  group('GameLogic - movement and collision', () {
    test('piece cannot move left past wall', () async {
      final game = GameLogic();
      await Future<void>.delayed(Duration.zero);

      // Place a 2-wide piece at the leftmost edge
      game.currentPiece = Tetromino.create(TetrominoType.O, 0, 0);

      final moved = game.movePieceLeft();
      expect(moved, isFalse);
      
      game.dispose();
    });

    test('piece cannot move right past wall', () async {
      final game = GameLogic();
      await Future<void>.delayed(Duration.zero);

      // Place a 2-wide piece at the rightmost edge
      final rightX = GameConstants.cols - 2; // O piece is 2-wide
      game.currentPiece = Tetromino.create(TetrominoType.O, rightX, 0);

      final moved = game.movePieceRight();
      expect(moved, isFalse);
      
      game.dispose();
    });

    test('piece moves down until lock', () async {
      final game = GameLogic();
      await Future<void>.delayed(Duration.zero);

      // Use a simple I piece
      final piece = Tetromino.create(TetrominoType.I, GameConstants.cols ~/ 2, 0);
      game.currentPiece = piece;

      var moved = true;
      var steps = 0;
      while (moved && steps < GameConstants.rows + 5) {
        moved = game.movePieceDown();
        steps++;
      }

      // After moving down until it locks, there should be a colored cell on the board
      final hasCell = game.board.any((row) => row.any((c) => c != null));
      expect(hasCell, isTrue);
      
      game.dispose();
    });
  });

  group('GameLogic - rotation', () {
    test('rotate succeeds in open space', () async {
      final game = GameLogic();
      await Future<void>.delayed(Duration.zero);

      // Use T piece in the middle area
      final startX = GameConstants.cols ~/ 2 - 1;
      game.currentPiece = Tetromino.create(TetrominoType.T, startX, 1);

      final rotated = game.rotatePiece();
      expect(rotated, isTrue);
      expect(game.currentPiece, isNotNull);
      
      game.dispose();
    });
  });

  group('GameLogic - hard drop', () {
    test('hard drop increases score based on drop distance', () async {
      final game = GameLogic();
      await Future<void>.delayed(Duration.zero);

      // Use I piece to drop from top
      game.currentPiece = Tetromino.create(TetrominoType.I, GameConstants.cols ~/ 2, 0);

      game.hardDrop();

      // Score should be > 0 since we gained 2 points per cell dropped
      expect(game.score, greaterThan(0));

      // There should be at least one filled cell in the bottom area
      final hasCell = game.board.any((row) => row.any((c) => c != null));
      expect(hasCell, isTrue);
      
      game.dispose();
    });
  });
}
