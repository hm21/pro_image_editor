import 'package:flutter/material.dart';

import '../../utils/pro_image_editor_icons.dart';

/// Customizable icons for the Painting Editor component.
class IconsPaintingEditor {
  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for adjusting line weight.
  final IconData lineWeight;

  /// The icon representing a filled background.
  final IconData fill;

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

  /// The icon for the thin stroke width when the theme is set to `Whatsapp`.
  final IconData whatsAppStrokeWidthThin;

  /// The icon for the medium stroke width when the theme is set to `Whatsapp`.
  final IconData whatsAppStrokeWidthMedium;

  /// The icon for the bold stroke width when the theme is set to `Whatsapp`.
  final IconData whatsAppStrokeWidthBold;

  /// Creates an instance of [IconsPaintingEditor] with customizable icon settings.
  ///
  /// You can provide custom icons for various actions in the Painting Editor component.
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
    this.whatsAppStrokeWidthThin = ProImageEditorIcons.penSize1,
    this.whatsAppStrokeWidthMedium = ProImageEditorIcons.penSize2,
    this.whatsAppStrokeWidthBold = ProImageEditorIcons.penSize3,
  });
}
