// Project imports:
import '../../modules/paint_editor/utils/paint_editor_enum.dart';

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
///   hasOptionFreeStyle: true,
///   hasOptionArrow: true,
///   hasOptionLine: true,
///   hasOptionRect: true,
///   hasOptionCircle: true,
///   hasOptionDashLine: true,
///   canToggleFill: true,
///   canChangeLineWidth: true,
///   initialFill: false,
///   showColorPicker: true,
///   initialStrokeWidth: 10.0,
///   initialColor: const Color(0xffff0000),
///   initialPaintMode: PaintModeE.freeStyle,
/// );
/// ```
class PaintEditorConfigs {
  /// Creates an instance of PaintEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and most drawing tools are enabled.
  /// Other properties are set to reasonable defaults.
  const PaintEditorConfigs({
    this.enabled = true,
    this.enableZoom = false,
    this.editorMinScale = 1.0,
    this.editorMaxScale = 5.0,
    this.hasOptionFreeStyle = true,
    this.hasOptionArrow = true,
    this.hasOptionLine = true,
    this.hasOptionRect = true,
    this.hasOptionCircle = true,
    this.hasOptionDashLine = true,
    this.hasOptionEraser = true,
    this.canToggleFill = true,
    this.canChangeLineWidth = true,
    this.canChangeOpacity = true,
    this.initialFill = false,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.freeStyleHighPerformanceScaling,
    this.freeStyleHighPerformanceMoving,
    this.freeStyleHighPerformanceHero = false,
    this.initialPaintMode = PaintModeE.freeStyle,
  })  : assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale'),
        assert(editorMaxScale > editorMinScale,
            'editorMaxScale must be greater than editorMinScale');

  /// Indicates whether the paint editor is enabled.
  final bool enabled;

  /// Indicates whether the editor supports zoom functionality.
  ///
  /// When set to `true`, the editor allows users to zoom in and out, providing
  /// enhanced accessibility and usability, especially on smaller screens or for
  /// users with visual impairments. If set to `false`, the zoom functionality
  /// is disabled, and the editor's content remains at a fixed scale.
  ///
  /// Default value is `false`.
  final bool enableZoom;

  /// Indicating whether the free-style drawing option is available.
  final bool hasOptionFreeStyle;

  /// Indicating whether the arrow drawing option is available.
  final bool hasOptionArrow;

  /// Indicating whether the line drawing option is available.
  final bool hasOptionLine;

  /// Indicating whether the rectangle drawing option is available.
  final bool hasOptionRect;

  /// Indicating whether the circle drawing option is available.
  final bool hasOptionCircle;

  /// Indicating whether the dash line drawing option is available.
  final bool hasOptionDashLine;

  /// Indicating whether the eraser option is available.
  final bool hasOptionEraser;

  /// Indicating whether the fill option can be toggled.
  final bool canToggleFill;

  /// Indicating whether the line width can be changed.
  final bool canChangeLineWidth;

  /// Indicating whether the opacity can be changed.
  final bool canChangeOpacity;

  /// Indicates the initial fill state.
  final bool initialFill;

  /// Enables high-performance scaling for free-style drawing when set to
  /// `true`.
  ///
  /// When this option is enabled, it optimizes scaling for improved
  /// performance.
  ///
  /// By default, it's set to `true` on mobile devices and `false` on desktop
  /// devices.
  final bool? freeStyleHighPerformanceScaling;

  /// Enables high-performance moving for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes moving for improved performance.
  ///
  /// By default, it's set to `true` only on mobile-web devices.
  final bool? freeStyleHighPerformanceMoving;

  /// Enables high-performance hero-animations for free-style drawing when set
  /// to `true`.
  ///
  /// When this option is enabled, it optimizes hero-animations for improved
  /// performance.
  ///
  /// By default, it's set to `false`.
  final bool freeStyleHighPerformanceHero;

  /// Indicates the initial paint mode.
  final PaintModeE initialPaintMode;

  /// The minimum scale factor for the editor.
  ///
  /// This value determines the lowest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 1.0.
  final double editorMinScale;

  /// The maximum scale factor for the editor.
  ///
  /// This value determines the highest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 5.0.
  final double editorMaxScale;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Creates a copy of this `PaintEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [PaintEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  PaintEditorConfigs copyWith({
    bool? enabled,
    bool? enableZoom,
    bool? hasOptionFreeStyle,
    bool? hasOptionArrow,
    bool? hasOptionLine,
    bool? hasOptionRect,
    bool? hasOptionCircle,
    bool? hasOptionDashLine,
    bool? hasOptionEraser,
    bool? canToggleFill,
    bool? canChangeLineWidth,
    bool? canChangeOpacity,
    bool? initialFill,
    bool? freeStyleHighPerformanceScaling,
    bool? freeStyleHighPerformanceMoving,
    bool? freeStyleHighPerformanceHero,
    PaintModeE? initialPaintMode,
    double? editorMinScale,
    double? editorMaxScale,
    double? minScale,
    double? maxScale,
  }) {
    return PaintEditorConfigs(
      enabled: enabled ?? this.enabled,
      enableZoom: enableZoom ?? this.enableZoom,
      hasOptionFreeStyle: hasOptionFreeStyle ?? this.hasOptionFreeStyle,
      hasOptionArrow: hasOptionArrow ?? this.hasOptionArrow,
      hasOptionLine: hasOptionLine ?? this.hasOptionLine,
      hasOptionRect: hasOptionRect ?? this.hasOptionRect,
      hasOptionCircle: hasOptionCircle ?? this.hasOptionCircle,
      hasOptionDashLine: hasOptionDashLine ?? this.hasOptionDashLine,
      hasOptionEraser: hasOptionEraser ?? this.hasOptionEraser,
      canToggleFill: canToggleFill ?? this.canToggleFill,
      canChangeLineWidth: canChangeLineWidth ?? this.canChangeLineWidth,
      canChangeOpacity: canChangeOpacity ?? this.canChangeOpacity,
      initialFill: initialFill ?? this.initialFill,
      freeStyleHighPerformanceScaling: freeStyleHighPerformanceScaling ??
          this.freeStyleHighPerformanceScaling,
      freeStyleHighPerformanceMoving:
          freeStyleHighPerformanceMoving ?? this.freeStyleHighPerformanceMoving,
      freeStyleHighPerformanceHero:
          freeStyleHighPerformanceHero ?? this.freeStyleHighPerformanceHero,
      initialPaintMode: initialPaintMode ?? this.initialPaintMode,
      editorMinScale: editorMinScale ?? this.editorMinScale,
      editorMaxScale: editorMaxScale ?? this.editorMaxScale,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
    );
  }
}
