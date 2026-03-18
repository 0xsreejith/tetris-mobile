import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';
import '../../domain/game_logic.dart';
import '../../domain/game_state.dart';
import '../viewmodel/game_view_model.dart';
import '../widgets/game_board_grid.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_header.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/next_piece_preview.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/score_panel.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final GameViewModel _viewModel;

  late final AnimationController _lineClearController;
  late final AnimationController _gameOverController;
  late final Animation<double> _lineClearAnimation;
  late final Animation<double> _gameOverAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _lineClearController = AnimationController(
      duration: GameConstants.lineClearAnimationDuration,
      vsync: this,
    );
    _gameOverController = AnimationController(
      duration: GameConstants.gameOverAnimationDuration,
      vsync: this,
    );
    _lineClearAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _lineClearController, curve: Curves.easeInOut),
    );
    _gameOverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut),
    );

    _viewModel = GameViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _viewModel.handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _lineClearController.dispose();
    _gameOverController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (_viewModel.isLineClearing && !_lineClearController.isAnimating) {
      _lineClearController.forward().then((_) {
        if (mounted) {
          _lineClearController.reset();
        }
      });
    }

    if (_viewModel.gameState == GameState.playing) {
      _gameOverController.reset();
    }

    if (_viewModel.gameOver) {
      _triggerGameOverFlow();
    }
  }

  void _triggerGameOverFlow() {
    if (!_gameOverController.isAnimating && !_gameOverController.isCompleted) {
      _gameOverController.forward();
    }

    if (_viewModel.shouldShowGameOverDialog) {
      _viewModel.markGameOverDialogShown();
      Future.delayed(GameConstants.gameOverAnimationDuration, () {
        if (!mounted || !_viewModel.gameOver) return;
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        score: _viewModel.finalScoreAtGameOver ?? _viewModel.score,
        highScore: _viewModel.highScore,
        isNewHighScore: _viewModel.isNewHighScore,
        onRetry: () {
          Navigator.of(context).pop();
          _gameOverController.reset();
          _viewModel.reset();
        },
        onHome: () {
          Navigator.of(context).pop();
          _viewModel.returnToIdle();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final isSmallScreen =
                    screenWidth < GameConstants.smallScreenWidth;

                final headerHeight = isSmallScreen ? 50.0 : 60.0;
                final controlsHeight =
                    (screenHeight * GameConstants.controlsHeightRatio).clamp(
                      140.0,
                      220.0,
                    );

                final availableMainHeight = max(
                  0.0,
                  screenHeight - headerHeight - controlsHeight,
                );
                final sidebarWidth = isSmallScreen
                    ? max(44.0, screenWidth * 0.12)
                    : screenWidth * GameConstants.sidebarWidthRatio;
                final boardAreaWidth = max(
                  0.0,
                  screenWidth - (sidebarWidth * 2),
                );

                final cellByWidth = boardAreaWidth / GameLogic.cols;
                final cellByHeight = availableMainHeight / GameLogic.rows;
                final cellSize = min(
                  cellByWidth,
                  cellByHeight,
                ).clamp(GameConstants.minCellSize, GameConstants.maxCellSize);

                final boardWidth = cellSize * GameLogic.cols;
                final boardHeight = cellSize * GameLogic.rows;

                return Stack(
                  children: [
                    Column(
                      children: [
                        GameHeader(
                          isSmallScreen: isSmallScreen,
                          onBack: () {
                            _viewModel.returnToIdle();
                            Navigator.pop(context);
                          },
                          onReset: _viewModel.reset,
                        ),
                        SizedBox(
                          height: availableMainHeight,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: sidebarWidth,
                                  child: ScorePanel(
                                    score: _viewModel.score,
                                    level: _viewModel.level,
                                    lines: _viewModel.lines,
                                    highScore: _viewModel.highScore,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ),
                                SizedBox(
                                  width: boardWidth,
                                  height: boardHeight,
                                  child: GameBoardGrid(
                                    board: _viewModel.board,
                                    currentPiece: _viewModel.currentPiece,
                                    ghostPiece: _viewModel.ghostPiece,
                                    rows: GameLogic.rows,
                                    cols: GameLogic.cols,
                                    acceptsInput:
                                        _viewModel.gameState.acceptsInput,
                                    clearingLines: _viewModel.clearingLines,
                                    lineClearAnimation: _lineClearAnimation,
                                    onRotate: _viewModel.rotatePiece,
                                    onMoveLeft: _viewModel.movePieceLeft,
                                    onMoveRight: _viewModel.movePieceRight,
                                    onSoftDrop: _viewModel.movePieceDown,
                                  ),
                                ),
                                SizedBox(
                                  width: sidebarWidth,
                                  child: NextPiecePreview(
                                    nextPiece: _viewModel.nextPiece,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: controlsHeight,
                          child: GameControls(
                            onMoveLeft: _viewModel.movePieceLeft,
                            onMoveRight: _viewModel.movePieceRight,
                            onRotate: _viewModel.rotatePiece,
                            onSoftDrop: _viewModel.movePieceDown,
                            onHardDrop: _viewModel.hardDrop,
                            onPause: _viewModel.togglePause,
                            isPaused: _viewModel.isPaused,
                            gameOver: _viewModel.gameOver,
                          ),
                        ),
                      ],
                    ),
                    if (_viewModel.isPaused && !_viewModel.gameOver)
                      PauseOverlay(onResume: _viewModel.togglePause),
                    if (_viewModel.gameOver)
                      GameOverOverlay(
                        animation: _gameOverAnimation,
                        score:
                            _viewModel.finalScoreAtGameOver ?? _viewModel.score,
                        isNewHighScore: _viewModel.isNewHighScore,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
