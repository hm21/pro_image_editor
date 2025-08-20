import 'package:flutter/widgets.dart';

import '/features/paint_editor/enums/paint_editor_enum.dart';
import '../../custom_widgets/paint_editor_widgets.dart';
import '../../icons/paint_editor_icons.dart';
import '../../styles/paint_editor_style.dart';
import '../utils/base_editor_layer_configs.dart';
import '../utils/editor_safe_area.dart';
import '../utils/zoom_configs.dart';
import 'censor_configs.dart';

export '../../custom_widgets/paint_editor_widgets.dart';
export '../../icons/paint_editor_icons.dart';
export '../../styles/paint_editor_style.dart';
export 'censor_configs.dart';

/// Configuration options for a paint editor.
///
/// `PaintEditorConfigs` allows you to define settings for a paint editor,
/// including whether the editor is enabled, which drawing tools are available,
/// initial settings for drawing, and more.
///
/// Example usage:
/// ```dart
/// PaintEditorConfigs(
///   enabled: true,
///   enableModeFreeStyle = true,
///   enableModeArrow = true,
///   enableModeLine = true,
///   enableModeRect = true,
///   enableModeCircle = true,
///   enableModeDashLine = true,
///   enableModeBlur = true,
///   enableModePixelate = true,
///   enableModeEraser = true,
///   isInitiallyFilled: false,
///   initialPaintMode: PaintMode.freeStyle,
/// );
/// ```
class PaintEditorConfigs extends ZoomConfigs implements BaseEditorLayerConfigs {
  /// Creates an instance of PaintEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and most drawing tools are enabled.
  /// Other properties are set to reasonable defaults.
  const PaintEditorConfigs({
    this.enabled = true,
    super.enableZoom,
    super.editorMinScale,
    super.editorMaxScale,
    super.enableDoubleTapZoom,
    super.doubleTapZoomFactor,
    super.doubleTapZoomDuration,
    super.doubleTapZoomCurve,
    super.boundaryMargin,
    super.invertTrackpadDirection,
    this.layerFractionalOffset = const Offset(-0.5, -0.5),
    this.enableEdit = true,
    this.enableModeFreeStyle = true,
    this.enableModeArrow = true,
    this.enableModeLine = true,
    this.enableModeRect = true,
    this.enableModeCircle = true,
    this.enableModeDashLine = true,
    this.enableModePolygon = true,
    this.enableModeBlur = true,
    this.enableModePixelate = true,
    this.enableModeEraser = true,
    this.showToggleFillButton = true,
    this.showLineWidthAdjustmentButton = true,
    this.showOpacityAdjustmentButton = true,
    this.isInitiallyFilled = false,
    this.showLayers = true,
    this.enableShareZoomMatrix = true,
    this.polygonConnectionThreshold = 20,
    this.minStrokeWidth = 1.0,
    this.maxStrokeWidth = 40.0,
    this.divisionsStrokeWidth = 39,
    this.minOpacity = 0.0,
    this.maxOpacity = 1.0,
    this.divisionsOpacity = 100,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.initialPaintMode = PaintMode.freeStyle,
    this.eraserMode = EraserMode.partial,
    this.eraserSize = 8.0,
    this.censorConfigs = const CensorConfigs(),
    this.safeArea = const EditorSafeArea(),
    this.style = const PaintEditorStyle(),
    this.icons = const PaintEditorIcons(),
    this.widgets = const PaintEditorWidgets(),
  })  : assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale'),
        assert(editorMaxScale > editorMinScale,
            'editorMaxScale must be greater than editorMinScale'),
        assert(editorMinScale >= 0,
            'editorMinScale must be greater than or equal to 0'),
        assert(maxOpacity >= minOpacity,
            'maxOpacity must be greater than or equal to minOpacity'),
        assert(minOpacity >= 0 && minOpacity <= 1,
            'minOpacity must be between 0 and 1'),
        assert(maxOpacity <= 1, 'maxOpacity must be less than or equal to 1'),
        assert(maxStrokeWidth >= minStrokeWidth,
            'maxStrokeWidth must be greater than or equal to minStrokeWidth'),
        assert(minStrokeWidth >= 0,
            'minStrokeWidth must be greater than or equal to 0');

