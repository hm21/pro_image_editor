import 'package:material_ui/material_ui.dart';

import '../../../core/models/editor_configs/crop_rotate_editor_configs.dart';
import '../../../core/models/i18n/i18n_crop_rotate_editor.dart';

/// A custom app bar widget for the crop editor screen.
///
/// This widget provides an app bar with various controls for the crop editor,
/// including undo, redo, and done actions.
///
/// Implements [PreferredSizeWidget] to specify the preferred size of the app
/// bar.
///
/// Parameters:
/// - `configs`: Configuration settings for the crop editor.
/// - `i18n`: Internationalization settings for localization.
/// - `enableCloseButton`: A boolean flag to enable or disable the close button.
/// - `canUndo`: A boolean flag indicating if the undo action is available.
/// - `canRedo`: A boolean flag indicating if the redo action is available.
/// - `onDone`: Callback function to be executed when the done action is
///   triggered.
/// - `onClose`: Callback function to be executed when the close action is
///   triggered.
/// - `onUndo`: Callback function to be executed when the undo action is
///   triggered.
/// - `onRedo`: Callback function to be executed when the redo action is
///   triggered.
class CropEditorAppbar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of `CropEditorAppbar`, a custom `AppBar` for the Blur
  /// Editor UI.
  const CropEditorAppbar({
    super.key,
    required this.configs,
    required this.i18n,
    required this.enableCloseButton,
    required this.canUndo,
    required this.canRedo,
    required this.onDone,
    required this.onClose,
    required this.onUndo,
    required this.onRedo,
  });

  /// Configuration settings for the crop and rotate editor.
  final CropRotateEditorConfigs configs;

  /// Internationalization settings for the crop and rotate editor.
  final I18nCropRotateEditor i18n;

  /// Indicates whether the close button is enabled.
  final bool enableCloseButton;

  /// Indicates whether the undo action is available.
  final bool canUndo;

  /// Indicates whether the redo action is available.
  final bool canRedo;

  /// Callback function to be executed when the done action is triggered.
  final Function() onDone;

  /// Callback function to be executed when the close action is triggered.
  final Function() onClose;

  /// Callback function to be executed when the undo action is triggered.
  final Function() onUndo;

  /// Callback function to be executed when the redo action is triggered.
  final Function() onRedo;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: configs.style.appBarBackground,
      foregroundColor: configs.style.appBarColor,
      actions: [
        if (enableCloseButton)
          IconButton(
            tooltip: i18n.back,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(configs.icons.backButton),
            onPressed: onClose,
          ),
        const Spacer(),
        IconButton(
          tooltip: i18n.undo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            configs.icons.undoAction,
            color: canUndo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: onUndo,
        ),
        IconButton(
          tooltip: i18n.redo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            configs.icons.redoAction,
            color: canRedo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: onRedo,
        ),
        _buildDoneBtn(),
      ],
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(configs.icons.applyChanges),
      iconSize: 28,
      onPressed: onDone,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
