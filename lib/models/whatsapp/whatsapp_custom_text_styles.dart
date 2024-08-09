// Flutter imports:
import 'package:flutter/widgets.dart';

/// Represents custom text styles for the text editor in the `WhatsApp` design.
class WhatsAppCustomTextStyles {
  /// Class representing custom text styles for WhatsApp with optional tooltip.
  const WhatsAppCustomTextStyles({
    required this.id,
    required this.style,
    this.tooltip,
  });

  /// The unique identifier for the text style.
  final String id;

  /// The text style.
  final TextStyle style;

  /// Tooltip for the item.
  final String? tooltip;
}
