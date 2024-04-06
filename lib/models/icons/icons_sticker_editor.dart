import 'package:flutter/material.dart';

import '../../utils/pro_image_editor_icons.dart';

/// Customizable icons for the Sticker Editor component.
class IconsStickerEditor {
  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates an instance of [IconsStickerEditor] with customizable icon settings.
  ///
  /// You can provide a custom [bottomNavBar] icon to be displayed in the
  /// bottom navigation bar of the Sticker Editor component. If no custom icon
  /// is provided, the default icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsStickerEditor(
  ///   bottomNavBar: Icons.layers_outlined,
  /// )
  /// ```
  const IconsStickerEditor({
    this.bottomNavBar = ProImageEditorIcons.stickers,
  });
}
