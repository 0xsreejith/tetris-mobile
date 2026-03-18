import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import 'game_state.dart';
import 'score_manager.dart';
import 'tetromino.dart';

class GameLogic extends ChangeNotifier {
  static const int rows = GameConstants.rows;
  static const int cols = GameConstants.cols;

  List<List<Color?>> board = List.generate(
    rows,
    (_) => List.generate(cols, (_) => null),
  );

  Tetromino? currentPiece;
  Tetromino? nextPiece;
  Tetromino? ghostPiece;

  int score = 0;
  int level = 1;
  int lines = 0;
  int highScore = 0;

  bool isNewHighScore = false;
  int? finalScoreAtGameOver;

  GameState _gameState = GameState.idle;
  GameState get gameState => _gameState;

  bool isLineClearing = false;
  final List<int> clearingLines = [];

  DateTime? _lastMoveTime;
  DateTime? _lastRotateTime;

  bool _gameOverTriggered = false;
  final Random _random = Random();
  Timer? _lineClearTimer;
  bool _isDisposed = false;

  GameLogic() {
    _loadHighScore();
    _initializeGame();
  }

  bool get gameOver => _gameState == GameState.gameOver;
  bool get isPaused => _gameState == GameState.paused;

  void _setState(GameState newState) {
    if (_gameState == newState) return;

    if (kDebugMode) {
      debugPrint('GameState: ${_gameState.name} -> ${newState.name}');
    }
    _gameState = newState;
    _notifySafely();
  }

  void startGame() {
    if (_gameState != GameState.idle) {
      if (kDebugMode) {
        debugPrint('startGame() ignored in state: ${_gameState.name}');
      }
      return;
    }

    _resetGameData();
    _setState(GameState.playing);
    _initializeGame();
    _notifySafely();
  }

  void pauseGame() {
    if (_gameState != GameState.playing) return;
    _setState(GameState.paused);
  }

  void resumeGame() {
    if (_gameState != GameState.paused) return;
    _setState(GameState.playing);
  }

  void returnToIdle() {
    _resetGameData();
    _setState(GameState.idle);
  }

  void _triggerGameOver() {
    if (_gameOverTriggered || _gameState == GameState.gameOver) {
      if (kDebugMode) {
        debugPrint('Game over already triggered.');
      }
      return;
    }

    _gameOverTriggered = true;
    final finalScore = score;
    finalScoreAtGameOver = finalScore;
    isNewHighScore = false;
    _setState(GameState.gameOver);
    unawaited(_updateHighScore(finalScore));
  }

  void _resetGameData() {
    _lineClearTimer?.cancel();
    _lineClearTimer = null;

    board = List.generate(rows, (_) => List.generate(cols, (_) => null));
    score = 0;
    level = 1;
    lines = 0;
    isLineClearing = false;
    clearingLines.clear();
    currentPiece = null;
    nextPiece = null;
    ghostPiece = null;
    _lastMoveTime = null;
    _lastRotateTime = null;
    _gameOverTriggered = false;
    isNewHighScore = false;
    finalScoreAtGameOver = null;
  }

  Future<void> _loadHighScore() async {
    await ScoreManager.instance.initialize();
    if (_isDisposed) return;
    highScore = ScoreManager.instance.getHighScore();
    _notifySafely();
  }

  void _initializeGame() {
    _spawnNewPiece();
    _generateNextPiece();
    _updateGhostPiece();
  }

  void _spawnNewPiece() {
    if (nextPiece != null) {
      currentPiece = Tetromino.create(nextPiece!.type, cols ~/ 2 - 1, 0);
    } else {
      final randomType =
          TetrominoType.values[_random.nextInt(TetrominoType.values.length)];
      currentPiece = Tetromino.create(randomType, cols ~/ 2 - 1, 0);
    }

    if (_checkCollision(currentPiece!)) {
      _triggerGameOver();
      return;
    }

    _updateGhostPiece();
  }

  void _generateNextPiece() {
    final randomType =
        TetrominoType.values[_random.nextInt(TetrominoType.values.length)];
    nextPiece = Tetromino.create(randomType, 0, 0);
  }

  void _updateGhostPiece() {
    if (currentPiece == null) {
      ghostPiece = null;
      return;
    }

    ghostPiece = currentPiece!.copyWith();
    while (!_checkCollision(ghostPiece!.copyWith(y: ghostPiece!.y + 1))) {
      ghostPiece = ghostPiece!.copyWith(y: ghostPiece!.y + 1);
    }
  }

  bool _checkCollision(Tetromino piece) {
    for (int row = 0; row < piece.height; row++) {
      for (int col = 0; col < piece.width; col++) {
        if (piece.shape[row][col] != 1) continue;

        final boardX = piece.x + col;
        final boardY = piece.y + row;

        if (boardX < 0 || boardX >= cols || boardY >= rows) {
          return true;
        }

        if (boardY >= 0 && board[boardY][boardX] != null) {
          return true;
        }
      }
    }
    return false;
  }

