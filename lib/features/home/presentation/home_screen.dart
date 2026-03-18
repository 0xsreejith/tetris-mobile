import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../game/domain/score_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int highScore = 0;
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    await ScoreManager.instance.initialize();
    if (mounted) {
      setState(() {
        highScore = ScoreManager.instance.getHighScore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameConstants.backgroundColor,
              GameConstants.boardBackgroundColor,
              GameConstants.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isSmallScreen =
                  screenWidth < GameConstants.smallScreenWidth;

              return Column(
                children: [
                  // Title section
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _titleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titleAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'TETRIS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getTitleFontSize(screenWidth),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    shadows: [
                                      Shadow(
                                        color: GameConstants.primaryCyan
                                            .withValues(alpha: 0.8),
                                        blurRadius: 20,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Menu buttons section
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedMenuButton(
                          'PLAY',
                          Icons.play_arrow,
                          () async {
                            await Navigator.pushNamed(context, AppRouter.game);
                            // Refresh high score when returning from game
                            _loadHighScore();
                          },
                          0,
                          screenWidth,
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildAnimatedMenuButton(
                          'HIGH SCORES',
                          Icons.leaderboard,
                          () => _showHighScores(context),
                          1,
                          screenWidth,
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildAnimatedMenuButton(
                          'HOW TO PLAY',
                          Icons.help_outline,
                          () => _showInstructions(context),
                          2,
                          screenWidth,
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),

                  // Footer with version info
                  if (!isSmallScreen)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'v1.0.0 • Made with Flutter',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < GameConstants.smallScreenWidth) return 36;
    if (screenWidth < GameConstants.mediumScreenWidth) return 48;
    return 60;
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < GameConstants.smallScreenWidth) return 16;
    if (screenWidth < GameConstants.mediumScreenWidth) return 18;
    return 20;
  }

  Widget _buildAnimatedMenuButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    int index,
    double screenWidth,
    bool isSmallScreen,
  ) {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = (_buttonAnimation.value - delay).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: _buildMenuButton(
              text,
              icon,
              onPressed,
              screenWidth,
              isSmallScreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    double screenWidth,
    bool isSmallScreen,
  ) {
    final buttonWidth = screenWidth * (isSmallScreen ? 0.8 : 0.7);
    final buttonHeight = isSmallScreen ? 50.0 : 60.0;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: GameConstants.boardBackgroundColor,
          foregroundColor: Colors.white,
          side: BorderSide(
            color: GameConstants.primaryCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: GameConstants.primaryCyan.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 20 : 24,
              color: GameConstants.primaryCyan,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              text,
              style: TextStyle(
                fontSize: _getButtonFontSize(screenWidth),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHighScores(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.boardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: GameConstants.primaryCyan.withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          'HIGH SCORE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameConstants.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GameConstants.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$highScore',
                style: const TextStyle(
                  color: GameConstants.primaryYellow,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keep playing to beat your record!',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: GameConstants.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.boardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: GameConstants.primaryCyan.withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          'HOW TO PLAY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionSection(
                'TOUCH CONTROLS:',
                GameConstants.primaryCyan,
                [
                  _buildInstructionItem(
                    Icons.touch_app,
                    'Tap board',
                    'Rotate piece',
                  ),
                  _buildInstructionItem(
                    Icons.swipe,
                    'Swipe left/right',
                    'Move piece',
                  ),
                  _buildInstructionItem(Icons.swipe, 'Swipe down', 'Soft drop'),
                ],
              ),
              const SizedBox(height: 16),
              _buildInstructionSection(
                'BUTTONS:',
                GameConstants.primaryPurple,
                [
                  _buildInstructionItem(
                    Icons.rotate_left,
                    'Rotate',
                    'Rotate piece',
                  ),
                  _buildInstructionItem(
                    Icons.keyboard_double_arrow_down,
                    'Drop',
                    'Hard drop',
                  ),
                  _buildInstructionItem(Icons.pause, 'Pause', 'Pause/Resume'),
                ],
              ),
              const SizedBox(height: 16),
              _buildInstructionSection(
                'SCORING:',
                GameConstants.primaryGreen,
                [
                      '• Single line: 100 × level',
                      '• Double line: 300 × level',
                      '• Triple line: 500 × level',
                      '• Tetris (4 lines): 800 × level',
                      '• Hard drop: +2 per cell',
                    ]
                    .map(
                      (text) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT!',
              style: TextStyle(color: GameConstants.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection(
    String title,
    Color color,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildInstructionItem(
    IconData icon,
    String action,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: GameConstants.primaryCyan, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$action: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
