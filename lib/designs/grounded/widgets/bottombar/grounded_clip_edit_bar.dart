import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/features/clips_editor/pages/clips_editor_edit_page.dart';
import '/pro_image_editor.dart';
import '../../grounded_design.dart';

/// A toolbar widget for editing video clips.
class GroundedClipEditorBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [GroundedClipEditorBar].
  const GroundedClipEditorBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds text-related information.
  final ClipsEditorEditPageState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedClipEditorBar> createState() => _GroundedClipEditorBarState();
}

class _GroundedClipEditorBarState extends State<GroundedClipEditorBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        GroundedBottomBar(
          configs: configs,
          done: widget.editor.done,
          close: widget.editor.close,
        ),
      ],
    );
  }
}
