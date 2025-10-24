import '/features/clips_editor/models/video_clip.dart';
import '../../custom_widgets/clips_editor_widgets.dart';
import '../../icons/clips_editor_icons.dart';
import '../../styles/clips_editor_style.dart';
import '../utils/base_sub_editor_configs.dart';
import '../utils/editor_safe_area.dart';

export '../../custom_widgets/clips_editor_widgets.dart';
export '../../icons/clips_editor_icons.dart';
export '../../styles/clips_editor_style.dart';

/// Configuration options for the Clips Editor feature.
class ClipsEditorConfigs implements BaseSubEditorConfigs {
  /// Creates an instance of [ClipsEditorConfigs].
  const ClipsEditorConfigs({
    this.enableGesturePop = true,
    this.clips = const [],
    this.safeArea = const EditorSafeArea(),
    this.icons = const ClipsEditorIcons(),
    this.style = const ClipsEditorStyle(),
    this.widgets = const ClipsEditorWidgets(),
  });

  /// The list of video clips currently in the editor.
  final List<VideoClip> clips;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Icon configuration used by the Clips Editor.
  final ClipsEditorIcons icons;

  /// Visual styling applied to the audio editor widgets.
  final ClipsEditorStyle style;

  /// Widget builder overrides for customizing the audio editor.
  final ClipsEditorWidgets widgets;

  /// Creates a copy of this instance with the given parameters overridden.
  ClipsEditorConfigs copyWith({
    List<VideoClip>? clips,
    bool? enableGesturePop,
    EditorSafeArea? safeArea,
    ClipsEditorIcons? icons,
    ClipsEditorStyle? style,
    ClipsEditorWidgets? widgets,
  }) {
    return ClipsEditorConfigs(
      clips: clips ?? this.clips,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      safeArea: safeArea ?? this.safeArea,
      icons: icons ?? this.icons,
      style: style ?? this.style,
      widgets: widgets ?? this.widgets,
    );
  }
}
