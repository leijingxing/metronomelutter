import 'package:audioplayers/audioplayers.dart';

/// 低延迟音效播放器，维护固定数量的播放器实例用于节拍播放。
class GameAudio {
  final List<AudioPlayer> _players = [];
  final List<String>? files;
  final int maxPlayers;

  GameAudio(this.maxPlayers, {this.files});

  Future<void> init() async {
    for (int i = 0; i < maxPlayers; i++) {
      final AudioPlayer player = AudioPlayer();
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

  /// 清理缓存（audioplayers 6.x 后此处不再需要显式处理）。
  void clearAll() {
    // AudioCache moved to global cache in audioplayers 6.x; nothing to clear here.
  }

  /// 关闭日志（当前版本由包内部统一管理，此处保留兼容接口）。
  void disableLog() {
    // No-op: logging control is handled by the audioplayers package internally.
  }
}

