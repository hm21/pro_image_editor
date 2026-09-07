import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../models/paint_bottom_bar_item.dart';

/// A widget representing the bottom bar for the paint editor, providing
/// options for selecting paint modes, enabling zoom, and other related actions.
class PaintEditorBottombar extends StatelessWidget {
  /// Creates a `PaintEditorBottombar` with the provided configurations,
  /// modes, and callbacks for interactions.
  ///
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [configs]: Configuration settings for the paint editor.
  /// - [paintMode]: The current paint mode being used.
  /// - [bottomBarScrollCtrl]: Controls the scroll behavior of the bottom bar.
  /// - [theme]: Theme data for styling the bottom bar.
  /// - [enableZoom]: Whether zoom functionality is enabled.
  /// - [tools]: A list of available paint modes displayed in the bottom
  ///   bar.
  /// - [setMode]: Callback triggered when a new paint mode is selected.
  const PaintEditorBottombar({
    super.key,
    required this.configs,
    required this.paintMode,
    required this.i18n,
    required this.theme,
    required this.enableZoom,
    required this.tools,
    required this.setMode,
    required this.bottomBarScrollCtrl,
  });

  /// Localization strings for tooltips and labels.
  final I18nPaintEditor i18n;

  /// Configuration settings for the paint editor.
  final PaintEditorConfigs configs;

  /// The current paint mode being used.
  final PaintMode paintMode;

  /// Controls the scroll behavior of the bottom bar.
  final ScrollController bottomBarScrollCtrl;

  /// Theme data for styling the bottom bar.
  final ThemeData theme;

  /// Whether zoom functionality is enabled.
  final bool enableZoom;

  /// A list of available paint modes displayed in the bottom bar.
  final List<PaintModeBottomBarItem> tools;

  /// Callback triggered when a new paint mode is selected.
  final Function(PaintMode mode) setMode;

  Color _getColor(PaintMode mode) {
    return paintMode == mode
        ? configs.style.bottomBarActiveItemColor
        : configs.style.bottomBarInactiveItemColor;
  }

  @override
  Widget build(BuildContext context) {
    double minWidth = min(MediaQuery.sizeOf(context).width, 600);
    double maxWidth = max((tools.length + (enableZoom ? 1 : 0)) * 80, minWidth);

    return Theme(
      data: theme,
      child: EditorScrollbar(
        controller: bottomBarScrollCtrl,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: configs.style.bottomBarBackground,
          padding: EdgeInsets.zero,
          child: Center(
            child: SingleChildScrollView(
              controller: bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: minWidth,
                  maxWidth: MediaQuery.sizeOf(context).width > 660
                      ? maxWidth
                      : double.infinity,
                ),
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.spaceAround,
                  runAlignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: tools.map((item) {
                    Color color = _getColor(item.mode);
                    return FlatIconTextButton(
                      label: Text(
                        item.label,
                        style: TextStyle(fontSize: 10.0, color: color),
                      ),
                      icon: Icon(item.icon, color: color),
                      onPressed: () {
                        setMode(item.mode);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
