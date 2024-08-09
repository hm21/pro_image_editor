// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// A theme configuration for loading dialogs.
class LoadingDialogTheme {
  /// Creates an instance of the `LoadingDialogTheme` class with the specified
  /// theme properties.
  const LoadingDialogTheme({
    this.textColor = imageEditorTextColor,
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });

  /// Text color for loading dialogs.
  final Color textColor;

  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;
}
