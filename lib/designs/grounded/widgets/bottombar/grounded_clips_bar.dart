import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/features/clips_editor/pages/clips_editor_page.dart';
import '/pro_image_editor.dart';
import '../../grounded_design.dart';

/// A widget that displays and manages the list of grounded audio clips.
class GroundedClipsBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [GroundedClipsBar].
  const GroundedClipsBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds text-related information.
  final ClipsEditorPageState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedClipsBar> createState() => _GroundedClipsBarState();
}

class _GroundedClipsBarState extends State<GroundedClipsBar>
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
