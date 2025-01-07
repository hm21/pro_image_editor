// Flutter imports:
import 'package:flutter/material.dart';

/// Represents the button style for WhatsApp-themed buttons.
///
/// This [ButtonStyle] defines the visual appearance of buttons in a
/// WhatsApp-themed style. It includes properties such as background color,
/// padding, icon size, minimum size, and tap target size.
final ButtonStyle whatsAppButtonStyle = IconButton.styleFrom(
  backgroundColor: Colors.black38,
  padding: const EdgeInsets.all(8),
  iconSize: 22,
  minimumSize: const Size.fromRadius(10),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);
