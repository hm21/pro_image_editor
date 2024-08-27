// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/pro_image_editor_icons.dart';

/// Customizable icons for the Sticker Editor component.
class IconsStickerEditor {
  /// Creates an instance of [IconsStickerEditor] with customizable icon
  /// settings.
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

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates a copy of this `IconsStickerEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsStickerEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsStickerEditor copyWith({
    IconData? bottomNavBar,
  }) {
    return IconsStickerEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
    );
  }
}
