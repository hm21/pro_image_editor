import 'package:flutter/material.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'grounded_design.dart';
import 'utils/grounded_configs.dart';

/// A widget that provides a toolbar for text editing in the ProImageEditor.
///
/// The [GroundedTextBar] allows users to access various text editing features,
/// including changing text color, alignment, and applying custom text styles.
/// It also includes controls for toggling background modes and text alignment.
class GroundedTextBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedTextBar].
  ///
  /// Requires [configs], [callbacks], [editor], [i18nColor], and
  /// [showColorPicker] parameters.
  const GroundedTextBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.i18nColor,
    required this.showColorPicker,
  });

  /// The editor state that holds text-related information.
  final TextEditorState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  /// The localized label for the color picker.
  final String i18nColor;

  /// Function that shows the color picker when called.
  final Function(Color currentColor) showColorPicker;

  @override
  State<GroundedTextBar> createState() => _GroundedTextBarState();
}

class _GroundedTextBarState extends State<GroundedTextBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _bottomBarScrollCtrl;

  Color get _foreGroundColor =>
      imageEditorTheme.textEditor.appBarForegroundColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withOpacity(0.6);

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GroundedBottomWrapper(
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
            done: widget.editor.done,
            close: widget.editor.close,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
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
                if (textEditorConfigs.customTextStyles != null) ...[
                  const SizedBox(width: 5),
                  _buildDivider(),
                  ...List.generate(
                    textEditorConfigs.customTextStyles!.length,
                    (index) {
                      var item = textEditorConfigs.customTextStyles![index];
                      var selected = widget.editor.selectedTextStyle;
                      bool isSelected = selected.hashCode == item.hashCode;

                      return FadeInUp(
                        duration: GROUNDED_FADE_IN_DURATION * 1.5,
                        delay: GROUNDED_FADE_IN_STAGGER_DELAY * (index + 2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: IconButton(
                            onPressed: () => widget.editor.setTextStyle(item),
                            icon: Text(
                              'Aa',
                              style: item.copyWith(
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.white : Colors.black38,
                              foregroundColor:
                                  isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
          widget.showColorPicker(widget.editor.primaryColor);
        },
      ),
      FlatIconTextButton(
        label: Text(
          i18n.textEditor.textAlign,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          switch (widget.editor.align) {
            TextAlign.left => configs.icons.textEditor.alignLeft,
            TextAlign.right => configs.icons.textEditor.alignRight,
            TextAlign.center || _ => configs.icons.textEditor.alignCenter,
          },
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.toggleTextAlign();
        },
      ),
      FlatIconTextButton(
        label: Text(
          i18n.textEditor.backgroundMode,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          configs.icons.textEditor.backgroundMode,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.toggleBackgroundMode();
        },
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
