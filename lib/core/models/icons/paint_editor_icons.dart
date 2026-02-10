// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Paint Editor component.
class PaintEditorIcons {
  /// Creates an instance of [PaintEditorIcons] with customizable icon settings.
  ///
  /// You can provide custom icons for various actions in the Paint Editor
  /// component.
  const PaintEditorIcons({
    this.moveAndZoom = Icons.pinch_outlined,
    this.changeOpacity = Icons.opacity_outlined,
    this.eraser = Icons.delete_forever_outlined,
    this.bottomNavBar = Icons.edit_outlined,
    this.lineWeight = Icons.line_weight_rounded,
    this.freeStyle = Icons.edit,
    this.freeStyleArrowStart = Icons.edit,
    this.freeStyleArrowEnd = Icons.edit,
    this.freeStyleArrowStartEnd = Icons.edit,
    this.arrow = Icons.arrow_right_alt_outlined,
    this.line = Icons.horizontal_rule,
    this.fill = Icons.format_color_fill,
    this.noFill = Icons.format_color_reset,
    this.rectangle = Icons.crop_free,
    this.circle = Icons.lens_outlined,
    this.dashLine = Icons.power_input,
    this.dashDotLine = Icons.linear_scale,
    this.hexagon = Icons.hexagon_outlined,
    this.polygon = Icons.pentagon_outlined,
    this.pixelate = Icons.grid_on,
    this.blur = Icons.blur_on_rounded,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.undoAction = Icons.undo,
    this.redoAction = Icons.redo,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for adjusting line weight.
  final IconData lineWeight;

  /// The icon used for moving and zooming within the editor.
  ///
  /// This icon appears in the editor bottombar.
  ///
  /// When in the [PaintEditorConfigs] the config [enableZoom] is set to
  /// `true`, this icon will be displayed, allowing users to interact with the
  /// editor's zoom and move features. If [enableZoom] is set to `false`,
  /// the icon will be hidden.
  final IconData moveAndZoom;

  /// The icon representing a filled background.
  final IconData fill;

  /// The icon representing to change the opacity.
  final IconData changeOpacity;

  /// The icon representing an unfilled (transparent) background.
  final IconData noFill;

  /// The icon for the freehand drawing tool.
  final IconData freeStyle;

  /// The icon for the freehand drawing tool with an arrow at the start point.
  final IconData freeStyleArrowStart;

  /// The icon for the freehand drawing tool with an arrow at the end point.
  final IconData freeStyleArrowEnd;

  /// The icon for the freehand drawing tool with arrows at both start and end
  /// points.
  final IconData freeStyleArrowStartEnd;

  /// The icon for the arrow drawing tool.
  final IconData arrow;

  /// The icon for the straight line drawing tool.
  final IconData line;

  /// The icon for the rectangle drawing tool.
  final IconData rectangle;

  /// The icon for the circle drawing tool.
  final IconData circle;

  /// The icon for the dashed line drawing tool.
  final IconData dashLine;

  /// The icon for the dash-dot line drawing tool.
  final IconData dashDotLine;

  /// The icon for the hexagon drawing tool.
  final IconData hexagon;

  /// The icon for the polygon drawing tool.
  final IconData polygon;

  /// The icon for the blur drawing tool.
  final IconData blur;

  /// The icon for the pixelate drawing tool.
  final IconData pixelate;

  /// The icon for the eraser tool.
  final IconData eraser;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// The icon for undoing the last action.
  final IconData undoAction;

  /// The icon for redoing the last undone action.
  final IconData redoAction;

  /// Creates a copy of this [PaintEditorIcons] with updated values.
  PaintEditorIcons copyWith({
    IconData? bottomNavBar,
    IconData? lineWeight,
    IconData? moveAndZoom,
    IconData? fill,
    IconData? changeOpacity,
    IconData? noFill,
    IconData? freeStyle,
    IconData? freeStyleArrowStart,
    IconData? freeStyleArrowEnd,
    IconData? freeStyleArrowStartEnd,
    IconData? arrow,
    IconData? line,
    IconData? rectangle,
    IconData? circle,
    IconData? dashLine,
    IconData? dashDotLine,
    IconData? hexagon,
    IconData? polygon,
    IconData? blur,
    IconData? pixelate,
    IconData? eraser,
    IconData? backButton,
    IconData? applyChanges,
    IconData? undoAction,
    IconData? redoAction,
  }) {
    return PaintEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      lineWeight: lineWeight ?? this.lineWeight,
      moveAndZoom: moveAndZoom ?? this.moveAndZoom,
      fill: fill ?? this.fill,
      changeOpacity: changeOpacity ?? this.changeOpacity,
      noFill: noFill ?? this.noFill,
      freeStyle: freeStyle ?? this.freeStyle,
      freeStyleArrowStart: freeStyleArrowStart ?? this.freeStyleArrowStart,
      freeStyleArrowEnd: freeStyleArrowEnd ?? this.freeStyleArrowEnd,
      freeStyleArrowStartEnd:
          freeStyleArrowStartEnd ?? this.freeStyleArrowStartEnd,
      arrow: arrow ?? this.arrow,
      line: line ?? this.line,
      rectangle: rectangle ?? this.rectangle,
      circle: circle ?? this.circle,
      dashLine: dashLine ?? this.dashLine,
      dashDotLine: dashDotLine ?? this.dashDotLine,
      hexagon: hexagon ?? this.hexagon,
      polygon: polygon ?? this.polygon,
      blur: blur ?? this.blur,
      pixelate: pixelate ?? this.pixelate,
      eraser: eraser ?? this.eraser,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
      undoAction: undoAction ?? this.undoAction,
      redoAction: redoAction ?? this.redoAction,
    );
  }
}
