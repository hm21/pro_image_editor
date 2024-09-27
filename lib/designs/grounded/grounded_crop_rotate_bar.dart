import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../modules/crop_rotate_editor/widgets/crop_aspect_ratio_button.dart';
import 'utils/grounded_configs.dart';

/// A widget that provides controls for cropping and rotating an image in the
/// ProImageEditor.
///
/// The [GroundedCropRotateBar] allows users to apply cropping and rotation
/// functions to an image, with additional controls for aspect ratio selection.
/// It integrates with the ProImageEditor system and uses theming and layout
/// configurations through [ProImageEditorConfigs].
class GroundedCropRotateBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedCropRotateBar].
  ///
  /// Requires [configs], [callbacks], [editor], and [selectedRatioColor].
  const GroundedCropRotateBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.selectedRatioColor,
  });

  /// The editor state that holds crop and rotate information.
  final CropRotateEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// The color used for highlighting the selected aspect ratio.
  final Color selectedRatioColor;

  @override
  State<GroundedCropRotateBar> createState() => _GroundedCropRotateBarState();
}

/// State class for [GroundedCropRotateBar].
///
/// This state manages the UI and interaction for the crop and rotate bar,
/// providing buttons for rotating, flipping, and aspect ratio selection. It
/// includes scrollable horizontal controls and integrates with the undo/redo
/// system of the editor.
class _GroundedCropRotateBarState extends State<GroundedCropRotateBar>
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
          done: widget.editor.done,
          close: widget.editor.close,
          undo: widget.editor.undoAction,
          redo: widget.editor.redoAction,
          enableRedo: widget.editor.canRedo,
          enableUndo: widget.editor.canUndo,
        ),
      ],
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
                    cropRotateEditorConfigs.aspectRatios.length,
                    (index) {
                      var item = cropRotateEditorConfigs.aspectRatios[index];
                      bool isSelected =
                          widget.editor.activeAspectRatio == item.value;
                      return FadeInUp(
                        duration: GROUNDED_FADE_IN_DURATION * 1.5,
                        delay: GROUNDED_FADE_IN_STAGGER_DELAY * (index + 2),
                        child: FlatIconTextButton(
                          label: Text(
                            item.text,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: isSelected
                                  ? widget.selectedRatioColor
                                  : _foreGroundColorAccent,
                            ),
                          ),
                          icon: SizedBox(
                            height: 28,
                            child: FittedBox(
                              child: AspectRatioButton(
                                aspectRatio: item.value,
                                isSelected: isSelected,
                              ),
                            ),
                          ),
                          onPressed: () {
                            widget.editor.updateAspectRatio(item.value ?? -1);
                          },
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
          i18n.cropRotateEditor.rotate,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          configs.icons.cropRotateEditor.rotate,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.rotate();
        },
      ),
      FlatIconTextButton(
        label: Text(
          i18n.cropRotateEditor.flip,
          style: TextStyle(
            fontSize: 10.0,
            color: _foreGroundColorAccent,
          ),
        ),
        icon: Icon(
          configs.icons.cropRotateEditor.flip,
          color: _foreGroundColor,
        ),
        onPressed: () {
          widget.editor.flip();
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
