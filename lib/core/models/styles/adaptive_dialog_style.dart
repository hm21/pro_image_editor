// Flutter imports:
import 'package:flutter/widgets.dart';

/// A style configuration for adaptive dialogs.
class AdaptiveDialogStyle {
  /// Constructs an [AdaptiveDialogStyle] object with the given parameters.
  const AdaptiveDialogStyle({
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });

  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;

  /// Creates a copy of this `AdaptiveDialogStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [AdaptiveDialogStyle] with some properties updated while keeping the
  /// others unchanged.
  AdaptiveDialogStyle copyWith({
    Color? cupertinoPrimaryColorLight,
    Color? cupertinoPrimaryColorDark,
  }) {
    return AdaptiveDialogStyle(
      cupertinoPrimaryColorLight:
          cupertinoPrimaryColorLight ?? this.cupertinoPrimaryColorLight,
      cupertinoPrimaryColorDark:
          cupertinoPrimaryColorDark ?? this.cupertinoPrimaryColorDark,
    );
  }
}
