// Flutter imports:
import 'package:flutter/material.dart';

/// The theme the editor falls back to when `ProImageEditorConfigs.theme` is
/// `null`.
///
/// Layer content inherits its text theme from the surrounding [Theme], so
/// anything that renders layers outside the editor has to install the same
/// fallback to get the same result.
ThemeData defaultEditorTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue.shade800,
      brightness: Brightness.dark,
    ),
  );
}
