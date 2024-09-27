import 'package:flutter/material.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'grounded_design.dart';
import 'utils/grounded_configs.dart';

/// A widget that provides the painting toolbar for the ProImageEditor.
///
/// The [GroundedPaintingBar] allows users to access painting-related tools
/// such as changing colors, line width, opacity, and toggling fill options
/// for shapes. It also integrates undo/redo functionality and provides zoom
/// options if enabled in the configuration.
class GroundedPaintingBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedPaintingBar].
  ///
  /// Requires [configs], [callbacks], [editor], [i18nColor], and
  /// [showColorPicker] parameters.
  const GroundedPaintingBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.i18nColor,
    required this.showColorPicker,
  });

  /// The editor state that holds painting-related information.
  final PaintingEditorState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  /// The localized label for the color picker.
  final String i18nColor;

  /// Function that shows the color picker when called.
  final Function(Color currentColor) showColorPicker;

  @override
  State<GroundedPaintingBar> createState() => _GroundedPaintingBarState();
}

/// State class for [GroundedPaintingBar].
///
/// This state manages the UI for the painting toolbar, including buttons
/// for selecting colors, line width, opacity, and shape fill options.
class _GroundedPaintingBarState extends State<GroundedPaintingBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _bottomBarScrollCtrl;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  Color get _foreGroundColor =>
      imageEditorTheme.paintingEditor.appBarForegroundColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        Scrollbar(
          controller: _bottomBarScrollCtrl,
          scrollbarOrientation: ScrollbarOrientation.top,
          thickness: isDesktop ? null : 0,
          child: _buildFunctions(constraints),
        ),
        GroundedBottomBar(
          configs: configs,
          undo: widget.editor.undoAction,
          redo: widget.editor.redoAction,
          done: widget.editor.done,
          close: widget.editor.close,
          enableRedo: widget.editor.canRedo,
          enableUndo: widget.editor.canUndo,
        ),
      ],
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
    Color getColor(PaintModeE mode) {
      return widget.editor.paintMode == mode
          ? imageEditorTheme.paintingEditor.bottomBarActiveItemColor
          : imageEditorTheme.paintingEditor.bottomBarInactiveItemColor;
    }

    return BottomAppBar(
      height: GROUNDED_SUB_BAR_HEIGHT,
      color: imageEditorTheme.bottomBarBackgroundColor,
      padding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          controller: _bottomBarScrollCtrl,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: FadeInUp(
            duration: GROUNDED_FADE_IN_DURATION,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ..._buildConfigs(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: _buildDivider(),
                ),
                if (paintEditorConfigs.enableZoom) ...[
                  FlatIconTextButton(
                    label: Text(
                      i18n.paintEditor.moveAndZoom,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: getColor(PaintModeE.moveAndZoom),
                      ),
                    ),
                    icon: Icon(
                      icons.paintingEditor.moveAndZoom,
                      color: getColor(PaintModeE.moveAndZoom),
                    ),
                    onPressed: () {
                      widget.editor.setMode(PaintModeE.moveAndZoom);
                    },
                  ),
                  _buildDivider(),
                ],
                ...List.generate(
                  widget.editor.paintModes.length,
                  (index) {
                    PaintModeBottomBarItem item =
                        widget.editor.paintModes[index];
                    Color color = getColor(item.mode);
                    return FadeInUp(
                      duration: GROUNDED_FADE_IN_DURATION * 1.5,
                      delay: GROUNDED_FADE_IN_STAGGER_DELAY * (index + 2),
                      child: FlatIconTextButton(
                        label: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: widget.editor.paintMode == item.mode
                                ? imageEditorTheme
                                    .paintingEditor.bottomBarActiveItemColor
                                : _foreGroundColorAccent,
                          ),
                        ),
                        icon: Icon(item.icon, color: color),
                        onPressed: () {
                          widget.editor.setMode(item.mode);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfigs() {
    return [
      FlatIconTextButton(
        label: Text(
          widget.i18nColor,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          Icons.color_lens_outlined,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.showColorPicker(widget.editor.activeColor);
        },
      ),
      FlatIconTextButton(
        label: Text(
          i18n.paintEditor.lineWidth,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          configs.icons.paintingEditor.lineWeight,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.openLineWeightBottomSheet();
        },
      ),
      FlatIconTextButton(
        label: Text(
          i18n.paintEditor.changeOpacity,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          configs.icons.paintingEditor.changeOpacity,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.openOpacityBottomSheet();
        },
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            child: child,
          ),
        ),
        child: widget.editor.paintMode == PaintModeE.rect ||
                widget.editor.paintMode == PaintModeE.circle
            ? Center(
                child: FlatIconTextButton(
                  label: Text(
                    i18n.paintEditor.toggleFill,
                    style: TextStyle(
                      fontSize: 10.0,
                      color: _foreGroundColorAccent,
                    ),
                  ),
                  icon: Icon(
                    widget.editor.fillBackground
                        ? configs.icons.paintingEditor.fill
                        : configs.icons.paintingEditor.noFill,
                    color: _foreGroundColor,
                  ),
                  onPressed: () {
                    widget.editor.toggleFill();
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    ];
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: kBottomNavigationBarHeight - 14,
      width: 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: imageEditorTheme.paintingEditor.bottomBarInactiveItemColor,
      ),
    );
  }
}
