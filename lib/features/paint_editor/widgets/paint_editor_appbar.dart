import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/platform/platform_popup_menu.dart';

/// A custom AppBar for the paint editor, providing controls for undo, redo,
/// toggling fill mode, and accessing additional settings like opacity and
/// line weight.
class PaintEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a `PaintEditorAppBar` with the provided configurations,
  /// constraints, and callbacks for various actions.
  ///
  /// - [paintEditorConfigs]: Configuration settings for the paint editor's
  ///   appearance.
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [constraints]: Box constraints for responsive layout adjustments.
  /// - [designMode]: Indicates the current design mode of the editor.
  /// - [canUndo]: Whether undo action is currently available.
  /// - [canRedo]: Whether redo action is currently available.
  /// - [isFillMode]: Whether fill mode is currently enabled.
  /// - [onTapMenuFill]: Callback triggered when the fill menu is tapped.
  /// - [onUndo]: Callback triggered for undoing the last action.
  /// - [onRedo]: Callback triggered for redoing the last undone action.
  /// - [onToggleFill]: Callback triggered for toggling fill mode.
  /// - [onDone]: Callback triggered for completing the paint editing session.
  /// - [onClose]: Callback triggered for closing the paint editor.
  /// - [onOpenOpacityBottomSheet]: Callback triggered to open the opacity
  ///   settings.
  /// - [onOpenLineWeightBottomSheet]: Callback triggered to open the line
  ///   weight settings.
  const PaintEditorAppBar({
    super.key,
    required this.paintEditorConfigs,
    required this.i18n,
    required this.constraints,
    required this.onTapMenuFill,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleFill,
    required this.onDone,
    required this.onClose,
    required this.canUndo,
    required this.canRedo,
    required this.onOpenOpacityBottomSheet,
    required this.onOpenLineWeightBottomSheet,
    required this.isFillMode,
    required this.designMode,
  });

  /// Configuration settings for the paint editor's appearance.
  final PaintEditorConfigs paintEditorConfigs;

  /// Localization strings for tooltips and labels.
  final I18nPaintEditor i18n;

  /// Box constraints for responsive layout adjustments.
  final BoxConstraints constraints;

  /// Indicates the current design mode of the editor.
  final ImageEditorDesignMode designMode;

  /// Whether undo action is currently available.
  final bool canUndo;

  /// Whether redo action is currently available.
  final bool canRedo;

  /// Whether fill mode is currently enabled.
  final bool isFillMode;

  /// Callback triggered when the fill menu is tapped.
  final Function() onTapMenuFill;

  /// Callback triggered for undoing the last action.
  final Function() onUndo;

  /// Callback triggered for redoing the last undone action.
  final Function() onRedo;

  /// Callback triggered for toggling fill mode.
  final Function() onToggleFill;

  /// Callback triggered for completing the paint editing session.
  final Function() onDone;

  /// Callback triggered for closing the paint editor.
  final Function() onClose;

  /// Callback triggered to open the opacity settings.
  final Function() onOpenOpacityBottomSheet;

  /// Callback triggered to open the line weight settings.
  final Function() onOpenLineWeightBottomSheet;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: paintEditorConfigs.style.appBarBackground,
      foregroundColor: paintEditorConfigs.style.appBarColor,
      actions: _buildAction(constraints),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Builds an action bar depending on the allowed space
  List<Widget> _buildAction(BoxConstraints constraints) {
    const int defaultIconButtonSize = 48;
    final List<Widget> configButtons = _getConfigButtons();
    final List<Widget> actionButtons = _getActionButtons();

    // Taking into account the back button
    final expandedIconButtonsSize =
        (1 + configButtons.length + actionButtons.length) *
        defaultIconButtonSize;

    return [
      IconButton(
        tooltip: i18n.back,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(paintEditorConfigs.icons.backButton),
        onPressed: onClose,
      ),
      const Spacer(),
      ...[
        if (constraints.maxWidth >= expandedIconButtonsSize) ...[
          ...configButtons,
          if (constraints.maxWidth >= 640) const Spacer(),
          ...actionButtons,
        ] else ...[
          ..._buildShortActionBar(
            constraints,
            actionButtons,
            defaultIconButtonSize,
          ),
        ],
      ],
    ];
  }

  /// Builds an action bar with limited number of quick actions
  List<Widget> _buildShortActionBar(
    BoxConstraints constraints,
    List<Widget> actionButtons,
    int defaultIconButtonSize,
  ) {
    final shrunkIconButtonsSize =
        (1 + actionButtons.length) * defaultIconButtonSize;
    final bool hasEnoughSpace = constraints.maxWidth >= shrunkIconButtonsSize;

    return [
      if (hasEnoughSpace) ...[...actionButtons] else ...[_buildDoneBtn()],
      PlatformPopupBtn(
        designMode: designMode,
        title: i18n.smallScreenMoreTooltip,
        options: [
          if (paintEditorConfigs.showLineWidthAdjustmentButton)
            PopupMenuOption(
              label: i18n.lineWidth,
              icon: Icon(paintEditorConfigs.icons.lineWeight),
              onTap: onOpenLineWeightBottomSheet,
            ),
          if (paintEditorConfigs.showToggleFillButton)
            PopupMenuOption(
              label: i18n.toggleFill,
              icon: Icon(
                !isFillMode
                    ? paintEditorConfigs.icons.noFill
                    : paintEditorConfigs.icons.fill,
              ),
              onTap: onTapMenuFill,
            ),
          if (paintEditorConfigs.showOpacityAdjustmentButton)
            PopupMenuOption(
              label: i18n.changeOpacity,
              icon: Icon(paintEditorConfigs.icons.changeOpacity),
              onTap: onOpenOpacityBottomSheet,
            ),
          if (!hasEnoughSpace) ...[
            if (canUndo)
              PopupMenuOption(
                label: i18n.undo,
                icon: Icon(paintEditorConfigs.icons.undoAction),
                onTap: onUndo,
              ),
            if (canRedo)
              PopupMenuOption(
                label: i18n.redo,
                icon: Icon(paintEditorConfigs.icons.redoAction),
                onTap: onRedo,
              ),
          ],
        ],
      ),
    ];
  }

  /// Builds and returns a list of IconButton to change the line width /
  /// toggle fill or un-fill / change the opacity.
  List<Widget> _getConfigButtons() => [
    if (paintEditorConfigs.showLineWidthAdjustmentButton)
      IconButton(
        tooltip: i18n.lineWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(
          paintEditorConfigs.icons.lineWeight,
          color: paintEditorConfigs.style.appBarColor,
        ),
        onPressed: onOpenLineWeightBottomSheet,
      ),
    if (paintEditorConfigs.showToggleFillButton)
      IconButton(
        tooltip: i18n.toggleFill,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(
          !isFillMode
              ? paintEditorConfigs.icons.noFill
              : paintEditorConfigs.icons.fill,
          color: paintEditorConfigs.style.appBarColor,
        ),
        onPressed: onToggleFill,
      ),
    if (paintEditorConfigs.showOpacityAdjustmentButton)
      IconButton(
        tooltip: i18n.changeOpacity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(
          paintEditorConfigs.icons.changeOpacity,
          color: paintEditorConfigs.style.appBarColor,
        ),
        onPressed: onOpenOpacityBottomSheet,
      ),
  ];

  /// Builds and returns a list of IconButton to undo / redo / apply changes.
  List<Widget> _getActionButtons() => [
    IconButton(
      tooltip: i18n.undo,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(
        paintEditorConfigs.icons.undoAction,
        color: canUndo
            ? paintEditorConfigs.style.appBarColor
            : paintEditorConfigs.style.appBarColor.withAlpha(80),
      ),
      onPressed: onUndo,
    ),
    IconButton(
      tooltip: i18n.redo,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(
        paintEditorConfigs.icons.redoAction,
        color: canRedo
            ? paintEditorConfigs.style.appBarColor
            : paintEditorConfigs.style.appBarColor.withAlpha(80),
      ),
      onPressed: onRedo,
    ),
    _buildDoneBtn(),
  ];

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(paintEditorConfigs.icons.applyChanges),
      iconSize: 28,
      onPressed: onDone,
    );
  }
}
