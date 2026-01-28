/// Game state management for Tetris
/// Ensures proper state transitions and prevents duplicate triggers
enum GameState {
  /// Home screen - no game logic running
  idle,
  
  /// Game is actively running - timer active, pieces falling
  playing,
  
  /// Game is paused - timer stopped, can resume
  paused,
  
  /// Game over - timer stopped, dialog shown, awaiting user action
  gameOver,
}

/// Extension methods for GameState to provide clear state checks
extension GameStateExtension on GameState {
  /// Returns true if game logic should be running
  bool get isActive => this == GameState.playing;
  
  /// Returns true if timer should be running
  bool get shouldRunTimer => this == GameState.playing;
  
  /// Returns true if user input should be accepted
  bool get acceptsInput => this == GameState.playing;
  
  /// Returns true if game is in a terminal state
  bool get isTerminal => this == GameState.gameOver;
  
  /// Returns true if game can be paused
  bool get canPause => this == GameState.playing;
  
  /// Returns true if game can be resumed
  bool get canResume => this == GameState.paused;
}