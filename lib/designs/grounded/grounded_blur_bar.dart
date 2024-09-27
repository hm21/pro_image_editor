import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/designs/grounded/utils/grounded_configs.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that represents the blur control bar in the image editor.
///
/// The [GroundedBlurBar] provides a UI to adjust the blur effect applied to
/// an image within the ProImageEditor package. It includes a slider for
/// controlling the blur factor and integrates with the `GroundedBottomWrapper`
/// and `GroundedBottomBar` for consistency.
class GroundedBlurBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedBlurBar].
  ///
  /// Requires the [configs], [callbacks], and [editor] parameters.
  const GroundedBlurBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds blur and editing information.
  final BlurEditorState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedBlurBar> createState() => _GroundedBlurBarState();
}

/// State class for [GroundedBlurBar].
///
/// This state manages the UI and interactions for the blur bar, including
/// the slider to adjust the blur factor.
class _GroundedBlurBarState extends State<GroundedBlurBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        _buildFunctions(constraints),
        GroundedBottomBar(
          configs: configs,
          done: widget.editor.done,
          close: widget.editor.close,
        ),
      ],
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
    return Container(
      color: imageEditorTheme.bottomBarBackgroundColor,
      child: FadeInUp(
        duration: GROUNDED_FADE_IN_DURATION,
        child: Slider(
          onChanged: (value) {
            widget.editor.setBlurFactor(value);
          },
          value: widget.editor.blurFactor,
          max: blurEditorConfigs.maxBlur,
          activeColor: Colors.blue.shade200,
        ),
      ),
    );
  }
}
