import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/game_logic.dart';
import '../../domain/game_state.dart';
import '../../domain/tetromino.dart';

/// Presentation-layer orchestrator for the game screen.
class GameViewModel extends ChangeNotifier {
  GameViewModel({GameLogic? gameLogic})
    : _gameLogic = gameLogic ?? GameLogic() {
    _gameLogic.addListener(_onGameLogicChanged);
    _lastObservedState = _gameLogic.gameState;
  }

  final GameLogic _gameLogic;
  Timer? _gameTimer;
  Duration? _scheduledDropDuration;

  GameState _lastObservedState = GameState.idle;
  bool _gameOverDialogShown = false;
  bool _isDisposed = false;

  List<List<Color?>> get board => _gameLogic.board;
  Tetromino? get currentPiece => _gameLogic.currentPiece;
  Tetromino? get nextPiece => _gameLogic.nextPiece;
  Tetromino? get ghostPiece => _gameLogic.ghostPiece;

  int get score => _gameLogic.score;
  int get level => _gameLogic.level;
  int get lines => _gameLogic.lines;
  int get highScore => _gameLogic.highScore;

  bool get isLineClearing => _gameLogic.isLineClearing;
  List<int> get clearingLines => _gameLogic.clearingLines;
  GameState get gameState => _gameLogic.gameState;

  bool get isPaused => _gameLogic.isPaused;
  bool get gameOver => _gameLogic.gameOver;
  bool get isNewHighScore => _gameLogic.isNewHighScore;
  int? get finalScoreAtGameOver => _gameLogic.finalScoreAtGameOver;

  bool get shouldShowGameOverDialog => gameOver && !_gameOverDialogShown;

  void start() {
    if (_gameLogic.gameState == GameState.idle) {
      _gameLogic.startGame();
    } else {
      _startGameTimer();
      _notifySafely();
    }
  }

  void reset() {
    _gameOverDialogShown = false;
    _gameLogic.reset();
  }

  void returnToIdle() {
    _gameOverDialogShown = false;
    _gameLogic.returnToIdle();
  }

  void togglePause() => _gameLogic.togglePause();
  bool movePieceLeft() => _gameLogic.movePieceLeft();
  bool movePieceRight() => _gameLogic.movePieceRight();
  bool movePieceDown() => _gameLogic.movePieceDown();
  bool rotatePiece() => _gameLogic.rotatePiece();
  void hardDrop() => _gameLogic.hardDrop();

  void markGameOverDialogShown() {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;
    _notifySafely();
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (_gameLogic.gameState == GameState.playing) {
          _gameLogic.pauseGame();
        }
        break;
      case AppLifecycleState.detached:
        _stopGameTimer();
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onGameLogicChanged() {
    final state = _gameLogic.gameState;

    if (state != _lastObservedState) {
      if (state == GameState.playing) {
        _gameOverDialogShown = false;
        _startGameTimer(forceRestart: true);
      } else {
        _stopGameTimer();
      }
      _lastObservedState = state;
    } else if (state == GameState.playing && _gameTimer == null) {
      _startGameTimer();
    }

    _notifySafely();
  }

  void _startGameTimer({bool forceRestart = false}) {
    if (!_gameLogic.gameState.shouldRunTimer) return;
    if (_gameTimer != null && !forceRestart) return;

    _stopGameTimer();

    final scheduledDuration = _gameLogic.dropDuration;
    _scheduledDropDuration = scheduledDuration;

    _gameTimer = Timer.periodic(scheduledDuration, (_) {
      if (!_gameLogic.gameState.shouldRunTimer || _gameLogic.isLineClearing) {
        return;
      }

      _gameLogic.movePieceDown();

      if (_gameLogic.dropDuration != _scheduledDropDuration) {
        _startGameTimer(forceRestart: true);
      }
    });
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
    _scheduledDropDuration = null;
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopGameTimer();
    _gameLogic.removeListener(_onGameLogicChanged);
    _gameLogic.dispose();
    super.dispose();
  }
}
