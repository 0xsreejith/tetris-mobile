import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_logic.dart';
import 'game_state.dart';
import 'controls.dart';
import 'constants.dart';
import 'game_over_dialog.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> 
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late GameLogic gameLogic;
  Timer? _gameTimer;
  bool _gameOverDialogShown = false; // Prevent duplicate dialogs
  
  // Animation controllers
  late AnimationController _lineClearController;
  late AnimationController _gameOverController;
  late Animation<double> _lineClearAnimation;
  late Animation<double> _gameOverAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize animation controllers
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
    
    // Initialize game logic and start game
    gameLogic = GameLogic();
    gameLogic.addListener(_onGameStateChanged);
    
    // Start the game immediately when screen loads
    gameLogic.startGame();
    _startGameTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopGameTimer();
    _lineClearController.dispose();
    _gameOverController.dispose();
    gameLogic.removeListener(_onGameStateChanged);
    gameLogic.dispose();
    super.dispose();
  }

  /// GAME STATE CHANGE HANDLER
  /// Responds to game state changes and manages timer/UI accordingly
  void _onGameStateChanged() {
    if (!mounted) return;
    
    switch (gameLogic.gameState) {
      case GameState.playing:
        _startGameTimer();
        _gameOverDialogShown = false; // Reset dialog flag for new game
        break;
        
      case GameState.paused:
        _stopGameTimer();
        break;
        
      case GameState.gameOver:
        _stopGameTimer();
        _triggerGameOverAnimation();
        break;
        
      case GameState.idle:
        _stopGameTimer();
        break;
    }
  }
  
  /// TIMER MANAGEMENT
  /// Proper timer lifecycle management based on game state
  
  void _startGameTimer() {
    _stopGameTimer(); // Ensure no duplicate timers
    
    if (!gameLogic.gameState.shouldRunTimer) return;
    
    _gameTimer = Timer.periodic(gameLogic.dropDuration, (timer) {
      // Only move piece if game is still in playing state
      if (gameLogic.gameState.shouldRunTimer && !gameLogic.isLineClearing) {
        gameLogic.movePieceDown();
        
        // Restart timer if level changed (speed increased)
        if (timer.tick > 1) {
          final currentDuration = Duration(milliseconds: timer.tick * gameLogic.dropDuration.inMilliseconds);
          if (currentDuration != gameLogic.dropDuration) {
            _startGameTimer();
          }
        }
      }
    });
  }
  
  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }
  
  /// GAME OVER HANDLING
  /// Ensures game over is handled exactly once
  
  void _triggerGameOverAnimation() {
    if (!_gameOverController.isCompleted) {
      _gameOverController.forward();
      
      // Show dialog after animation, but only once
      Future.delayed(GameConstants.gameOverAnimationDuration, () {
        if (mounted && gameLogic.gameState == GameState.gameOver && !_gameOverDialogShown) {
          _gameOverDialogShown = true;
          _showGameOverDialog();
        }
      });
    }
  }

  /// APP LIFECYCLE HANDLING
  /// Proper pause/resume behavior based on app state
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Auto-pause only if game is currently playing
        if (gameLogic.gameState == GameState.playing) {
          gameLogic.pauseGame();
        }
        break;
        
      case AppLifecycleState.resumed:
        // Game remains paused until user manually resumes
        // This prevents accidental resume when returning to app
        break;
        
      case AppLifecycleState.detached:
        _stopGameTimer();
        break;
        
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: gameLogic,
          builder: (context, child) {
            // Trigger animations based on game state
            if (gameLogic.isLineClearing && !_lineClearController.isAnimating) {
              _lineClearController.forward().then((_) {
                _lineClearController.reset();
              });
            }
            
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Responsive calculations
        final isSmallScreen = screenWidth < GameConstants.smallScreenWidth;
        
        // Calculate optimal board size
        final availableWidth = screenWidth * GameConstants.boardWidthRatio;
        
        final cellSize = (availableWidth / GameLogic.cols).clamp(
          GameConstants.minCellSize,
          GameConstants.maxCellSize,
        );
        
        final boardWidth = cellSize * GameLogic.cols;
        final boardHeight = cellSize * GameLogic.rows;
        
        // Adjust sidebar width based on screen size
        final sidebarWidth = isSmallScreen 
            ? screenWidth * 0.12
            : screenWidth * GameConstants.sidebarWidthRatio;

        return Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(screenWidth, isSmallScreen),

                // Main game area
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left sidebar - Score info
                      SizedBox(
                        width: sidebarWidth,
                        child: _buildLeftSidebar(isSmallScreen),
                      ),

                      // Game board
                      SizedBox(
                        width: boardWidth,
                        height: boardHeight,
                        child: _buildGameBoard(cellSize),
                      ),

                      // Right sidebar - Next piece
                      SizedBox(
                        width: sidebarWidth,
                        child: _buildRightSidebar(isSmallScreen, cellSize),
                      ),
                    ],
                  ),
                ),

                // Game controls
                SizedBox(
                  height: screenHeight * GameConstants.controlsHeightRatio,
                  child: GameControls(
                    onMoveLeft: gameLogic.movePieceLeft,
                    onMoveRight: gameLogic.movePieceRight,
                    onRotate: gameLogic.rotatePiece,
                    onSoftDrop: gameLogic.movePieceDown,
                    onHardDrop: gameLogic.hardDrop,
                    onPause: gameLogic.togglePause,
                    isPaused: gameLogic.isPaused,
                    gameOver: gameLogic.gameOver,
                  ),
                ),
              ],
            ),

            // Overlays
            if (gameLogic.isPaused && !gameLogic.gameOver)
              _buildPauseOverlay(),

            if (gameLogic.gameOver)
              _buildGameOverOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildHeader(double screenWidth, bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 50 : 60,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameConstants.backgroundColor,
            GameConstants.boardBackgroundColor,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: isSmallScreen ? 20 : 24,
            onPressed: () {
              // Properly clean up when leaving game screen
              gameLogic.returnToIdle();
              Navigator.pop(context);
            },
          ),
          Text(
            'TETRIS',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: GameConstants.primaryCyan.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            iconSize: isSmallScreen ? 20 : 24,
            onPressed: gameLogic.reset,
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final valueFontSize = isSmallScreen ? 12.0 : 16.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreItem('SCORE', gameLogic.score.toString(), 
            Colors.white, fontSize, valueFontSize),
        SizedBox(height: isSmallScreen ? 8 : 12),
        _buildScoreItem('LEVEL', gameLogic.level.toString(), 
            GameConstants.primaryCyan, fontSize, valueFontSize),
        SizedBox(height: isSmallScreen ? 8 : 12),
        _buildScoreItem('LINES', gameLogic.lines.toString(), 
            GameConstants.primaryGreen, fontSize, valueFontSize),
        if (gameLogic.highScore > 0) ...[
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildScoreItem('HIGH', gameLogic.highScore.toString(),
              GameConstants.primaryYellow, fontSize, valueFontSize),
        ],
      ],
    );
  }

  Widget _buildRightSidebar(bool isSmallScreen, double cellSize) {
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
          width: isSmallScreen ? 40 : 60,
          height: isSmallScreen ? 40 : 60,
          decoration: BoxDecoration(
            border: Border.all(color: GameConstants.primaryCyan, width: 1),
            color: GameConstants.boardBackgroundColor,
            borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
          ),
          child: gameLogic.nextPiece != null 
              ? _buildNextPiece(isSmallScreen) 
              : null,
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, String value, Color color, 
      double labelSize, double valueSize) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: labelSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard(double cellSize) {
    return GestureDetector(
      // Touch controls
      onTap: () {
        if (gameLogic.gameState.acceptsInput) {
          HapticFeedback.lightImpact();
          gameLogic.rotatePiece();
        }
      },
      onPanEnd: (details) {
        if (!gameLogic.gameState.acceptsInput) return;

        final velocity = details.velocity.pixelsPerSecond;
        final threshold = GameConstants.swipeThreshold;

        if (velocity.dx.abs() > velocity.dy.abs()) {
          // Horizontal swipe
          if (velocity.dx > threshold) {
            HapticFeedback.selectionClick();
            gameLogic.movePieceRight();
          } else if (velocity.dx < -threshold) {
            HapticFeedback.selectionClick();
            gameLogic.movePieceLeft();
          }
        } else if (velocity.dy > threshold) {
          // Vertical swipe down
          HapticFeedback.lightImpact();
          gameLogic.movePieceDown();
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
            crossAxisCount: GameLogic.cols,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ GameLogic.cols;
            final col = index % GameLogic.cols;

            return _buildCell(row, col, cellSize);
          },
          itemCount: GameLogic.rows * GameLogic.cols,
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    Color? cellColor = gameLogic.board[row][col];
    bool isGhostCell = false;
    bool isClearingLine = gameLogic.clearingLines.contains(row);

    // Check for current piece
    if (gameLogic.currentPiece != null) {
      final piece = gameLogic.currentPiece!;
      final pieceRow = row - piece.y;
      final pieceCol = col - piece.x;

      if (pieceRow >= 0 &&
          pieceRow < piece.height &&
          pieceCol >= 0 &&
          pieceCol < piece.width &&
          piece.shape[pieceRow][pieceCol] == 1) {
        cellColor = piece.color;
      }
    }

    // Check for ghost piece (only if no current piece at this position)
    if (cellColor == null && gameLogic.ghostPiece != null) {
      final ghost = gameLogic.ghostPiece!;
      final ghostRow = row - ghost.y;
      final ghostCol = col - ghost.x;

      if (ghostRow >= 0 &&
          ghostRow < ghost.height &&
          ghostCol >= 0 &&
          ghostCol < ghost.width &&
          ghost.shape[ghostRow][ghostCol] == 1) {
        cellColor = GameConstants.ghostPieceColor;
        isGhostCell = true;
      }
    }

    return AnimatedBuilder(
      animation: _lineClearAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: GameConstants.pieceAnimationDuration,
          margin: EdgeInsets.all(GameConstants.cellMargin),
          decoration: BoxDecoration(
            color: isClearingLine 
                ? (cellColor ?? GameConstants.cellEmptyColor)
                    .withValues(alpha: _lineClearAnimation.value)
                : (cellColor ?? GameConstants.cellEmptyColor),
            border: Border.all(
              color: isGhostCell 
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.3),
              width: GameConstants.cellBorderWidth,
            ),
            borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
            boxShadow: cellColor != null && !isGhostCell ? [
              BoxShadow(
                color: cellColor.withValues(alpha: 0.3),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ] : null,
          ),
        );
      },
    );
  }

  Widget _buildNextPiece(bool isSmallScreen) {
    final piece = gameLogic.nextPiece!;
    final gridSize = isSmallScreen ? 3 : 4;
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ gridSize;
        final col = index % gridSize;

        if (row < piece.height &&
            col < piece.width &&
            piece.shape[row][col] == 1) {
          return Container(
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              color: piece.color,
              border: Border.all(color: Colors.black.withValues(alpha: 0.3), width: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: GameConstants.cellEmptyColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
      itemCount: gridSize * gridSize,
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: GameConstants.backgroundColor.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
              onPressed: gameLogic.togglePause,
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

  Widget _buildGameOverOverlay() {
    return AnimatedBuilder(
      animation: _gameOverAnimation,
      builder: (context, child) {
        return Container(
          color: GameConstants.backgroundColor.withValues(
            alpha: 0.95 * _gameOverAnimation.value,
          ),
          child: Center(
            child: Transform.scale(
              scale: _gameOverAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: GameConstants.primaryRed,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score: ${gameLogic.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (gameLogic.score == gameLogic.highScore) ...[
                    const SizedBox(height: 10),
                    const Text(
                      '🎉 NEW HIGH SCORE! 🎉',
                      style: TextStyle(
                        color: GameConstants.primaryYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => GameOverDialog(
        score: gameLogic.score,
        highScore: gameLogic.highScore,
        isNewHighScore: gameLogic.score == gameLogic.highScore && gameLogic.score > 0,
        onRetry: () {
          Navigator.of(context).pop(); // Close dialog
          _gameOverController.reset();
          _gameOverDialogShown = false;
          gameLogic.reset(); // This will transition to playing state
        },
        onHome: () {
          Navigator.of(context).pop(); // Close dialog
          gameLogic.returnToIdle(); // Clean transition to idle
          Navigator.of(context).pop(); // Go back to home screen
        },
      ),
    );
  }
}