  /// {@macro layerFractionalOffset}
  @override
  final Offset layerFractionalOffset;

  /// Indicates whether the paint editor is enabled.
  final bool enabled;

  /// Indicating whether created layers can be edited.
  final bool enableEdit;

  /// Indicating whether the free-style drawing option is enabled.
  final bool enableModeFreeStyle;

  /// Indicating whether the arrow drawing option is enabled.
  final bool enableModeArrow;

  /// Indicating whether the line drawing option is enabled.
  final bool enableModeLine;

  /// Indicating whether the rectangle drawing option is enabled.
  final bool enableModeRect;

  /// Indicating whether the circle drawing option is enabled.
  final bool enableModeCircle;

  /// Indicating whether the dash line drawing option is enabled.
  final bool enableModeDashLine;

  /// Indicating whether the polygon drawing option is enabled.
  final bool enableModePolygon;

  /// Indicating whether the blur drawing option is enabled.
  final bool enableModeBlur;

  /// Indicating whether the pixelate drawing option is enabled.
  ///
  /// **IMPORTANT**: This mode is only supported when using the Impeller
  /// rendering engine. On all other platforms, it will automatically be
  /// set to `false`.
  final bool enableModePixelate;

  /// Indicating whether the eraser option is enabled.
  final bool enableModeEraser;

  /// Whether to show a button for toggle the fill state.
  final bool showToggleFillButton;

  /// Whether to show a button for adjusting the line width.
  final bool showLineWidthAdjustmentButton;

  /// Whether to show a button for adjusting the opacity.
  final bool showOpacityAdjustmentButton;

  /// Indicates the initial fill state.
  final bool isInitiallyFilled;

  /// Show the layers from the main-editor.
  final bool showLayers;

  /// Shares the zoom matrix between the main and paint editor.
  final bool enableShareZoomMatrix;

  /// Indicates the initial paint mode.
  final PaintMode initialPaintMode;

  /// Indicates the eraser mode.
  final EraserMode eraserMode;

  /// The size of the eraser tool in pixels.
  ///
  /// This value determines the diameter/width of the eraser when removing
  /// painted content from the canvas. A larger value creates a bigger eraser
  /// that removes more content at once, while a smaller value provides more
  /// precise erasing capabilities.
  final double eraserSize;

  /// Configuration settings for the censor tool in the paint editor.
  ///
  /// This property holds an instance of [CensorConfigs] which contains
  /// various settings and options for the censoring functionality within
  /// the paint editor.
  final CensorConfigs censorConfigs;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Minimum stroke width selectable by the user.
  final double minStrokeWidth;

  /// Maximum stroke width selectable by the user.
  final double maxStrokeWidth;

  /// Number of divisions for the stroke width slider.
  final int divisionsStrokeWidth;

  /// Minimum opacity value (0.0 = fully transparent).
  final double minOpacity;

  /// Maximum opacity value (1.0 = fully opaque).
  final double maxOpacity;

  /// Number of divisions for the opacity slider.
  final int divisionsOpacity;

  /// The maximum distance between the first and last point to be auto
  /// connected when drawing polygons.
  final double polygonConnectionThreshold;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Style configuration for the paint editor.
  final PaintEditorStyle style;

  /// Icons used in the paint editor.
  final PaintEditorIcons icons;

  /// Widgets associated with the paint editor.
  final PaintEditorWidgets widgets;

