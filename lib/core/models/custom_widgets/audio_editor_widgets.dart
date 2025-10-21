import 'package:flutter/widgets.dart';

import '/features/audio_editor/audio_editor_page.dart';
import '/features/audio_editor/models/audio_track.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';

/// Builder signature for creating an audio editor app bar.
typedef AudioEditorAppBarBuilder = ReactiveAppbar? Function(
  AudioEditorPageState editorState,
  Stream<void> rebuildStream,
);

/// Builder signature for creating an audio editor bottom bar.
typedef AudioEditorBottomBarBuilder = ReactiveWidget? Function(
  AudioEditorPageState editorState,
  Stream<void> rebuildStream,
);

/// Builder signature for rendering an individual audio track widget.
typedef AudioEditorTrackBuilder = Widget Function(
  AudioTrack audioTrack,
  Function()? onTap,
);

/// A typedef for building custom audio waveform widgets in the audio editor.
///
/// This function type is used to create custom visual representations of audio
/// waveforms within the audio editor interface.
typedef AudioEditorWaveBuilder = Widget Function(
  AudioTrack audioTrack,
  Function(Duration startTime)? updateStartTime,
);

/// A collection of customizable widgets used in the audio editor UI.
///
/// Provides optional builders for the app bar, bottom bar, and
/// individual audio track items.
class AudioEditorWidgets {
  /// Creates an instance of [AudioEditorWidgets].
  const AudioEditorWidgets({
    this.audioTrackItem,
    this.appBar,
    this.bottomBar,
    this.audioWave,
  });

  /// Builder for a custom reactive app bar in the audio editor.
  ///
  /// Called with the current [AudioEditorPageState] and a [rebuildStream]
  /// to reactively update the app bar UI.
  final AudioEditorAppBarBuilder? appBar;

  /// Builder for a custom reactive bottom bar in the audio editor.
  ///
  /// Called with the current [AudioEditorPageState] and a [rebuildStream]
  /// to rebuild the bottom bar when the editor state changes.
  final AudioEditorBottomBarBuilder? bottomBar;

  /// Builder for rendering an individual audio track widget.
  ///
  /// Called with an [AudioTrack] and an optional [onTap] callback
  /// triggered when the user selects a specific timestamp.
  final AudioEditorTrackBuilder? audioTrackItem;

  /// Builder for displaying the waveform visualization of an audio track.
  ///
  /// Called with an [AudioTrack] and the current waveform data to render
  /// a custom visual representation of the audio signal.
  final AudioEditorWaveBuilder? audioWave;

  /// Returns a copy of this object with the provided overrides.
  AudioEditorWidgets copyWith({
    AudioEditorTrackBuilder? audioTrackItem,
    AudioEditorAppBarBuilder? appBar,
    AudioEditorBottomBarBuilder? bottomBar,
    AudioEditorWaveBuilder? audioWave,
  }) {
    return AudioEditorWidgets(
      audioTrackItem: audioTrackItem ?? this.audioTrackItem,
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      audioWave: audioWave ?? this.audioWave,
    );
  }
}
