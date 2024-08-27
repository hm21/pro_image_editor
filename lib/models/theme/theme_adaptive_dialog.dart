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

  /// Creates a copy of this `AdaptiveDialogTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [AdaptiveDialogTheme] with some properties updated while keeping the
  /// others unchanged.
  AdaptiveDialogTheme copyWith({
    Color? cupertinoPrimaryColorLight,
    Color? cupertinoPrimaryColorDark,
  }) {
    return AdaptiveDialogTheme(
      cupertinoPrimaryColorLight:
          cupertinoPrimaryColorLight ?? this.cupertinoPrimaryColorLight,
      cupertinoPrimaryColorDark:
          cupertinoPrimaryColorDark ?? this.cupertinoPrimaryColorDark,
    );
  }
}
