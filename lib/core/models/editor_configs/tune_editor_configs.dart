import '/features/tune_editor/models/tune_adjustment_item.dart';
import '../custom_widgets/tune_editor_widgets.dart';
import '../icons/tune_editor_icons.dart';
import '../styles/tune_editor_style.dart';
import 'utils/base_sub_editor_configs.dart';
import 'utils/editor_safe_area.dart';

export '../custom_widgets/tune_editor_widgets.dart';
export '../icons/tune_editor_icons.dart';
export '../styles/tune_editor_style.dart';

/// A configuration class for the Tune Editor.
///
/// This class defines various configurations such as enabling the editor,
/// showing layers, providing tune adjustment options, and defining the
/// editor's safe area.
class TuneEditorConfigs implements BaseSubEditorConfigs {
  /// Creates a [TuneEditorConfigs] instance with the specified parameters.
  const TuneEditorConfigs({
    this.enableGesturePop = true,
    this.showLayers = true,
    this.tuneAdjustmentOptions,
    this.safeArea = const EditorSafeArea(),
    this.style = const TuneEditorStyle(),
    this.icons = const TuneEditorIcons(),
    this.widgets = const TuneEditorWidgets(),
  });

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Specifies whether the layers should be visible in the editor.
  ///
  /// If `true`, layers are displayed within the tune editor interface.
  final bool showLayers;

  /// Defines the safe area configuration for the editor.
  ///
  /// This determines padding or spacing around the editor UI elements.
  final EditorSafeArea safeArea;

  /// A list of tune adjustment options available in the tune editor.
  ///
  /// These options allow users to modify aspects like brightness, contrast,
  /// or other tune adjustments.
  final List<TuneAdjustmentItem>? tuneAdjustmentOptions;

  /// Style configuration for the tune editor.
  final TuneEditorStyle style;

  /// Icons used in the tune editor.
  final TuneEditorIcons icons;

  /// Widgets associated with the tune editor.
  final TuneEditorWidgets widgets;

  /// Creates a copy of this [TuneEditorConfigs] object with the given fields
  /// replaced with new values.
  TuneEditorConfigs copyWith({
    bool? enableGesturePop,
    bool? showLayers,
    EditorSafeArea? safeArea,
    List<TuneAdjustmentItem>? tuneAdjustmentOptions,
    TuneEditorStyle? style,
    TuneEditorIcons? icons,
    TuneEditorWidgets? widgets,
  }) {
    return TuneEditorConfigs(
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      safeArea: safeArea ?? this.safeArea,
      showLayers: showLayers ?? this.showLayers,
      tuneAdjustmentOptions:
          tuneAdjustmentOptions ?? this.tuneAdjustmentOptions,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
    );
  }
}
