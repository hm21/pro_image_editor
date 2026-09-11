import 'package:material_ui/material_ui.dart';

/// Provides `package:material_ui` [MaterialLocalizations] when the host app
/// still uses the SDK `MaterialApp`.
///
/// Overlay dialogs and sub-editor routes sit under the host navigator, so they
/// cannot see a theme wrapper around [ProImageEditor] alone.
///
/// An existing host [MaterialLocalizations] is left alone, including regional
/// locales such as `en_GB`. A fallback is inserted only when the lookup
/// misses:
/// - [GlobalMaterialLocalizations] when that delegate supports the ambient
///   locale
/// - otherwise [DefaultMaterialLocalizations] (US English)
class MaterialUiLocalizationsScope extends StatelessWidget {
  /// Creates a [MaterialUiLocalizationsScope].
  const MaterialUiLocalizationsScope({super.key, required this.child});

  /// The subtree that needs material_ui localizations.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) !=
        null) {
      return child;
    }

    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final useGlobal = GlobalMaterialLocalizations.delegate.isSupported(locale);

    return Localizations.override(
      context: context,
      // DefaultMaterialLocalizations.delegate only accepts English. Keep the
      // ambient locale when the global catalog can serve it; otherwise load
      // US English so the fallback delegate is not skipped.
      locale: useGlobal ? locale : const Locale('en'),
      delegates: [
        useGlobal
            ? GlobalMaterialLocalizations.delegate
            : DefaultMaterialLocalizations.delegate,
      ],
      child: child,
    );
  }
}
