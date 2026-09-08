import 'package:material_ui/material_ui.dart';

import '/core/models/i18n/i18n_layer_interaction.dart';
import '/core/models/icons/layer_interaction_icons.dart';

/// Represents a context menu for interacting with a layer widget.
class LayerWidgetContextMenu {
  /// Creates a [LayerWidgetContextMenu] with the required callbacks and
  /// interaction configurations.
  LayerWidgetContextMenu({
    required this.onRemoveTap,
    required this.onEditTap,
    required this.onContextMenuToggled,
    required this.i18nLayerInteraction,
    required this.layerInteractionIcons,
  });

  /// Callback triggered when the layer is removed.
  final Function()? onRemoveTap;

  /// Callback triggered when the layer is edited.
  final Function()? onEditTap;

  /// Callback triggered when the context menu is opened or closed.
  final Function(bool isOpen)? onContextMenuToggled;

  /// Provides localized strings for layer interactions.
  final I18nLayerInteraction i18nLayerInteraction;

  /// Provides icons for layer interaction actions.
  final LayerInteractionIcons layerInteractionIcons;

  /// Opens the context menu at the specified position.
  ///
  /// The menu allows users to edit or remove a layer based on the provided
  /// permissions.
  void open({
    required BuildContext context,
    required TapUpDetails details,
    required bool enableEditButton,
    required bool enableRemoveButton,
  }) {
    final Offset clickPosition = details.globalPosition;
    double spacing = 14.0;

    onContextMenuToggled?.call(true);

    // Show a popup menu at the click position.
    showMenu(
      context: context,
      useRootNavigator: true,
      position: RelativeRect.fromLTRB(
        clickPosition.dx,
        clickPosition.dy,
        clickPosition.dx + 1.0, // Adding a small value to avoid zero width
        clickPosition.dy + 1.0, // Adding a small value to avoid zero height
      ),
      items: <PopupMenuEntry<String>>[
        if (enableEditButton)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              spacing: spacing,
              children: [
                Icon(layerInteractionIcons.edit),
                Text(i18nLayerInteraction.edit),
              ],
            ),
          ),
        if (enableRemoveButton)
          PopupMenuItem<String>(
            value: 'remove',
            child: Row(
              spacing: spacing,
              children: [
                Icon(layerInteractionIcons.remove),
                Text(i18nLayerInteraction.remove),
              ],
            ),
          ),
      ],
    ).then((String? selectedValue) {
      switch (selectedValue) {
        case 'edit':
          onEditTap?.call();
          break;
        case 'remove':
          onRemoveTap?.call();
          break;
        default:
      }

      onContextMenuToggled?.call(false);
    });
  }
}
