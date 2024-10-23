import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/designs/grounded/utils/grounded_configs.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that represents a grounded tune adjustment bar for the editor.
///
/// The `GroundedTuneBar` is used to display and manage tune adjustment options
/// for the image editor, providing the ability to adjust various parameters
/// such as brightness, contrast, and saturation.
///
/// This widget interacts with the `TuneEditorState` to apply the changes and
/// uses the provided `configs` and `callbacks` for customization and response
/// handling.
class GroundedTuneBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a `GroundedTuneBar` with the given configurations and callbacks.
  ///
  /// The [configs] parameter provides the configuration settings for the
  /// editor.
  /// The [callbacks] parameter provides the callback functions for handling
  /// user interactions.
  /// The [editor] parameter refers to the `TuneEditorState` that manages the
  /// image editing state.
  const GroundedTuneBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds filter and editing information.
  final TuneEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedTuneBar> createState() => _GroundedTuneBarState();
}

class _GroundedTuneBarState extends State<GroundedTuneBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Controller for managing the scroll of the horizontal filter list.
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

  TuneEditorState get tuneEditor => widget.editor;

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
          undo: tuneEditor.undo,
          redo: tuneEditor.redo,
          enableRedo: tuneEditor.canRedo,
          enableUndo: tuneEditor.canUndo,
        ),
      ],
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;
    return Container(
      color: imageEditorTheme.bottomBarBackgroundColor,
      child: FadeInUp(
        duration: GROUNDED_FADE_IN_DURATION,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: RepaintBoundary(
                child: StreamBuilder(
                    stream: tuneEditor.uiStream.stream,
                    builder: (context, snapshot) {
                      var activeOption = tuneEditor
                          .tuneAdjustmentList[tuneEditor.selectedIndex];
                      var activeMatrix = tuneEditor
                          .tuneAdjustmentMatrix[tuneEditor.selectedIndex];
                      return SizedBox(
                        height: 40,
                        child: Slider(
                          min: activeOption.min,
                          max: activeOption.max,
                          divisions: activeOption.divisions,
                          label: (activeMatrix.value *
                                  activeOption.labelMultiplier)
                              .round()
                              .toString(),
                          value: activeMatrix.value,
                          onChangeStart: tuneEditor.onChangedStart,
                          onChanged: tuneEditor.onChanged,
                          onChangeEnd: tuneEditor.onChangedEnd,
                        ),
                      );
                    }),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: kBottomNavigationBarHeight,
              child: Scrollbar(
                controller: tuneEditor.bottomBarScrollCtrl,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                thickness: isDesktop ? null : 0,
                child: SingleChildScrollView(
                  controller: tuneEditor.bottomBarScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          tuneEditor.tuneAdjustmentMatrix.length, (index) {
                        var item = tuneEditor.tuneAdjustmentList[index];
                        return FlatIconTextButton(
                          label: Text(item.label, style: bottomTextStyle),
                          icon: Icon(
                            item.icon,
                            size: bottomIconSize,
                            color: tuneEditor.selectedIndex == index
                                ? imageEditorPrimaryColor
                                : Colors.white,
                          ),
                          onPressed: () {
                            tuneEditor.setState(() {
                              tuneEditor.selectedIndex = index;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