  /// Creates a copy of this `PaintEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [PaintEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  PaintEditorConfigs copyWith({
    Offset? layerFractionalOffset,
    bool? enabled,
    bool? enableEdit,
    bool? enableModeFreeStyle,
    bool? enableModeArrow,
    bool? enableModeLine,
    bool? enableModeRect,
    bool? enableModeCircle,
    bool? enableModeDashLine,
    bool? enableModePolygon,
    bool? enableModeBlur,
    bool? enableModePixelate,
    bool? enableModeEraser,
    bool? showToggleFillButton,
    bool? showLineWidthAdjustmentButton,
    bool? showOpacityAdjustmentButton,
    bool? isInitiallyFilled,
    bool? showLayers,
    bool? enableShareZoomMatrix,
    PaintMode? initialPaintMode,
    EraserMode? eraserMode,
    double? eraserSize,
    CensorConfigs? censorConfigs,
    double? minScale,
    double? maxScale,
    EditorSafeArea? safeArea,
    PaintEditorStyle? style,
    PaintEditorIcons? icons,
    PaintEditorWidgets? widgets,
    bool? enableZoom,
    double? editorMinScale,
    double? editorMaxScale,
    double? polygonConnectionThreshold,
    EdgeInsets? boundaryMargin,
    bool? enableDoubleTapZoom,
    bool? invertTrackpadDirection,
    double? doubleTapZoomFactor,
    Duration? doubleTapZoomDuration,
    Curve? doubleTapZoomCurve,
    double? minStrokeWidth,
    double? maxStrokeWidth,
    int? divisionsStrokeWidth,
    double? minOpacity,
    double? maxOpacity,
    int? divisionsOpacity,
  }) {
    return PaintEditorConfigs(
      layerFractionalOffset:
          layerFractionalOffset ?? this.layerFractionalOffset,
      enabled: enabled ?? this.enabled,
      enableEdit: enableEdit ?? this.enableEdit,
      enableModeFreeStyle: enableModeFreeStyle ?? this.enableModeFreeStyle,
      enableModeArrow: enableModeArrow ?? this.enableModeArrow,
      enableModeLine: enableModeLine ?? this.enableModeLine,
      enableModeRect: enableModeRect ?? this.enableModeRect,
      enableModeCircle: enableModeCircle ?? this.enableModeCircle,
      enableModeDashLine: enableModeDashLine ?? this.enableModeDashLine,
      enableModePolygon: enableModePolygon ?? this.enableModePolygon,
      enableModeBlur: enableModeBlur ?? this.enableModeBlur,
      enableModePixelate: enableModePixelate ?? this.enableModePixelate,
      enableModeEraser: enableModeEraser ?? this.enableModeEraser,
      showToggleFillButton: showToggleFillButton ?? this.showToggleFillButton,
      showLineWidthAdjustmentButton:
          showLineWidthAdjustmentButton ?? this.showLineWidthAdjustmentButton,
      showOpacityAdjustmentButton:
          showOpacityAdjustmentButton ?? this.showOpacityAdjustmentButton,
      isInitiallyFilled: isInitiallyFilled ?? this.isInitiallyFilled,
      showLayers: showLayers ?? this.showLayers,
      enableShareZoomMatrix:
          enableShareZoomMatrix ?? this.enableShareZoomMatrix,
      initialPaintMode: initialPaintMode ?? this.initialPaintMode,
      eraserMode: eraserMode ?? this.eraserMode,
      eraserSize: eraserSize ?? this.eraserSize,
      censorConfigs: censorConfigs ?? this.censorConfigs,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      safeArea: safeArea ?? this.safeArea,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      enableZoom: enableZoom ?? this.enableZoom,
      editorMinScale: editorMinScale ?? this.editorMinScale,
      editorMaxScale: editorMaxScale ?? this.editorMaxScale,
      polygonConnectionThreshold:
          polygonConnectionThreshold ?? this.polygonConnectionThreshold,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      invertTrackpadDirection:
          invertTrackpadDirection ?? this.invertTrackpadDirection,
      doubleTapZoomFactor: doubleTapZoomFactor ?? this.doubleTapZoomFactor,
      doubleTapZoomDuration:
          doubleTapZoomDuration ?? this.doubleTapZoomDuration,
      doubleTapZoomCurve: doubleTapZoomCurve ?? this.doubleTapZoomCurve,
      boundaryMargin: boundaryMargin ?? this.boundaryMargin,
      minStrokeWidth: minStrokeWidth ?? this.minStrokeWidth,
      maxStrokeWidth: maxStrokeWidth ?? this.maxStrokeWidth,
      divisionsStrokeWidth: divisionsStrokeWidth ?? this.divisionsStrokeWidth,
      minOpacity: minOpacity ?? this.minOpacity,
      maxOpacity: maxOpacity ?? this.maxOpacity,
      divisionsOpacity: divisionsOpacity ?? this.divisionsOpacity,
    );
  }
}
