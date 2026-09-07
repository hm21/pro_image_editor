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
    this.enableEdgeSnapping = true,
    this.enableSmartAlignment = false,
    this.enablePaintLayerSnapping = true,
    this.smartAlignmentNeighborLimit = 3,
    this.smartAlignmentSharedAxisMin = 2,
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

  /// When `true`, text and paint layers also snap on their visible edges
  /// (left/center/right and top/center/bottom). When `false`, every layer
  /// snaps from its center only.
  final bool enableEdgeSnapping;

  /// Softens layer-to-layer snapping on a dense canvas (many text labels).
  ///
  /// When `false` (the default), every edge of every layer can snap to every
  /// other edge — the original behavior, which becomes sticky on a page of
  /// labels.
  ///
  /// When `true`:
  /// * Same layer type (text↔text, paint↔paint) snaps matching edges
  ///   (left↔left, center↔center, right↔right).
  /// * Different types (text↔sticker) snap center↔center only.
  /// * Only nearby layers ([smartAlignmentNeighborLimit]) plus axes already
  ///   shared by [smartAlignmentSharedAxisMin] or more layers participate, so a
  ///   lone label across the sheet is not a magnet. Shared **center** axes
  ///   count across layer types (a token and a label on the same X); edges
  ///   stay type-specific.
  /// * Canvas center lines snap the layer center only, not every edge.
  /// * Snapping is applied on top of the pointer's intended position. Release
  ///   is measured from that intended position so both axes can catch without
  ///   trapping the layer on the snapped coordinates.
  ///
  /// Custom guides are unchanged. Combine with [enableEdgeSnapping] to recover
  /// flush-start columns without the magnet field.
  final bool enableSmartAlignment;

  /// When `false`, paint layers do not snap while dragging (canvas midlines,
  /// custom guides, and layer-align) and do not act as layer-align targets
  /// for other layers. Text edges and sticker centers are unchanged. Defaults
  /// to `true` so existing apps keep paint-to-paint alignment.
  final bool enablePaintLayerSnapping;

  /// How many of the closest layers participate as snap targets while
  /// [enableSmartAlignment] is on.
  ///
  /// Lower values calm a dense canvas further; higher values bring back more of
  /// the original magnet field. Ignored when [enableSmartAlignment] is `false`.
  final int smartAlignmentNeighborLimit;

  /// How many layers must already share an axis for that axis to stay a global
  /// snap target while [enableSmartAlignment] is on.
  ///
  /// A shared axis snaps to the real edge closest to the cluster, so the guide
  /// always overlays an actual layer edge. Ignored when [enableSmartAlignment]
  /// is `false`.
  final int smartAlignmentSharedAxisMin;

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
    bool? enableEdgeSnapping,
    bool? enableSmartAlignment,
    bool? enablePaintLayerSnapping,
    int? smartAlignmentNeighborLimit,
    int? smartAlignmentSharedAxisMin,
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
      enableEdgeSnapping: enableEdgeSnapping ?? this.enableEdgeSnapping,
      enableSmartAlignment: enableSmartAlignment ?? this.enableSmartAlignment,
      enablePaintLayerSnapping:
          enablePaintLayerSnapping ?? this.enablePaintLayerSnapping,
      smartAlignmentNeighborLimit:
          smartAlignmentNeighborLimit ?? this.smartAlignmentNeighborLimit,
      smartAlignmentSharedAxisMin:
          smartAlignmentSharedAxisMin ?? this.smartAlignmentSharedAxisMin,
      releaseThreshold: releaseThreshold ?? this.releaseThreshold,
      customGuides: customGuides ?? this.customGuides,
      style: style ?? this.style,
    );
  }
}
