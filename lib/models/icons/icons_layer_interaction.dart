import 'package:flutter/material.dart';

/// Represents the interaction icons for layers in the theme.
///
/// This class defines the icons used for various layer interactions such as
/// removing a layer and rotating/scaling a layer.
class IconsLayerInteraction {
  /// The icon data for removing a layer.
  final IconData remove;

  /// The icon data for editing a Textlayer.
  final IconData edit;

  /// The icon data for rotating or scaling a layer.
  final IconData rotateScale;

  /// Creates a new instance of [IconsLayerInteraction].
  ///
  /// The [edit] icon defaults to [Icons.edit].
  /// The [remove] icon defaults to [Icons.clear].
  /// The [rotateScale] icon defaults to [Icons.sync].
  const IconsLayerInteraction({
    this.remove = Icons.clear,
    this.edit = Icons.edit_outlined,
    this.rotateScale = Icons.sync,
  });
}
