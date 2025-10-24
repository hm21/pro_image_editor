import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/features/audio_editor/audio_editor_page.dart';
import '/pro_image_editor.dart';
import '../../grounded_design.dart';

/// A widget that displays and manages audio-related controls in the editor.
class GroundedAudioBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [GroundedAudioBar].
  const GroundedAudioBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds text-related information.
  final AudioEditorPageState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedAudioBar> createState() => _GroundedAudioBarState();
}

class _GroundedAudioBarState extends State<GroundedAudioBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: GroundedBottomWrapper(
        theme: configs.theme,
        children: (constraints) => [
          GroundedBottomBar(
            configs: configs,
            done: widget.editor.done,
            close: widget.editor.close,
          ),
        ],
      ),
    );
  }
}
