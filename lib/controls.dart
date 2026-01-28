import 'package:flutter/material.dart';
import 'constants.dart';

class GameControls extends StatefulWidget {
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onPause;
  final bool isPaused;
  final bool gameOver;

  const GameControls({
    super.key,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onPause,
    this.isPaused = false,
    this.gameOver = false,
  });

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  // Button press states for visual feedback
  final Map<String, bool> _buttonPressed = {};

  void _onButtonPress(String buttonKey, VoidCallback action) {
    if (widget.gameOver) return;
    
    setState(() {
      _buttonPressed[buttonKey] = true;
    });
    
    action();
    
    // Reset button state after animation
    Future.delayed(GameConstants.buttonAnimationDuration, () {
      if (mounted) {
        setState(() {
          _buttonPressed[buttonKey] = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final buttonSize = (screenWidth * 0.12).clamp(
          GameConstants.minButtonSize,
          GameConstants.maxButtonSize,
        );
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top control row - Rotate, Hard Drop, Pause
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    'rotate',
                    Icons.rotate_left,
                    'ROTATE',
                    () => _onButtonPress('rotate', widget.onRotate),
                    GameConstants.primaryPurple,
                    buttonSize,
                  ),
                  _buildControlButton(
                    'hardDrop',
                    Icons.keyboard_double_arrow_down,
                    'DROP',
                    () => _onButtonPress('hardDrop', widget.onHardDrop),
                    GameConstants.primaryOrange,
                    buttonSize,
                  ),
                  _buildControlButton(
                    'pause',
                    widget.isPaused ? Icons.play_arrow : Icons.pause,
                    widget.isPaused ? 'PLAY' : 'PAUSE',
                    () => _onButtonPress('pause', widget.onPause),
                    GameConstants.primaryCyan,
                    buttonSize,
                  ),
                ],
              ),
              
              SizedBox(height: GameConstants.buttonSpacing),
              
              // Bottom control row - Left, Soft Drop, Right
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    'left',
                    Icons.keyboard_arrow_left,
                    'LEFT',
                    () => _onButtonPress('left', widget.onMoveLeft),
                    GameConstants.primaryBlue,
                    buttonSize,
                  ),
                  
                  SizedBox(width: buttonSize * 0.4),
                  
                  _buildControlButton(
                    'down',
                    Icons.keyboard_arrow_down,
                    'DOWN',
                    () => _onButtonPress('down', widget.onSoftDrop),
                    GameConstants.primaryGreen,
                    buttonSize,
                  ),
                  
                  SizedBox(width: buttonSize * 0.4),
                  
                  _buildControlButton(
                    'right',
                    Icons.keyboard_arrow_right,
                    'RIGHT',
                    () => _onButtonPress('right', widget.onMoveRight),
                    GameConstants.primaryBlue,
                    buttonSize,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(
    String key,
    IconData icon,
    String label,
    VoidCallback onPressed,
    Color color,
    double size,
  ) {
    final isPressed = _buttonPressed[key] ?? false;
    final isDisabled = widget.gameOver;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: GameConstants.buttonAnimationDuration,
          width: size,
          height: size,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(size * 0.2),
              child: AnimatedContainer(
                duration: GameConstants.buttonAnimationDuration,
                decoration: BoxDecoration(
                  color: isDisabled 
                      ? GameConstants.cellEmptyColor
                      : (isPressed 
                          ? color.withValues(alpha: 0.8)
                          : GameConstants.boardBackgroundColor),
                  borderRadius: BorderRadius.circular(size * 0.2),
                  border: Border.all(
                    color: isDisabled 
                        ? Colors.grey.withValues(alpha: 0.3)
                        : color,
                    width: 2,
                  ),
                  boxShadow: isDisabled ? null : [
                    BoxShadow(
                      color: color.withValues(alpha: isPressed ? 0.6 : 0.3),
                      blurRadius: isPressed ? 8 : 4,
                      spreadRadius: isPressed ? 2 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: size * 0.4,
                  color: isDisabled 
                      ? Colors.grey.withValues(alpha: 0.5)
                      : (isPressed ? Colors.white : color),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 6),
        
        Text(
          label,
          style: TextStyle(
            color: isDisabled 
                ? Colors.grey.withValues(alpha: 0.5)
                : Colors.white,
            fontSize: (size * 0.18).clamp(10.0, 14.0),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
