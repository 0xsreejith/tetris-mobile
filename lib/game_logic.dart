import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tetromino.dart';
import 'constants.dart';
import 'dart:math';

class GameLogic extends ChangeNotifier {
  static const int rows = GameConstants.rows;
  static const int cols = GameConstants.cols;

  List<List<Color?>> board = List.generate(
    rows,
    (i) => List.generate(cols, (j) => null),
  );

  Tetromino? currentPiece;
  Tetromino? nextPiece;
  Tetromino? ghostPiece;
  int score = 0;
  int level = 1;
  int lines = 0;
  int highScore = 0;
  bool gameOver = false;
  bool isPaused = false;
  bool isLineClearing = false;
  List<int> clearingLines = [];
  
  // Performance optimization
  DateTime? _lastMoveTime;
  DateTime? _lastRotateTime;

  final Random _random = Random();
  SharedPreferences? _prefs;

  GameLogic() {
    _loadHighScore();
    _initializeGame();
  }

  Future<void> _loadHighScore() async {
    _prefs = await SharedPreferences.getInstance();
    highScore = _prefs?.getInt(GameConstants.highScoreKey) ?? 0;
    notifyListeners();
  }

  Future<void> _saveHighScore() async {
    if (_prefs != null) {
      await _prefs!.setInt(GameConstants.highScoreKey, highScore);
    }
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
      gameOver = true;
      _updateHighScore();
      notifyListeners();
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
        if (piece.shape[row][col] == 1) {
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
    }
    return false;
  }

  bool movePieceLeft() {
    if (gameOver || isPaused || currentPiece == null || isLineClearing) return false;
    
    // Debounce rapid moves
    final now = DateTime.now();
    if (_lastMoveTime != null && 
        now.difference(_lastMoveTime!).inMilliseconds < GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastMoveTime = now;

    final newPiece = currentPiece!.copyWith(x: currentPiece!.x - 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool movePieceRight() {
    if (gameOver || isPaused || currentPiece == null || isLineClearing) return false;
    
    // Debounce rapid moves
    final now = DateTime.now();
    if (_lastMoveTime != null && 
        now.difference(_lastMoveTime!).inMilliseconds < GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastMoveTime = now;

    final newPiece = currentPiece!.copyWith(x: currentPiece!.x + 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool movePieceDown() {
    if (gameOver || isPaused || currentPiece == null || isLineClearing) return false;

    final newPiece = currentPiece!.copyWith(y: currentPiece!.y + 1);
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      notifyListeners();
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
    notifyListeners();
    return false;
  }

  bool rotatePiece() {
    if (gameOver || isPaused || currentPiece == null || isLineClearing) return false;
    
    // Debounce rapid rotations
    final now = DateTime.now();
    if (_lastRotateTime != null && 
        now.difference(_lastRotateTime!).inMilliseconds < GameConstants.buttonDebounceMs) {
      return false;
    }
    _lastRotateTime = now;

    // Try normal rotation first
    final newPiece = currentPiece!.rotate();
    if (!_checkCollision(newPiece)) {
      currentPiece = newPiece;
      _updateGhostPiece();
      notifyListeners();
      return true;
    }

    // Try wall kicks if normal rotation fails
    return _tryWallKicks();
  }

  bool _tryWallKicks() {
    if (currentPiece == null) return false;

    // Try different wall kick positions
    final kicks = [
      (dx: -1, dy: 0), // Left
      (dx: 1, dy: 0), // Right
      (dx: 0, dy: -1), // Up
      (dx: -2, dy: 0), // Double left
      (dx: 2, dy: 0), // Double right
      (dx: -1, dy: -1), // Left up
      (dx: 1, dy: -1), // Right up
    ];

    for (final kick in kicks) {
      final newPiece = currentPiece!.rotate();
      final kickedPiece = newPiece.copyWith(
        x: currentPiece!.x + kick.dx,
        y: currentPiece!.y + kick.dy,
      );
      if (!_checkCollision(kickedPiece)) {
        currentPiece = kickedPiece;
        _updateGhostPiece();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void _lockPiece() {
    if (currentPiece == null) return;

    for (int row = 0; row < currentPiece!.height; row++) {
      for (int col = 0; col < currentPiece!.width; col++) {
        if (currentPiece!.shape[row][col] == 1) {
          final boardX = currentPiece!.x + col;
          final boardY = currentPiece!.y + row;

          if (boardY >= 0 && boardY < rows && boardX >= 0 && boardX < cols) {
            board[boardY][boardX] = currentPiece!.color;
          }
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
    
    // After animation delay, actually clear the lines
    Future.delayed(GameConstants.lineClearAnimationDuration, () {
      _performLineClear();
      lines += linesCleared;
      _updateLevel();
      _calculateScore(linesCleared);
      _spawnNewPiece();
      _generateNextPiece();
      isLineClearing = false;
      clearingLines.clear();
      notifyListeners();
    });
  }

  void _performLineClear() {
    for (int row in clearingLines.reversed) {
      board.removeAt(row);
      board.insert(0, List.generate(cols, (j) => null));
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

  Future<void> _updateHighScore() async {
    if (score > highScore) {
      highScore = score;
      await _saveHighScore();
    }
  }

  void hardDrop() {
    if (gameOver || isPaused || currentPiece == null || isLineClearing) return;

    int dropDistance = 0;
    while (movePieceDown()) {
      dropDistance++;
    }
    score += dropDistance * 2;
    notifyListeners();
  }

  void reset() {
    board = List.generate(rows, (i) => List.generate(cols, (j) => null));
    score = 0;
    level = 1;
    lines = 0;
    gameOver = false;
    isPaused = false;
    isLineClearing = false;
    clearingLines.clear();
    currentPiece = null;
    nextPiece = null;
    ghostPiece = null;
    _lastMoveTime = null;
    _lastRotateTime = null;
    _initializeGame();
    notifyListeners();
  }

  void togglePause() {
    if (!gameOver) {
      isPaused = !isPaused;
      notifyListeners();
    }
  }

  Duration get dropDuration {
    final dropTime =
        GameConstants.baseDropTime - (level - 1) * GameConstants.speedIncrement;
    return Duration(milliseconds: max(GameConstants.minDropTime, dropTime));
  }
}
