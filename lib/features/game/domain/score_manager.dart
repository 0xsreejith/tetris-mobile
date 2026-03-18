import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';

/// Manages high score persistence and retrieval.
class ScoreManager {
  static ScoreManager? _instance;
  static ScoreManager get instance => _instance ??= ScoreManager._();

  ScoreManager._();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  int getHighScore() {
    if (!_isInitialized || _prefs == null) {
      return 0;
    }
    return _prefs!.getInt(GameConstants.highScoreKey) ?? 0;
  }

  Future<bool> updateHighScore(int newScore) async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }

    final currentHighScore = getHighScore();
    if (newScore > currentHighScore) {
      await _prefs!.setInt(GameConstants.highScoreKey, newScore);
      return true;
    }

    return false;
  }

  Future<void> setHighScore(int score) async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }
    await _prefs!.setInt(GameConstants.highScoreKey, score);
  }

  Future<void> resetHighScore() async {
    await setHighScore(0);
  }
}
