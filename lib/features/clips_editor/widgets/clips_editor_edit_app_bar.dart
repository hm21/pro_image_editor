import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';

/// App bar used within the Clips editor page.
class ClipsEditorEditAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates a [ClipsEditorEditAppBar] with the provided configurations.
  const ClipsEditorEditAppBar({
    super.key,
    required this.configs,
    required this.i18n,
    required this.onClose,
    required this.onDone,
    required this.onRemove,
  });

  /// Configuration used to determine colors and icons for the Clips editor.
  final ClipsEditorConfigs configs;

  /// Localized strings used for tooltips.
  final I18nClipsEditor i18n;

  /// Callback invoked when the close button is pressed.
  final Function() onClose;

  /// Callback invoked when the done button is pressed, if available.
  final Function()? onDone;

  /// Callback invoked when the remove button is pressed, if available.
  final Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: configs.style.editPageAppBarBackground,
      foregroundColor: configs.style.editPageAppBarColor,
      actions: _buildAction(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Builds an action bar depending on the allowed space.
  List<Widget> _buildAction() {
    return [
      IconButton(
        tooltip: i18n.back,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(configs.icons.editPageBackButton),
        onPressed: onClose,
      ),
      const Spacer(),
      IconButton(
        tooltip: i18n.remove,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(configs.icons.editPageRemoveClip),
        iconSize: 28,
        onPressed: onRemove,
      ),
      const VerticalDivider(
        indent: 10,
        endIndent: 10,
      ),
      IconButton(
        tooltip: i18n.done,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(configs.icons.editPageApplyChanges),
        iconSize: 28,
        onPressed: onDone,
      ),
    ];
  }
}
