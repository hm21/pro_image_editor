import 'package:flutter/widgets.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';

class ClipsEditorPage extends StatefulWidget with SimpleConfigsAccess {
  /// Constructs a `ClipsEditorPage` widget.
  const ClipsEditorPage({
    super.key,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
  });

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  @override
  createState() => ClipsEditorPageState();
}

class ClipsEditorPageState extends State<ClipsEditorPage>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
