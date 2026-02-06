import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  final List<AudioPlayer> _players = [];
  final List<String>? files;
  final int maxPlayers;

  GameAudio(this.maxPlayers, {this.files});

  Future<void> init() async {
    for (int i = 0; i < maxPlayers; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      _players.add(player);
    }
  }

  Future<void> play(String file, {double volume = 1.0}) async {
    for (final player in _players) {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(
        AssetSource(file),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
      return;
    }
  }

  Future<void> stop() async {
    for (final player in _players) {
      await player.stop();
    }
  }

  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
  }

  /// Clears all the audios in the cache
  void clearAll() {
    // AudioCache moved to global cache in audioplayers 6.x; nothing to clear here.
  }

  /// Disables audio related logs
  void disableLog() {
    // No-op: logging control is handled by the audioplayers package internally.
  }
}

