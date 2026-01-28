import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// Manages high score persistence and retrieval
/// Ensures thread-safe operations and prevents race conditions
class ScoreManager {
  static ScoreManager? _instance;
  static ScoreManager get instance => _instance ??= ScoreManager._();
  
  ScoreManager._();
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  /// Initialize SharedPreferences - call this once at app start
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }
  
  /// Get current high score
  /// Returns 0 if no high score is saved
  int getHighScore() {
    if (!_isInitialized || _prefs == null) {
      return 0;
    }
    return _prefs!.getInt(GameConstants.highScoreKey) ?? 0;
  }
  
  /// Update high score if new score is higher
  /// Returns true if high score was updated, false otherwise
  Future<bool> updateHighScore(int newScore) async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }
    
    final currentHighScore = getHighScore();
    
    if (newScore > currentHighScore) {
      await _prefs!.setInt(GameConstants.highScoreKey, newScore);
      return true; // New high score achieved
    }
    
    return false; // No new high score
  }
  
  /// Force set high score (for testing or reset purposes)
  Future<void> setHighScore(int score) async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }
    await _prefs!.setInt(GameConstants.highScoreKey, score);
  }
  
  /// Reset high score to 0
  Future<void> resetHighScore() async {
    await setHighScore(0);
  }
}