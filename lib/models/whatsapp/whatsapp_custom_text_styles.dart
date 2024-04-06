import 'package:flutter/widgets.dart';

/// Represents custom text styles for the text editor in the `WhatsApp` design.
class WhatsAppCustomTextStyles {
  /// The unique identifier for the text style.
  final String id;

  /// The text style.
  final TextStyle style;

  /// Tooltip for the item.
  final String? tooltip;

  const WhatsAppCustomTextStyles({
    required this.id,
    required this.style,
    this.tooltip,
  });
}