  bool movePieceLeft() {
    if (!_gameState.acceptsInput || currentPiece == null || isLineClearing) {
      return false;
    }

    final now = DateTime.now();
    if (_lastMoveTime != null &&
        now.difference(_lastMoveTime!).inMilliseconds <
            GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastMoveTime = now;

    final newPiece = currentPiece!.copyWith(x: currentPiece!.x - 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      _notifySafely();
      return true;
    }
    return false;
  }

  bool movePieceRight() {
    if (!_gameState.acceptsInput || currentPiece == null || isLineClearing) {
      return false;
    }

    final now = DateTime.now();
    if (_lastMoveTime != null &&
        now.difference(_lastMoveTime!).inMilliseconds <
            GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastMoveTime = now;

    final newPiece = currentPiece!.copyWith(x: currentPiece!.x + 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      _notifySafely();
      return true;
    }
    return false;
  }

  bool movePieceDown() {
    if (!_gameState.acceptsInput || currentPiece == null || isLineClearing) {
      return false;
    }

    final newPiece = currentPiece!.copyWith(y: currentPiece!.y + 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      _notifySafely();
      return true;
    }

    _lockPiece();
    final linesCleared = _clearLines();
    if (linesCleared > 0) {
      _animateLineClear(linesCleared);
    } else {
      _spawnNewPiece();
      _generateNextPiece();
    }
    _notifySafely();
    return false;
  }

  bool rotatePiece() {
    if (!_gameState.acceptsInput || currentPiece == null || isLineClearing) {
      return false;
    }

    final now = DateTime.now();
    if (_lastRotateTime != null &&
        now.difference(_lastRotateTime!).inMilliseconds <
            GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastRotateTime = now;

    final newPiece = currentPiece!.rotate();
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      _notifySafely();
      return true;
    }

    return _tryWallKicks();
  }

  bool _tryWallKicks() {
    if (currentPiece == null) return false;

    final kicks = [
      (dx: -1, dy: 0),
      (dx: 1, dy: 0),
      (dx: 0, dy: -1),
      (dx: -2, dy: 0),
      (dx: 2, dy: 0),
      (dx: -1, dy: -1),
      (dx: 1, dy: -1),
    ];

    for (final kick in kicks) {
      final rotatedPiece = currentPiece!.rotate();
      final kickedPiece = rotatedPiece.copyWith(
        x: currentPiece!.x + kick.dx,
        y: currentPiece!.y + kick.dy,
      );
      if (!_checkCollision(kickedPiece)) {
        currentPiece = kickedPiece;
        _updateGhostPiece();
        _notifySafely();
        return true;
      }
    }
    return false;
  }

  void _lockPiece() {
    if (currentPiece == null) return;

    for (int row = 0; row < currentPiece!.height; row++) {
      for (int col = 0; col < currentPiece!.width; col++) {
        if (currentPiece!.shape[row][col] != 1) continue;

        final boardX = currentPiece!.x + col;
        final boardY = currentPiece!.y + row;

        if (boardY >= 0 && boardY < rows && boardX >= 0 && boardX < cols) {
          board[boardY][boardX] = currentPiece!.color;
        }
      }
    }
  }

  int _clearLines() {
    clearingLines.clear();

    for (int row = rows - 1; row >= 0; row--) {
      if (board[row].every((cell) => cell != null)) {
        clearingLines.add(row);
      }
    }

    return clearingLines.length;
  }

  void _animateLineClear(int linesCleared) {
    isLineClearing = true;
    _lineClearTimer?.cancel();

    _lineClearTimer = Timer(GameConstants.lineClearAnimationDuration, () {
      if (_isDisposed || _gameState != GameState.playing) {
        return;
      }

      _performLineClear();
      lines += linesCleared;
      _updateLevel();
      _calculateScore(linesCleared);
      _spawnNewPiece();
      _generateNextPiece();
      isLineClearing = false;
      clearingLines.clear();
      _notifySafely();
    });
  }

  void _performLineClear() {
    for (final row in clearingLines.reversed) {
      board.removeAt(row);
      board.insert(0, List.generate(cols, (_) => null));
    }
  }

  void _updateLevel() {
    final newLevel = (lines ~/ 10) + 1;
    if (newLevel > level) {
      level = newLevel;
    }
  }

  void _calculateScore(int linesCleared) {
    final points = (GameConstants.lineClearScores[linesCleared] ?? 0) * level;
    score += points;
  }

  Future<void> _updateHighScore(int finalScore) async {
    final updated = await ScoreManager.instance.updateHighScore(finalScore);
    if (_isDisposed) return;

    if (_gameState == GameState.gameOver &&
        finalScoreAtGameOver == finalScore) {
      isNewHighScore = updated;
    }
    if (updated) {
      highScore = finalScore;
    }

    _notifySafely();
  }

  void hardDrop() {
    if (!_gameState.acceptsInput || currentPiece == null || isLineClearing) {
      return;
    }

    var dropDistance = 0;
    var fallingPiece = currentPiece!;

    while (true) {
      final candidate = fallingPiece.copyWith(y: fallingPiece.y + 1);
      if (_checkCollision(candidate)) {
        break;
      }
      fallingPiece = candidate;
      dropDistance++;
    }

    currentPiece = fallingPiece;
    score += dropDistance * 2;

    _lockPiece();
    final linesCleared = _clearLines();
    if (linesCleared > 0) {
      _animateLineClear(linesCleared);
    } else {
      _spawnNewPiece();
      _generateNextPiece();
    }

    _notifySafely();
  }

  void reset() {
    _resetGameData();
    _setState(GameState.playing);
    _initializeGame();
    _notifySafely();
  }

  void togglePause() {
    if (_gameState == GameState.playing) {
      pauseGame();
    } else if (_gameState == GameState.paused) {
      resumeGame();
    }
  }

  Duration get dropDuration {
    final dropTime =
        GameConstants.baseDropTime - (level - 1) * GameConstants.speedIncrement;
    return Duration(milliseconds: max(GameConstants.minDropTime, dropTime));
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _lineClearTimer?.cancel();
    super.dispose();
  }
}
