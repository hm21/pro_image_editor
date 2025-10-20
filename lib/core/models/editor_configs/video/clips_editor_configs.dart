import '../../icons/clips_editor_icons.dart';
import '../utils/base_sub_editor_configs.dart';
import '../utils/editor_safe_area.dart';

export '../../icons/clips_editor_icons.dart';

/// Configuration options for the Clips Editor feature.
class ClipsEditorConfigs implements BaseSubEditorConfigs {
  /// Creates an instance of [ClipsEditorConfigs].
  const ClipsEditorConfigs({
    this.enableGesturePop = true,
    this.safeArea = const EditorSafeArea(),
    this.icons = const ClipsEditorIcons(),
  });

  /// Icon configuration used by the Clips Editor.
  final ClipsEditorIcons icons;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;
}
