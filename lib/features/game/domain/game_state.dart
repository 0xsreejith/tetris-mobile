/// Game state management for Tetris.
enum GameState { idle, playing, paused, gameOver }

extension GameStateExtension on GameState {
  bool get isActive => this == GameState.playing;
  bool get shouldRunTimer => this == GameState.playing;
  bool get acceptsInput => this == GameState.playing;
  bool get isTerminal => this == GameState.gameOver;
  bool get canPause => this == GameState.playing;
  bool get canResume => this == GameState.paused;
}
