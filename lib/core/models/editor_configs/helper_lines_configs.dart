import '../styles/helper_line_style.dart';
import 'helper_guide_line.dart';

export '../styles/helper_line_style.dart';
export 'helper_guide_line.dart';

/// The `HelperLineConfigs` class defines the settings for displaying helper
/// lines in the image editor.
/// Helper lines are used to guide users in positioning and rotating layers.
class HelperLineConfigs {
  /// Creates an instance of the `HelperLines` class with the specified
  /// settings.
  const HelperLineConfigs({
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.showRotateLine = true,
    this.showLayerAlignLine = true,
    this.isDisabledAtZoom = false,
    this.releaseThreshold = 10.0,
    this.customGuides = const [],
    this.style = const HelperLineStyle(),
  });

  /// Specifies whether to show the vertical helper line.
  final bool showVerticalLine;

  /// Specifies whether to show the horizontal helper line.
  final bool showHorizontalLine;

  /// Specifies whether to show the rotate helper line.
  final bool showRotateLine;

  /// Specifies whether to show the layer align helper line.
  final bool showLayerAlignLine;

  /// Determines whether the helper lines are disabled when the editor is
  /// zoomed in.
  ///
  /// If set to `true`, helper lines will not be displayed when the zoom level
  /// is increased.
  /// If set to `false`, helper lines will remain visible regardless of the
  /// zoom level.
  final bool isDisabledAtZoom;

  /// Style configuration for helper lines.
  final HelperLineStyle style;

  /// App-defined snapping guide lines that participate in layer snapping.
  ///
  /// Vertical guides snap layers horizontally, horizontal guides snap layers
  /// vertically. Each guide is drawn (using
  /// [HelperLineStyle.customGuideColor]) while a layer snaps to it. Defaults to
  /// an empty list (no custom guides).
  final List<HelperGuideLine> customGuides;

  /// The minimum distance in logical pixels that a draggable element must be
  /// released from a helper line for the snapping effect to be deactivated.
  final double releaseThreshold;

  /// Creates a copy of this `HelperLineConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [HelperLineConfigs] with some properties updated while keeping the
  /// others unchanged.
  HelperLineConfigs copyWith({
    bool? showVerticalLine,
    bool? showHorizontalLine,
    bool? showRotateLine,
    bool? showLayerAlignLine,
    bool? isDisabledAtZoom,
    double? releaseThreshold,
    List<HelperGuideLine>? customGuides,
    HelperLineStyle? style,
  }) {
    return HelperLineConfigs(
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      showRotateLine: showRotateLine ?? this.showRotateLine,
      showLayerAlignLine: showLayerAlignLine ?? this.showLayerAlignLine,
      isDisabledAtZoom: isDisabledAtZoom ?? this.isDisabledAtZoom,
      releaseThreshold: releaseThreshold ?? this.releaseThreshold,
      customGuides: customGuides ?? this.customGuides,
      style: style ?? this.style,
    );
  }
}
