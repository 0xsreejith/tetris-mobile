import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

class GameControls extends StatefulWidget {
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

  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onPause;
  final bool isPaused;
  final bool gameOver;

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  final Map<String, bool> _buttonPressed = {};

  void _onButtonPress(String buttonKey, VoidCallback action) {
    if (widget.gameOver) return;

    setState(() {
      _buttonPressed[buttonKey] = true;
    });

    action();

    Future.delayed(GameConstants.buttonAnimationDuration, () {
      if (!mounted) return;
      setState(() {
        _buttonPressed[buttonKey] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final compact = constraints.maxHeight < 140;
        final verticalPadding = compact ? 8.0 : 12.0;
        final rowSpacing = compact ? 8.0 : GameConstants.buttonSpacing;

        final widthBasedSize = (screenWidth * 0.12).clamp(
          32.0,
          GameConstants.maxButtonSize,
        );
        final heightBasedSize =
            ((constraints.maxHeight - (verticalPadding * 2) - rowSpacing - 24) /
                    2)
                .clamp(28.0, GameConstants.maxButtonSize);
        final buttonSize = math.min(
          widthBasedSize.toDouble(),
          heightBasedSize.toDouble(),
        );
        final labelFontSize = (buttonSize * 0.2).clamp(9.0, 14.0);
        final horizontalGap = buttonSize * (compact ? 0.25 : 0.4);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: verticalPadding,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      key: 'rotate',
                      icon: Icons.rotate_left,
                      label: 'ROTATE',
                      onPressed: () =>
                          _onButtonPress('rotate', widget.onRotate),
                      color: GameConstants.primaryPurple,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                    _buildControlButton(
                      key: 'hardDrop',
                      icon: Icons.keyboard_double_arrow_down,
                      label: 'DROP',
                      onPressed: () =>
                          _onButtonPress('hardDrop', widget.onHardDrop),
                      color: GameConstants.primaryOrange,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                    _buildControlButton(
                      key: 'pause',
                      icon: widget.isPaused ? Icons.play_arrow : Icons.pause,
                      label: widget.isPaused ? 'PLAY' : 'PAUSE',
                      onPressed: () => _onButtonPress('pause', widget.onPause),
                      color: GameConstants.primaryCyan,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                  ],
                ),
                SizedBox(height: rowSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      key: 'left',
                      icon: Icons.keyboard_arrow_left,
                      label: 'LEFT',
                      onPressed: () =>
                          _onButtonPress('left', widget.onMoveLeft),
                      color: GameConstants.primaryBlue,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                    SizedBox(width: horizontalGap),
                    _buildControlButton(
                      key: 'down',
                      icon: Icons.keyboard_arrow_down,
                      label: 'DOWN',
                      onPressed: () =>
                          _onButtonPress('down', widget.onSoftDrop),
                      color: GameConstants.primaryGreen,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                    SizedBox(width: horizontalGap),
                    _buildControlButton(
                      key: 'right',
                      icon: Icons.keyboard_arrow_right,
                      label: 'RIGHT',
                      onPressed: () =>
                          _onButtonPress('right', widget.onMoveRight),
                      color: GameConstants.primaryBlue,
                      size: buttonSize,
                      labelFontSize: labelFontSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required String key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required double size,
    required double labelFontSize,
  }) {
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
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(
                              alpha: isPressed ? 0.6 : 0.3,
                            ),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.5)
                : Colors.white,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
