import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/features/game/presentation/screens/game_board_screen.dart';
import 'package:tetris/features/game/presentation/widgets/game_over_overlay.dart';
import 'package:tetris/features/game/presentation/widgets/next_piece_preview.dart';
import 'package:tetris/features/game/domain/tetromino.dart';

void main() {
  testWidgets('game board renders on small screen without overflow exception', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: GameBoard()));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });

  testWidgets('next piece preview always uses 4x4 grid', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NextPiecePreview(
            nextPiece: Tetromino.create(TetrominoType.I, 0, 0),
            isSmallScreen: true,
          ),
        ),
      ),
    );

    final gridView = tester.widget<GridView>(find.byType(GridView));
    final delegate = gridView.childrenDelegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game over celebration only appears when explicitly flagged', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameOverOverlay(
            animation: AlwaysStoppedAnimation<double>(1),
            score: 1000,
            isNewHighScore: false,
          ),
        ),
      ),
    );

    expect(find.text('NEW HIGH SCORE!'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameOverOverlay(
            animation: AlwaysStoppedAnimation<double>(1),
            score: 1000,
            isNewHighScore: true,
          ),
        ),
      ),
    );

    expect(find.text('NEW HIGH SCORE!'), findsOneWidget);
  });
}
