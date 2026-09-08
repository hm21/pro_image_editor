import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/platform/platform_circular_progress_indicator.dart';
import '../services/state_manager.dart';

/// A custom AppBar for the main editor, providing actions for closing,
/// undoing, redoing, and completing editing tasks.
class MainEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a `MainEditorAppBar` with the given configurations and actions.
  ///
  /// - [i18n]: Localization for tooltips and labels.
  /// - [configs]: Configuration settings for the editor.
  /// - [closeEditor]: Callback for closing the editor.
  /// - [undoAction]: Callback for undoing the last action.
  /// - [redoAction]: Callback for redoing the last undone action.
  /// - [doneEditing]: Callback for applying changes and completing editing.
  /// - [isInitialized]: Indicates whether the editor has been fully
  /// initialized.
  /// - [stateManager]: Manages the editor's state.
  const MainEditorAppBar({
    super.key,
    required this.i18n,
    required this.configs,
    required this.closeEditor,
    required this.undoAction,
    required this.redoAction,
    required this.doneEditing,
    required this.isInitialized,
    required this.stateManager,
  });

  /// Localization for tooltips and labels.
  final I18n i18n;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Manages the editor's state.
  final StateManager stateManager;

  /// Retrieves the main editor's specific configurations.
  MainEditorConfigs get mainEditorConfigs => configs.mainEditor;

  /// Determines the foreground color for the AppBar.
  Color get foregroundColor => mainEditorConfigs.style.appBarColor;

  /// Indicates whether the editor has been fully initialized.
  final bool isInitialized;

  /// Callback for closing the editor.
  final Function() closeEditor;

  /// Callback for undoing the last action.
  final Function() undoAction;

  /// Callback for redoing the last undone action.
  final Function() redoAction;

  /// Callback for applying changes and completing editing.
  final Function() doneEditing;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: foregroundColor,
      backgroundColor: mainEditorConfigs.style.appBarBackground,
      leading: mainEditorConfigs.enableCloseButton
          ? IconButton(
              tooltip: i18n.cancel,
              icon: Icon(mainEditorConfigs.icons.closeEditor),
              onPressed: closeEditor,
            )
          : null,
      actions: [
        IconButton(
          key: const ValueKey('MainEditorUndoButton'),
          tooltip: i18n.undo,
          icon: Icon(
            mainEditorConfigs.icons.undoAction,
            color: stateManager.canUndo
                ? foregroundColor
                : foregroundColor.withAlpha(80),
          ),
          onPressed: undoAction,
        ),
        IconButton(
          key: const ValueKey('MainEditorRedoButton'),
          tooltip: i18n.redo,
          icon: Icon(
            mainEditorConfigs.icons.redoAction,
            color: stateManager.canRedo
                ? foregroundColor
                : foregroundColor.withAlpha(80),
          ),
          onPressed: redoAction,
        ),
        !isInitialized
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox.square(
                  dimension: 24,
                  child: PlatformCircularProgressIndicator(configs: configs),
                ),
              )
            : IconButton(
                key: const ValueKey('MainEditorDoneButton'),
                tooltip: i18n.done,
                icon: Icon(mainEditorConfigs.icons.doneIcon),
                iconSize: 28,
                onPressed: doneEditing,
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
