import 'package:material_ui/material_ui.dart';

import '/core/enums/design_mode.dart';
import '/core/models/editor_configs/text_editor_configs.dart';
import '/core/models/i18n/i18n_text_editor.dart';
import '/shared/widgets/platform/platform_popup_menu.dart';

/// A custom AppBar for the text editor, providing options for text alignment,
/// background mode, and font scaling.
class TextEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a `TextEditorAppBar` with the provided configurations, design
  /// mode, and callbacks for user interactions.
  ///
  /// - [textEditorConfigs]: Configuration settings for the text editor's
  /// appearance.
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [align]: The current text alignment.
  /// - [designMode]: Indicates the current design mode of the editor.
  /// - [constraints]: Box constraints for responsive layout adjustments.
  /// - [onClose]: Callback triggered when the editor is closed.
  /// - [onDone]: Callback triggered when editing is completed.
  /// - [onToggleTextAlign]: Callback triggered to toggle the text alignment.
  /// - [onOpenFontScaleBottomSheet]: Callback to open the font scaling options.
  /// - [onToggleBackgroundMode]: Callback triggered to toggle background mode.
  const TextEditorAppBar({
    super.key,
    required this.textEditorConfigs,
    required this.i18n,
    required this.onClose,
    required this.onDone,
    required this.align,
    required this.onToggleTextAlign,
    required this.onOpenFontScaleBottomSheet,
    required this.onToggleBackgroundMode,
    required this.designMode,
    required this.constraints,
  });

  /// Configuration settings for the text editor's appearance.
  final TextEditorConfigs textEditorConfigs;

  /// Localization strings for tooltips and labels.
  final I18nTextEditor i18n;

  /// The current text alignment.
  final TextAlign align;

  /// Indicates the current design mode of the editor.
  final ImageEditorDesignMode designMode;

  /// Box constraints for responsive layout adjustments.
  final BoxConstraints constraints;

  /// Callback triggered when the editor is closed.
  final Function() onClose;

  /// Callback triggered when editing is completed.
  final Function() onDone;

  /// Callback triggered to toggle the text alignment.
  final Function() onToggleTextAlign;

  /// Callback to open the font scaling options.
  final Function() onOpenFontScaleBottomSheet;

  /// Callback triggered to toggle background mode.
  final Function() onToggleBackgroundMode;

  @override
  Widget build(BuildContext context) {
    const int defaultIconButtonSize = 48;
    final List<IconButton> configButtons = _getConfigButtons();

    // Taking into account the back and done button
    final iconButtonsSize = (2 + configButtons.length) * defaultIconButtonSize;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: textEditorConfigs.style.appBarBackground,
      foregroundColor: textEditorConfigs.style.appBarColor,
      actions: [
        IconButton(
          tooltip: i18n.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(textEditorConfigs.icons.backButton),
          onPressed: onClose,
        ),
        const Spacer(),
        if (constraints.maxWidth >= iconButtonsSize) ...[
          ..._getConfigButtons(),
          const Spacer(),
          _buildDoneBtn(),
        ] else ...[
          _buildDoneBtn(),
          PlatformPopupBtn(
            designMode: designMode,
            title: i18n.smallScreenMoreTooltip,
            options: [
              if (textEditorConfigs.showTextAlignButton)
                PopupMenuOption(
                  label: i18n.textAlign,
                  icon: Icon(
                    align == TextAlign.left
                        ? textEditorConfigs.icons.alignLeft
                        : align == TextAlign.right
                        ? textEditorConfigs.icons.alignRight
                        : textEditorConfigs.icons.alignCenter,
                  ),
                  onTap: () {
                    onToggleTextAlign();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (textEditorConfigs.showFontScaleButton)
                PopupMenuOption(
                  label: i18n.fontScale,
                  icon: Icon(textEditorConfigs.icons.fontScale),
                  onTap: () {
                    onOpenFontScaleBottomSheet();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (textEditorConfigs.showBackgroundModeButton)
                PopupMenuOption(
                  label: i18n.backgroundMode,
                  icon: Icon(textEditorConfigs.icons.backgroundMode),
                  onTap: () {
                    onToggleBackgroundMode();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      key: const ValueKey('TextEditorDoneButton'),
      tooltip: i18n.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(textEditorConfigs.icons.applyChanges),
      iconSize: 28,
      onPressed: onDone,
    );
  }

  List<IconButton> _getConfigButtons() => [
    if (textEditorConfigs.showTextAlignButton)
      IconButton(
        key: const ValueKey('TextAlignIconButton'),
        tooltip: i18n.textAlign,
        onPressed: onToggleTextAlign,
        icon: Icon(
          align == TextAlign.left
              ? textEditorConfigs.icons.alignLeft
              : align == TextAlign.right
              ? textEditorConfigs.icons.alignRight
              : textEditorConfigs.icons.alignCenter,
        ),
      ),
    if (textEditorConfigs.showFontScaleButton)
      IconButton(
        key: const ValueKey('BackgroundModeFontScaleButton'),
        tooltip: i18n.fontScale,
        onPressed: onOpenFontScaleBottomSheet,
        icon: Icon(textEditorConfigs.icons.fontScale),
      ),
    if (textEditorConfigs.showBackgroundModeButton)
      IconButton(
        key: const ValueKey('BackgroundModeColorIconButton'),
        tooltip: i18n.backgroundMode,
        onPressed: onToggleBackgroundMode,
        icon: Icon(textEditorConfigs.icons.backgroundMode),
      ),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
