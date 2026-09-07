import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/filter_editor_configs.dart';
import '/core/models/i18n/i18n_filter_editor.dart';

/// A custom AppBar for the Filter Editor, providing close and apply options.
class FilterEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates a `FilterEditorAppBar` with the provided configurations.
  ///
  /// - [filterEditorConfigs]: Configurations for styling and behavior.
  /// - [i18n]: Localization for tooltips and labels.
  /// - [close]: Callback for closing the editor.
  /// - [done]: Callback for applying changes.
  const FilterEditorAppBar({
    super.key,
    required this.filterEditorConfigs,
    required this.i18n,
    required this.close,
    required this.done,
  });

  /// Configurations for styling and behavior.
  final FilterEditorConfigs filterEditorConfigs;

  /// Localization for tooltips and labels.
  final I18nFilterEditor i18n;

  /// Callback for closing the editor.
  final Function() close;

  /// Callback for applying changes.
  final Function() done;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: filterEditorConfigs.style.appBarBackground,
      foregroundColor: filterEditorConfigs.style.appBarColor,
      actions: [
        IconButton(
          tooltip: i18n.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(filterEditorConfigs.icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.done,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(filterEditorConfigs.icons.applyChanges),
          iconSize: 28,
          onPressed: done,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
