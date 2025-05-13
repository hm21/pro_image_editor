import 'package:flutter/widgets.dart';

import '/features/paint_editor/enums/paint_editor_enum.dart';
import '../../custom_widgets/paint_editor_widgets.dart';
import '../../icons/paint_editor_icons.dart';
import '../../styles/paint_editor_style.dart';
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
class PaintEditorConfigs extends ZoomConfigs {
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
    this.enableModeFreeStyle = true,
    this.enableModeArrow = true,
    this.enableModeLine = true,
    this.enableModeRect = true,
    this.enableModeCircle = true,
    this.enableModeDashLine = true,
    this.enableModeBlur = true,
    this.enableModePixelate = true,
    this.enableModeEraser = true,
    this.showToggleFillButton = true,
    this.showLineWidthAdjustmentButton = true,
    this.showOpacityAdjustmentButton = true,
    this.isInitiallyFilled = false,
    this.showLayers = true,
    this.enableShareZoomMatrix = true,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.enableFreeStyleHighPerformanceScaling,
    this.enableFreeStyleHighPerformanceMoving,
    this.enableFreeStyleHighPerformanceHero = false,
    this.initialPaintMode = PaintMode.freeStyle,
    this.censorConfigs = const CensorConfigs(),
    this.style = const PaintEditorStyle(),
    this.icons = const PaintEditorIcons(),
    this.widgets = const PaintEditorWidgets(),
  })  : assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale'),
        assert(editorMaxScale > editorMinScale,
            'editorMaxScale must be greater than editorMinScale');

  /// Indicates whether the paint editor is enabled.
  final bool enabled;

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

  /// Enables high-performance scaling for free-style drawing when set to
  /// `true`.
  ///
  /// When this option is enabled, it optimizes scaling for improved
  /// performance.
  ///
  /// By default, it's set to `true` on mobile devices and `false` on desktop
  /// devices.
  final bool? enableFreeStyleHighPerformanceScaling;

  /// Enables high-performance moving for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes moving for improved performance.
  ///
  /// By default, it's set to `true` only on mobile-web devices.
  final bool? enableFreeStyleHighPerformanceMoving;

  /// Enables high-performance hero-animations for free-style drawing when set
  /// to `true`.
  ///
  /// When this option is enabled, it optimizes hero-animations for improved
  /// performance.
  ///
  /// By default, it's set to `false`.
  final bool enableFreeStyleHighPerformanceHero;

  /// Indicates the initial paint mode.
  final PaintMode initialPaintMode;

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
    bool? enabled,
    bool? enableModeFreeStyle,
    bool? enableModeArrow,
    bool? enableModeLine,
    bool? enableModeRect,
    bool? enableModeCircle,
    bool? enableModeDashLine,
    bool? enableModeBlur,
    bool? enableModePixelate,
    bool? enableModeEraser,
    bool? showToggleFillButton,
    bool? showLineWidthAdjustmentButton,
    bool? showOpacityAdjustmentButton,
    bool? isInitiallyFilled,
    bool? showLayers,
    bool? enableShareZoomMatrix,
    bool? enableFreeStyleHighPerformanceScaling,
    bool? enableFreeStyleHighPerformanceMoving,
    bool? enableFreeStyleHighPerformanceHero,
    PaintMode? initialPaintMode,
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
    EdgeInsets? boundaryMargin,
    bool? enableDoubleTapZoom,
    double? doubleTapZoomFactor,
    Duration? doubleTapZoomDuration,
    Curve? doubleTapZoomCurve,
  }) {
    return PaintEditorConfigs(
      enabled: enabled ?? this.enabled,
      enableModeFreeStyle: enableModeFreeStyle ?? this.enableModeFreeStyle,
      enableModeArrow: enableModeArrow ?? this.enableModeArrow,
      enableModeLine: enableModeLine ?? this.enableModeLine,
      enableModeRect: enableModeRect ?? this.enableModeRect,
      enableModeCircle: enableModeCircle ?? this.enableModeCircle,
      enableModeDashLine: enableModeDashLine ?? this.enableModeDashLine,
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
      enableFreeStyleHighPerformanceScaling:
          enableFreeStyleHighPerformanceScaling ??
              this.enableFreeStyleHighPerformanceScaling,
      enableFreeStyleHighPerformanceMoving:
          enableFreeStyleHighPerformanceMoving ??
              this.enableFreeStyleHighPerformanceMoving,
      enableFreeStyleHighPerformanceHero: enableFreeStyleHighPerformanceHero ??
          this.enableFreeStyleHighPerformanceHero,
      initialPaintMode: initialPaintMode ?? this.initialPaintMode,
      censorConfigs: censorConfigs ?? this.censorConfigs,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      enableZoom: enableZoom ?? this.enableZoom,
      editorMinScale: editorMinScale ?? this.editorMinScale,
      editorMaxScale: editorMaxScale ?? this.editorMaxScale,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      doubleTapZoomFactor: doubleTapZoomFactor ?? this.doubleTapZoomFactor,
      doubleTapZoomDuration:
          doubleTapZoomDuration ?? this.doubleTapZoomDuration,
      doubleTapZoomCurve: doubleTapZoomCurve ?? this.doubleTapZoomCurve,
      boundaryMargin: boundaryMargin ?? this.boundaryMargin,
    );
  }
}
