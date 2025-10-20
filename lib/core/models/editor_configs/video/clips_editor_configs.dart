import '/features/clips_editor/models/video_clip.dart';
import '../../custom_widgets/clips_editor_widgets.dart';
import '../../icons/clips_editor_icons.dart';
import '../../styles/clips_editor_style.dart';
import '../utils/base_sub_editor_configs.dart';
import '../utils/editor_safe_area.dart';

export '../../icons/clips_editor_icons.dart';

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
}
