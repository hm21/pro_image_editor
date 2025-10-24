import 'package:flutter/widgets.dart';

import '/features/audio_editor/audio_editor_page.dart';
import '/features/audio_editor/models/audio_track.dart';
import '/features/audio_editor/widgets/audio_main_bottom_bar.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';
import 'utils/custom_widgets_typedef.dart';

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
  ValueChanged<Duration>? updateStartTime,
);

/// Builder signature for creating an audio editor edit sheet.
typedef AudioEditorEditSheetBuilder = Widget Function(
  AudioMainBottomBarState editorState,
  ProVideoController controller,
  ValueChanged<Duration> updateStartTime,
  ValueChanged<double> updateBalance,
  VoidCallback openSelectTrack,
  VoidCallback confirm,
);

/// Builder signature for creating an audio editor edit track button.
typedef AudioEditorEditTrackButtonBuilder = Widget Function(
  AudioMainBottomBarState editorState,
  VoidCallback openSelectTrack,
);

/// Builder signature for creating an audio editor confirm button.
typedef AudioEditorConfirmButtonBuilder = Widget Function(
  AudioMainBottomBarState editorState,
  VoidCallback confirm,
);

/// Builder signature for creating an audio editor start time selector.
typedef AudioEditorStartTimeSelectorBuilder = Widget Function(
  AudioMainBottomBarState editorState,
  ProVideoController controller,
  ValueChanged<Duration> updateStartTime,
);

/// Builder signature for creating an audio editor balance chooser.
typedef AudioEditorBalanceChooserBuilder = Widget Function(
  AudioMainBottomBarState editorState,
  ProVideoController controller,
  ValueChanged<double> updateBalance,
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
    this.editBottomBar,
    this.buttonEditTrack,
    this.buttonConfirm,
    this.startTimeSelector,
    this.balanceChooser,
    this.startTimeDisplay,
    this.bodyItems,
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

  /// Builder for creating a custom edit sheet widget.
  ///
  /// This sheet typically contains controls for editing audio track properties
  /// like start time, balance, and track selection.
  final AudioEditorEditSheetBuilder? editBottomBar;

  /// Builder for creating a custom edit track button.
  ///
  /// This button typically opens the track selection interface.
  final AudioEditorEditTrackButtonBuilder? buttonEditTrack;

  /// Builder for creating a custom confirm button.
  ///
  /// This button typically confirms and applies the audio edits.
  final AudioEditorConfirmButtonBuilder? buttonConfirm;

  /// Builder for creating a custom start time selector widget.
  ///
  /// This widget allows users to adjust when the audio track starts playing
  /// relative to the video timeline.
  final AudioEditorStartTimeSelectorBuilder? startTimeSelector;

  /// Builder for creating a custom balance chooser widget.
  ///
  /// This widget allows users to adjust the audio balance between overlay music
  /// and original video audio:
  /// - Value of 1.0: Only overlay music (no original audio)
  /// - Value of 0.0: Balanced mix of both overlay and original audio
  /// - Value of -1.0: Only original audio (no overlay music)
  final AudioEditorBalanceChooserBuilder? balanceChooser;

  /// Builder for creating a custom start time display widget.
  ///
  /// This widget displays the current start time of the audio track in
  /// milliseconds.
  /// It receives a rebuild stream to update reactively when the start time
  /// changes.
  final ReactiveWidget Function(Stream<void> rebuildStream, int startTimeMs)?
      startTimeDisplay;

  /// {@macro customBodyItem}
  final CustomBodyItems<AudioEditorPageState>? bodyItems;

  /// Returns a copy of this object with the provided overrides.
  AudioEditorWidgets copyWith({
    AudioEditorAppBarBuilder? appBar,
    AudioEditorBottomBarBuilder? bottomBar,
    AudioEditorTrackBuilder? audioTrackItem,
    AudioEditorEditSheetBuilder? editBottomBar,
    AudioEditorEditTrackButtonBuilder? buttonEditTrack,
    AudioEditorConfirmButtonBuilder? buttonConfirm,
    AudioEditorStartTimeSelectorBuilder? startTimeSelector,
    AudioEditorBalanceChooserBuilder? balanceChooser,
    CustomBodyItems<AudioEditorPageState>? bodyItems,
  }) {
    return AudioEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      audioTrackItem: audioTrackItem ?? this.audioTrackItem,
      editBottomBar: editBottomBar ?? this.editBottomBar,
      buttonEditTrack: buttonEditTrack ?? this.buttonEditTrack,
      buttonConfirm: buttonConfirm ?? this.buttonConfirm,
      startTimeSelector: startTimeSelector ?? this.startTimeSelector,
      balanceChooser: balanceChooser ?? this.balanceChooser,
      bodyItems: bodyItems ?? this.bodyItems,
    );
  }
}
