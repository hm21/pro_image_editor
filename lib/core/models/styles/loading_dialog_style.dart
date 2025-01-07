// Flutter imports:
import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// A style configuration for loading dialogs.
class LoadingDialogStyle {
  /// Creates an instance of the `LoadingDialogStyle` class with the specified
  /// style properties.
  const LoadingDialogStyle({
    this.textColor = kImageEditorTextColor,
    this.cupertinoPrimaryColorLight = const Color(0xFF000000),
    this.cupertinoPrimaryColorDark = const Color(0xFFFFFFFF),
  });

  /// Text color for loading dialogs.
  final Color textColor;

  /// Primary color in the Cupertino design with brightness `light`.
  final Color cupertinoPrimaryColorLight;

  /// Primary color in the Cupertino design with brightness `dark`.
  final Color cupertinoPrimaryColorDark;

  /// Creates a copy of this `LoadingDialogStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [LoadingDialogStyle] with some properties updated while keeping the
  /// others unchanged.
  LoadingDialogStyle copyWith({
    Color? textColor,
    Color? cupertinoPrimaryColorLight,
    Color? cupertinoPrimaryColorDark,
  }) {
    return LoadingDialogStyle(
      textColor: textColor ?? this.textColor,
      cupertinoPrimaryColorLight:
          cupertinoPrimaryColorLight ?? this.cupertinoPrimaryColorLight,
      cupertinoPrimaryColorDark:
          cupertinoPrimaryColorDark ?? this.cupertinoPrimaryColorDark,
    );
  }
}
