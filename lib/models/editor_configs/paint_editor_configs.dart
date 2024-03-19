import 'dart:ui';

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
  /// Indicates whether the paint editor is enabled.
  final bool enabled;

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

  /// Indicating whether the color picker is visible.
  final bool showColorPicker;

  /// Indicating whether the fill option can be toggled.
  final bool canToggleFill;

  /// Indicating whether the line width can be changed.
  final bool canChangeLineWidth;

  /// Indicates the initial fill state.
  final bool initialFill;

  /// Enables high-performance scaling for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes scaling for improved performance.
  /// By default, it's set to `true` on mobile devices and `false` on desktop devices.
  final bool? freeStyleHighPerformanceScaling;

  /// Enables high-performance moving for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes moving for improved performance.
  /// By default, it's set to `true` only on mobile-web devices.
  final bool? freeStyleHighPerformanceMoving;

  /// Indicates the initial stroke width.
  final double initialStrokeWidth;

  /// Indicates the initial drawing color.
  final Color initialColor;

  /// Indicates the initial paint mode.
  final PaintModeE initialPaintMode;

  /// A callback function that will be called when the stroke width on changed.
  final Function(double x)? strokeWidthOnChanged;

  /// Creates an instance of PaintEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and most drawing tools are enabled.
  /// Other properties are set to reasonable defaults.
  const PaintEditorConfigs({
    this.enabled = true,
    this.hasOptionFreeStyle = true,
    this.hasOptionArrow = true,
    this.hasOptionLine = true,
    this.hasOptionRect = true,
    this.hasOptionCircle = true,
    this.hasOptionDashLine = true,
    this.canToggleFill = true,
    this.canChangeLineWidth = true,
    this.initialFill = false,
    this.showColorPicker = true,
    this.freeStyleHighPerformanceScaling,
    this.freeStyleHighPerformanceMoving,
    this.initialStrokeWidth = 10.0,
    this.initialColor = const Color(0xffff0000),
    this.initialPaintMode = PaintModeE.freeStyle,
    this.strokeWidthOnChanged,
  });
}
