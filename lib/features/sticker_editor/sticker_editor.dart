import 'package:material_ui/material_ui.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';

/// The `StickerEditor` class is responsible for creating a widget that allows
/// users to select stickers
class StickerEditor extends StatefulWidget with SimpleConfigsAccess {
  /// Creates an `StickerEditor` widget.
  const StickerEditor({
    super.key,
    required this.configs,
    this.callbacks = const ProImageEditorCallbacks(),
    required this.scrollController,
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Controller for managing scroll actions.
  final ScrollController scrollController;

  @override
  StickerEditorState createState() => StickerEditorState();
}

/// The state class for the `StickerEditor` widget.
class StickerEditorState extends State<StickerEditor>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    callbacks.stickerEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callbacks.stickerEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(stickerEditorConfigs.builder != null, '`builder` is required');

    return ExtendedPopScope(
      canPop: stickerEditorConfigs.enableGesturePop,
      child: stickerEditorConfigs.builder!.call(
        setLayer,
        widget.scrollController,
      ),
    );
  }

  /// Close the editor with the selected widget-layer.
  void setLayer(WidgetLayer widgetLayer) {
    Navigator.of(context).pop(widgetLayer);
  }
}
