// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../features/paint_editor/enums/paint_editor_enum.dart';

/// Represents a model for a paint-mode item, including an icon, a mode
/// identifier, and a label.
class PaintModeBottomBarItem {
  /// Creates a [PaintModeBottomBarItem] instance to define a paint mode.
  ///
  /// - [icon]: An optional icon to visually represent the paint mode.
  /// - [mode]: The identifier for the paint mode (enum value).
  /// - [label]: A descriptive label for the paint mode.
  const PaintModeBottomBarItem({
    required this.icon,
    required this.mode,
    required this.label,
  });

  /// The icon representing the paint mode.
  final IconData icon;

  /// The identifier for the paint mode.
  final PaintMode mode;

  /// A descriptive label for the paint mode.
  final String label;
}
