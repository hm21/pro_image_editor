// Flutter imports:
import 'package:flutter/widgets.dart';

/// A theme configuration for adaptive dialogs.
class AdaptiveDialogTheme {
  /// Constructs an [AdaptiveDialogTheme] object with the given parameters.
  const AdaptiveDialogTheme({
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });

  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;
}
