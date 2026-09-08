import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/src/emoji_picker.dart';

/// A wrapper around a grid or list of emojis.
/// If the button style is Cupertino or None, this is just wrapping the
/// `child` with a container of a provided color.
/// For Material style it is a `Material` widget that allows to render
/// touch response for individual InkWell cells.
class EmojiContainer extends StatelessWidget {
  /// Constructor
  const EmojiContainer({
    super.key,
    required this.color,
    required this.buttonMode,
    this.padding,
    required this.child,
  });

  /// Background color for container
  final Color color;

  /// Button mode that affects the type of container
  final ButtonMode buttonMode;

  /// Optional padding
  final EdgeInsets? padding;

  /// Child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (buttonMode == ButtonMode.MATERIAL) {
      return Material(
        color: color,
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      );
    } else {
      return Container(color: color, padding: padding, child: child);
    }
  }
}
