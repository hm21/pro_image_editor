import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/audio_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/video_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/video/video_editor_configs.dart';
import 'package:pro_image_editor/core/models/video/trim_duration_span_model.dart';
import 'package:pro_image_editor/shared/controllers/video_controller.dart';

class DummyCallbacks extends VideoEditorCallbacks {
  bool played = false;
  bool paused = false;
  bool muted = false;
  bool trimUpdated = false;
  bool? lastMuteState;
  TrimDurationSpan? lastTrimSpan;

  @override
  VoidCallback? get onPlay => () {
        played = true;
      };

  @override
  VoidCallback? get onPause => () {
        paused = true;
      };

  @override
  void Function(bool)? get onMuteToggle => (isMuted) {
        muted = true;
        lastMuteState = isMuted;
      };

  @override
  void Function(TrimDurationSpan)? get onTrimSpanUpdate => (span) {
        trimUpdated = true;
        lastTrimSpan = span;
      };
}

class DummyAudioCallbacks extends AudioEditorCallbacks {}

class DummyConfigs extends VideoEditorConfigs {
  @override
  bool get initialPlay => false;

  @override
  bool get initialMuted => false;
}

void main() {
  group('ProVideoController', () {
    late ProVideoController controller;
    late DummyCallbacks callbacks;
    late DummyConfigs configs;
    final dummyWidget = Container();
    const dummyDuration = Duration(seconds: 10);
    const dummyResolution = Size(1920, 1080);
    const dummyFileSize = 123456;

    setUp(() {
      callbacks = DummyCallbacks();
      configs = DummyConfigs();
      controller = ProVideoController(
        videoPlayer: dummyWidget,
        videoDuration: dummyDuration,
        initialResolution: dummyResolution,
        fileSize: dummyFileSize,
      )..initialize(
          callbacksAudioFunction: DummyAudioCallbacks.new,
          callbacksFunction: () => callbacks,
          configsFunction: () => configs,
        );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with correct values', () {
      expect(controller.videoPlayer, dummyWidget);
      expect(controller.videoDuration, dummyDuration);
      expect(controller.initialResolution, dummyResolution);
      expect(controller.fileSize, dummyFileSize);
      expect(controller.bitrate, isNull);
      expect(controller.thumbnails, isNull);
      expect(controller.isAudioEnabled, isTrue);
      expect(controller.startTime, Duration.zero);
      expect(controller.endTime, dummyDuration);
    });

    test('thumbnails getter/setter works', () {
      final thumbs = [MemoryImage(Uint8List(0))];
      controller.thumbnails = thumbs;
      expect(controller.thumbnails, thumbs);
    });

    test('togglePlayState toggles play and pause', () {
      controller.togglePlayState();
      expect(controller.isPlayingNotifier.value, isTrue);
      expect(callbacks.played, isTrue);

      callbacks.played = false;
      controller.togglePlayState();
      expect(controller.isPlayingNotifier.value, isFalse);
      expect(callbacks.paused, isTrue);
    });

    test('play() sets isPlayingNotifier and calls onPlay', () {
      controller.play();
      expect(controller.isPlayingNotifier.value, isTrue);
      expect(callbacks.played, isTrue);
    });

    test('pause() sets isPlayingNotifier and calls onPause', () {
      controller
        ..play()
        ..pause();
      expect(controller.isPlayingNotifier.value, isFalse);
      expect(callbacks.paused, isTrue);
    });

    test('setMuteState updates isMutedNotifier and calls onMuteToggle', () {
      controller.setMuteState(true);
      expect(controller.isMutedNotifier.value, isTrue);
      expect(callbacks.muted, isTrue);
      expect(callbacks.lastMuteState, isTrue);

      controller.setMuteState(false);
      expect(controller.isMutedNotifier.value, isFalse);
      expect(callbacks.lastMuteState, isFalse);
    });

    test(
        'setTrimSpan updates trimDurationSpanNotifier and calls '
        'onTrimSpanUpdate', () {
      const span = TrimDurationSpan(
          start: Duration(seconds: 2), end: Duration(seconds: 8));
      controller.setTrimSpan(span);
      expect(controller.trimDurationSpanNotifier.value.start, span.start);
      expect(controller.trimDurationSpanNotifier.value.end, span.end);
      expect(callbacks.trimUpdated, isTrue);
      expect(callbacks.lastTrimSpan, isNotNull);
      expect(callbacks.lastTrimSpan!.start, span.start);
      expect(callbacks.lastTrimSpan!.end, span.end);
    });

    test('setTrimStart updates only start', () {
      const newStart = Duration(seconds: 3);
      controller.setTrimStart(newStart);
      expect(controller.trimDurationSpanNotifier.value.start, newStart);
      expect(controller.trimDurationSpanNotifier.value.end, dummyDuration);
      expect(callbacks.trimUpdated, isTrue);
    });

    test('setTrimEnd updates only end', () {
      const newEnd = Duration(seconds: 7);
      controller.setTrimEnd(newEnd);
      expect(controller.trimDurationSpanNotifier.value.start, Duration.zero);
      expect(controller.trimDurationSpanNotifier.value.end, newEnd);
      expect(callbacks.trimUpdated, isTrue);
    });

    test('setPlayTime updates playTimeNotifier', () {
      const newTime = Duration(seconds: 5);
      controller.setPlayTime(newTime);
      expect(controller.playTimeNotifier.value, newTime);
    });

    test('showTrimTimeSpanNotifier can be toggled', () {
      expect(controller.showTrimTimeSpanNotifier.value, isFalse);
      controller.showTrimTimeSpanNotifier.value = true;
      expect(controller.showTrimTimeSpanNotifier.value, isTrue);
    });
  });
}
