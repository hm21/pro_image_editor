import 'package:material_ui/material_ui.dart';
import '/core/models/editor_configs/blur_editor_configs.dart';
import '/core/models/i18n/i18n_blur_editor.dart';

/// A custom AppBar widget for the Blur Editor feature.
///
/// This widget is a stateless widget that implements the PreferredSizeWidget
/// interface, making it suitable for use as an AppBar in a Scaffold.
///
/// The [BlurEditorAppBar] requires the following parameters:
///
/// * [blurEditorConfigs]: Configuration settings for the blur editor.
/// * [i18n]: Internationalization object for localized strings.
/// * [close]: Callback function to be executed when the close button is
/// pressed.
/// * [done]: Callback function to be executed when the done button is pressed.
class BlurEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of `BlurEditorAppBar`, a custom `AppBar` for the Blur
  /// Editor UI.
  const BlurEditorAppBar({
    super.key,
    required this.blurEditorConfigs,
    required this.i18n,
    required this.close,
    required this.done,
  });

  /// Configuration settings for the blur editor.
  final BlurEditorConfigs blurEditorConfigs;

  /// Internationalization support for the blur editor.
  final I18nBlurEditor i18n;

  /// Callback function to close the blur editor.
  final Function() close;

  /// Callback function to indicate completion of the blur editing process.
  final Function() done;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: blurEditorConfigs.style.appBarBackgroundColor,
      foregroundColor: blurEditorConfigs.style.appBarForegroundColor,
      actions: [
        IconButton(
          tooltip: i18n.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(blurEditorConfigs.icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.done,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(blurEditorConfigs.icons.applyChanges),
          iconSize: 28,
          onPressed: done,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
