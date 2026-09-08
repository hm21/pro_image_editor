import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/tune_editor_configs.dart';
import '/core/models/i18n/i18n_tune_editor.dart';

/// A custom AppBar for the tune editor, providing controls for undo, redo,
/// and completing or closing the tuning process.
class TuneEditorAppbar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a `TuneEditorAppbar` with the provided configurations and
  /// callbacks.
  ///
  /// - [tuneEditorConfigs]: Configuration settings for the tune editor's
  ///   appearance.
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [canRedo]: Indicates whether redo action is currently available.
  /// - [canUndo]: Indicates whether undo action is currently available.
  /// - [onRedo]: Callback triggered for redoing the last undone action.
  /// - [onUndo]: Callback triggered for undoing the last action.
  /// - [onClose]: Callback triggered for closing the tune editor.
  /// - [onDone]: Callback triggered for completing the tuning process.
  const TuneEditorAppbar({
    super.key,
    required this.tuneEditorConfigs,
    required this.i18n,
    required this.canRedo,
    required this.canUndo,
    required this.onRedo,
    required this.onUndo,
    required this.onClose,
    required this.onDone,
  });

  /// Configuration settings for the tune editor's appearance.
  final TuneEditorConfigs tuneEditorConfigs;

  /// Localization strings for tooltips and labels.
  final I18nTuneEditor i18n;

  /// Indicates whether redo action is currently available.
  final bool canRedo;

  /// Indicates whether undo action is currently available.
  final bool canUndo;

  /// Callback triggered for redoing the last undone action.
  final Function() onRedo;

  /// Callback triggered for undoing the last action.
  final Function() onUndo;

  /// Callback triggered for closing the tune editor.
  final Function() onClose;

  /// Callback triggered for completing the tuning process.
  final Function() onDone;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: tuneEditorConfigs.style.appBarBackground,
      foregroundColor: tuneEditorConfigs.style.appBarColor,
      actions: [
        IconButton(
          tooltip: i18n.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(tuneEditorConfigs.icons.backButton),
          onPressed: onClose,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.undo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            tuneEditorConfigs.icons.undoAction,
            color: canUndo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: canUndo ? onUndo : null,
        ),
        IconButton(
          tooltip: i18n.redo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            tuneEditorConfigs.icons.redoAction,
            color: canRedo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: canRedo ? onRedo : null,
        ),
        IconButton(
          tooltip: i18n.done,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(tuneEditorConfigs.icons.applyChanges),
          iconSize: 28,
          onPressed: onDone,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
