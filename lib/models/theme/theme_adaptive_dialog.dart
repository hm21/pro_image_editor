import 'package:flutter/widgets.dart';

/// A theme configuration for adaptive dialogs.
class AdaptiveDialogTheme {
  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;

  const AdaptiveDialogTheme({
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });
}
