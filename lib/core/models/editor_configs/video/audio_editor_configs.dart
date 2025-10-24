import '/features/audio_editor/models/audio_track.dart';
import '../../custom_widgets/audio_editor_widgets.dart';
import '../../icons/audio_editor_icons.dart';
import '../../styles/audio_editor_style.dart';
import '../utils/base_sub_editor_configs.dart';
import '../utils/editor_safe_area.dart';

export '/features/audio_editor/models/audio_track.dart';
export '../../custom_widgets/audio_editor_widgets.dart';
export '../../icons/audio_editor_icons.dart';
export '../../styles/audio_editor_style.dart';

/// Configuration options for the Audio Editor feature.
class AudioEditorConfigs implements BaseSubEditorConfigs {
  /// Creates an instance of [AudioEditorConfigs].
  const AudioEditorConfigs({
    this.enableGesturePop = true,
    this.enableEditBalance = true,
    this.enableEditStartTime = true,
    this.audioTracks = const [],
    this.safeArea = const EditorSafeArea(),
    this.icons = const AudioEditorIcons(),
    this.style = const AudioEditorStyle(),
    this.widgets = const AudioEditorWidgets(),
  });

  /// Tracks that should be displayed within the audio editor.
  final List<AudioTrack> audioTracks;

  /// Enables the balance editing feature.
  final bool enableEditBalance;

  /// Enables the start time editing feature.
  final bool enableEditStartTime;

  /// Icon configuration used by the Audio Editor.
  final AudioEditorIcons icons;

  /// Visual styling applied to the audio editor widgets.
  final AudioEditorStyle style;

  /// Widget builder overrides for customizing the audio editor.
  final AudioEditorWidgets widgets;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Creates a copy of this instance with the given parameters overridden.
  AudioEditorConfigs copyWith({
    List<AudioTrack>? audioTracks,
    bool? enableEditBalance,
    bool? enableEditStartTime,
    AudioEditorIcons? icons,
    AudioEditorStyle? style,
    AudioEditorWidgets? widgets,
    bool? enableGesturePop,
    EditorSafeArea? safeArea,
  }) {
    return AudioEditorConfigs(
      audioTracks: audioTracks ?? this.audioTracks,
      enableEditBalance: enableEditBalance ?? this.enableEditBalance,
      enableEditStartTime: enableEditStartTime ?? this.enableEditStartTime,
      icons: icons ?? this.icons,
      style: style ?? this.style,
      widgets: widgets ?? this.widgets,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      safeArea: safeArea ?? this.safeArea,
    );
  }
}
