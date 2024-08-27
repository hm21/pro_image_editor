// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Painting Editor component.
class IconsPaintingEditor {
  /// Creates an instance of [IconsPaintingEditor] with customizable icon
  /// settings.
  ///
  /// You can provide custom icons for various actions in the Painting Editor
  /// component.
  ///
  /// - [bottomNavBar]: The icon for the bottom navigation bar.
  /// - [lineWeight]: The icon for adjusting line weight.
  /// - [fill]: The icon for filling the background.
  /// - [noFill]: The icon for not filling the background.
  /// - [freeStyle]: The icon for the freehand drawing tool.
  /// - [arrow]: The icon for the arrow drawing tool.
  /// - [line]: The icon for the straight line drawing tool.
  /// - [rectangle]: The icon for the rectangle drawing tool.
  /// - [circle]: The icon for the circle drawing tool.
  /// - [dashLine]: The icon for the dashed line drawing tool.
  ///
  /// If no custom icons are provided, default icons are used for each action.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsPaintingEditor(
  ///   bottomNavBar: Icons.edit_rounded,
  ///   lineWeight: Icons.line_weight_rounded,
  ///   fill: Icons.fill, // Add the fill icon here
  ///   noFill: Icons.clear_rounded, // Add the noFill icon here
  ///   freeStyle: Icons.edit,
  ///   arrow: Icons.arrow_right_alt_outlined,
  ///   line: Icons.horizontal_rule,
  ///   rectangle: Icons.crop_free,
  ///   circle: Icons.lens_outlined,
  ///   dashLine: Icons.power_input,
  /// )
  /// ```
  const IconsPaintingEditor({
    this.moveAndZoom = Icons.pinch_outlined,
    this.changeOpacity = Icons.opacity_outlined,
    this.eraser = Icons.delete_forever_outlined,
    this.bottomNavBar = Icons.edit_outlined,
    this.lineWeight = Icons.line_weight_rounded,
    this.freeStyle = Icons.edit,
    this.arrow = Icons.arrow_right_alt_outlined,
    this.line = Icons.horizontal_rule,
    this.fill = Icons.format_color_fill,
    this.noFill = Icons.format_color_reset,
    this.rectangle = Icons.crop_free,
    this.circle = Icons.lens_outlined,
    this.dashLine = Icons.power_input,
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

  /// The icon for the eraser tool.
  final IconData eraser;

  /// Creates a copy of this `IconsPaintingEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsPaintingEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsPaintingEditor copyWith({
    IconData? moveAndZoom,
    IconData? changeOpacity,
    IconData? eraser,
    IconData? bottomNavBar,
    IconData? lineWeight,
    IconData? freeStyle,
    IconData? arrow,
    IconData? line,
    IconData? fill,
    IconData? noFill,
    IconData? rectangle,
    IconData? circle,
    IconData? dashLine,
  }) {
    return IconsPaintingEditor(
      moveAndZoom: moveAndZoom ?? this.moveAndZoom,
      changeOpacity: changeOpacity ?? this.changeOpacity,
      eraser: eraser ?? this.eraser,
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      lineWeight: lineWeight ?? this.lineWeight,
      freeStyle: freeStyle ?? this.freeStyle,
      arrow: arrow ?? this.arrow,
      line: line ?? this.line,
      fill: fill ?? this.fill,
      noFill: noFill ?? this.noFill,
      rectangle: rectangle ?? this.rectangle,
      circle: circle ?? this.circle,
      dashLine: dashLine ?? this.dashLine,
    );
  }
}
