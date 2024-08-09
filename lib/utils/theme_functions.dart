// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'design_mode.dart';

/// Determines the appropriate text style based on the platform and design mode.
///
/// The `platformTextStyle` function returns a text style that is suitable for
/// the given platform (iOS or Android) and design mode (Material or Cupertino).
///
/// Parameters:
/// - `context`: A BuildContext object representing the current build context.
/// - `mode`: An `ImageEditorDesignMode` enum representing the design mode
/// (Material or Cupertino).
///
/// Returns:
/// A `TextStyle` object that matches the text style of the specified platform
/// and design mode.
///
/// Example Usage:
/// ```dart
/// // Get the appropriate text style for Material Design on Android.
/// TextStyle textStyle =
/// platformTextStyle(context, ImageEditorDesignMode.material);
///
/// // Get the appropriate text style for Cupertino Design on iOS.
/// TextStyle textStyle =
/// platformTextStyle(context, ImageEditorDesignMode.cupertino);
/// ```
TextStyle platformTextStyle(BuildContext context, ImageEditorDesignModeE mode) {
  if (mode == ImageEditorDesignModeE.cupertino) {
    return CupertinoTheme.of(context).textTheme.textStyle;
  } else {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }
}
