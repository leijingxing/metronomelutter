// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RecordingStore on _RecordingStore, Store {
  late final _$initializedAtom =
      Atom(name: '_RecordingStore.initialized', context: context);

  @override
  bool get initialized {
    _$initializedAtom.reportRead();
    return super.initialized;
  }

  @override
  set initialized(bool value) {
    _$initializedAtom.reportWrite(value, super.initialized, () {
      super.initialized = value;
    });
  }

  late final _$isSheetOpenAtom =
      Atom(name: '_RecordingStore.isSheetOpen', context: context);

  @override
  bool get isSheetOpen {
    _$isSheetOpenAtom.reportRead();
    return super.isSheetOpen;
  }

  @override
  set isSheetOpen(bool value) {
    _$isSheetOpenAtom.reportWrite(value, super.isSheetOpen, () {
      super.isSheetOpen = value;
    });
  }

  late final _$isRecordingAtom =
      Atom(name: '_RecordingStore.isRecording', context: context);

  @override
  bool get isRecording {
    _$isRecordingAtom.reportRead();
    return super.isRecording;
  }

  @override
  set isRecording(bool value) {
    _$isRecordingAtom.reportWrite(value, super.isRecording, () {
      super.isRecording = value;
    });
  }

  late final _$isPlayingAtom =
      Atom(name: '_RecordingStore.isPlaying', context: context);

  @override
  bool get isPlaying {
    _$isPlayingAtom.reportRead();
    return super.isPlaying;
  }

  @override
  set isPlaying(bool value) {
    _$isPlayingAtom.reportWrite(value, super.isPlaying, () {
      super.isPlaying = value;
    });
  }

  late final _$isPausedAtom =
      Atom(name: '_RecordingStore.isPaused', context: context);

  @override
  bool get isPaused {
    _$isPausedAtom.reportRead();
    return super.isPaused;
  }

  @override
  set isPaused(bool value) {
    _$isPausedAtom.reportWrite(value, super.isPaused, () {
      super.isPaused = value;
    });
  }

  late final _$withMetronomeAtom =
      Atom(name: '_RecordingStore.withMetronome', context: context);

  @override
  bool get withMetronome {
    _$withMetronomeAtom.reportRead();
    return super.withMetronome;
  }

  @override
  set withMetronome(bool value) {
    _$withMetronomeAtom.reportWrite(value, super.withMetronome, () {
      super.withMetronome = value;
    });
  }

  late final _$activeClipIdAtom =
      Atom(name: '_RecordingStore.activeClipId', context: context);

  @override
  String get activeClipId {
    _$activeClipIdAtom.reportRead();
    return super.activeClipId;
  }

  @override
  set activeClipId(String value) {
    _$activeClipIdAtom.reportWrite(value, super.activeClipId, () {
      super.activeClipId = value;
    });
  }

  late final _$currentAmpAtom =
      Atom(name: '_RecordingStore.currentAmp', context: context);

  @override
  double get currentAmp {
    _$currentAmpAtom.reportRead();
    return super.currentAmp;
  }

  @override
  set currentAmp(double value) {
    _$currentAmpAtom.reportWrite(value, super.currentAmp, () {
      super.currentAmp = value;
    });
  }

  late final _$recordElapsedMsAtom =
      Atom(name: '_RecordingStore.recordElapsedMs', context: context);

  @override
  int get recordElapsedMs {
    _$recordElapsedMsAtom.reportRead();
    return super.recordElapsedMs;
  }

  @override
  set recordElapsedMs(int value) {
    _$recordElapsedMsAtom.reportWrite(value, super.recordElapsedMs, () {
      super.recordElapsedMs = value;
    });
  }

  late final _$playbackProgressAtom =
      Atom(name: '_RecordingStore.playbackProgress', context: context);

  @override
  double get playbackProgress {
    _$playbackProgressAtom.reportRead();
    return super.playbackProgress;
  }

  @override
  set playbackProgress(double value) {
    _$playbackProgressAtom.reportWrite(value, super.playbackProgress, () {
      super.playbackProgress = value;
    });
  }

  late final _$playbackPositionMsAtom =
      Atom(name: '_RecordingStore.playbackPositionMs', context: context);

  @override
  int get playbackPositionMs {
    _$playbackPositionMsAtom.reportRead();
    return super.playbackPositionMs;
  }

  @override
  set playbackPositionMs(int value) {
    _$playbackPositionMsAtom.reportWrite(value, super.playbackPositionMs, () {
      super.playbackPositionMs = value;
    });
  }

  late final _$playbackDurationMsAtom =
      Atom(name: '_RecordingStore.playbackDurationMs', context: context);

  @override
  int get playbackDurationMs {
    _$playbackDurationMsAtom.reportRead();
    return super.playbackDurationMs;
  }

  @override
  set playbackDurationMs(int value) {
    _$playbackDurationMsAtom.reportWrite(value, super.playbackDurationMs, () {
      super.playbackDurationMs = value;
    });
  }

  late final _$livePeaksAtom =
      Atom(name: '_RecordingStore.livePeaks', context: context);

  @override
  ObservableList<double> get livePeaks {
    _$livePeaksAtom.reportRead();
    return super.livePeaks;
  }

  @override
  set livePeaks(ObservableList<double> value) {
    _$livePeaksAtom.reportWrite(value, super.livePeaks, () {
      super.livePeaks = value;
    });
  }

  late final _$clipsAtom =
      Atom(name: '_RecordingStore.clips', context: context);

  @override
  ObservableList<RecordingClip> get clips {
    _$clipsAtom.reportRead();
    return super.clips;
  }

  @override
  set clips(ObservableList<RecordingClip> value) {
    _$clipsAtom.reportWrite(value, super.clips, () {
      super.clips = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_RecordingStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$startRecordAsyncAction =
      AsyncAction('_RecordingStore.startRecord', context: context);

  @override
  Future<String?> startRecord() {
    return _$startRecordAsyncAction.run(() => super.startRecord());
  }

  late final _$stopRecordAsyncAction =
      AsyncAction('_RecordingStore.stopRecord', context: context);

  @override
  Future<String?> stopRecord() {
    return _$stopRecordAsyncAction.run(() => super.stopRecord());
  }

  late final _$cancelRecordAsyncAction =
      AsyncAction('_RecordingStore.cancelRecord', context: context);

  @override
  Future<void> cancelRecord() {
    return _$cancelRecordAsyncAction.run(() => super.cancelRecord());
  }

  late final _$loadClipsAsyncAction =
      AsyncAction('_RecordingStore.loadClips', context: context);

  @override
  Future<void> loadClips() {
    return _$loadClipsAsyncAction.run(() => super.loadClips());
  }

  late final _$playClipAsyncAction =
      AsyncAction('_RecordingStore.playClip', context: context);

  @override
  Future<String?> playClip(String id) {
    return _$playClipAsyncAction.run(() => super.playClip(id));
  }

  late final _$stopPlayAsyncAction =
      AsyncAction('_RecordingStore.stopPlay', context: context);

  @override
  Future<void> stopPlay() {
    return _$stopPlayAsyncAction.run(() => super.stopPlay());
  }

  late final _$pausePlayAsyncAction =
      AsyncAction('_RecordingStore.pausePlay', context: context);

  @override
  Future<void> pausePlay() {
    return _$pausePlayAsyncAction.run(() => super.pausePlay());
  }

  late final _$resumePlayAsyncAction =
      AsyncAction('_RecordingStore.resumePlay', context: context);

  @override
  Future<void> resumePlay() {
    return _$resumePlayAsyncAction.run(() => super.resumePlay());
  }

  late final _$seekToProgressAsyncAction =
      AsyncAction('_RecordingStore.seekToProgress', context: context);

  @override
  Future<void> seekToProgress(double progress) {
    return _$seekToProgressAsyncAction
        .run(() => super.seekToProgress(progress));
  }

  late final _$deleteClipAsyncAction =
      AsyncAction('_RecordingStore.deleteClip', context: context);

  @override
  Future<void> deleteClip(String id) {
    return _$deleteClipAsyncAction.run(() => super.deleteClip(id));
  }

  late final _$_RecordingStoreActionController =
      ActionController(name: '_RecordingStore', context: context);

  @override
  void openSheet() {
    final _$actionInfo = _$_RecordingStoreActionController.startAction(
        name: '_RecordingStore.openSheet');
    try {
      return super.openSheet();
    } finally {
      _$_RecordingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeSheet() {
    final _$actionInfo = _$_RecordingStoreActionController.startAction(
        name: '_RecordingStore.closeSheet');
    try {
      return super.closeSheet();
    } finally {
      _$_RecordingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWithMetronome(bool value) {
    final _$actionInfo = _$_RecordingStoreActionController.startAction(
        name: '_RecordingStore.setWithMetronome');
    try {
      return super.setWithMetronome(value);
    } finally {
      _$_RecordingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
initialized: ${initialized},
isSheetOpen: ${isSheetOpen},
isRecording: ${isRecording},
isPlaying: ${isPlaying},
isPaused: ${isPaused},
withMetronome: ${withMetronome},
activeClipId: ${activeClipId},
currentAmp: ${currentAmp},
recordElapsedMs: ${recordElapsedMs},
playbackProgress: ${playbackProgress},
playbackPositionMs: ${playbackPositionMs},
playbackDurationMs: ${playbackDurationMs},
livePeaks: ${livePeaks},
clips: ${clips}
    ''';
  }
}
