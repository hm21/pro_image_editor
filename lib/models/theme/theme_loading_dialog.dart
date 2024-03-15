import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// A theme configuration for loading dialogs.
class LoadingDialogTheme {
  /// Text color for loading dialogs.
  final Color textColor;

  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;

  /// Creates an instance of the `LoadingDialogTheme` class with the specified theme properties.
  const LoadingDialogTheme({
    this.textColor = imageEditorTextColor,
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });
}
