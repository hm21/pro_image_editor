// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../modules/paint_editor/utils/paint_editor_enum.dart';

/// Represents a model for a painting mode, including an icon, a mode
/// identifier, and a label.
class PaintModeBottomBarItem {
  /// Creates a [PaintModeBottomBarItem] instance to define a painting mode.
  ///
  /// - [icon]: An optional icon to visually represent the painting mode.
  /// - [mode]: The identifier for the painting mode (enum value).
  /// - [label]: A descriptive label for the painting mode.
  const PaintModeBottomBarItem({
    required this.icon,
    required this.mode,
    required this.label,
  });

  /// The icon representing the painting mode.
  final IconData icon;

  /// The identifier for the painting mode.
  final PaintModeE mode;

  /// A descriptive label for the painting mode.
  final String label;
}
