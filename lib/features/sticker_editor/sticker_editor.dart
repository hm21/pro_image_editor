// Flutter imports:
import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';
import '../../core/models/layers/layer.dart';

/// The `StickerEditor` class is responsible for creating a widget that allows
/// users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis,
/// which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
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
  createState() => StickerEditorState();
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
    callbacks.stickerEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callbacks.stickerEditorCallbacks?.onAfterViewInit?.call();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.configs.stickerEditor.buildStickers != null,
      '`buildStickers` is required',
    );

    return ExtendedPopScope(
      child: widget.configs.stickerEditor.buildStickers!(
          setLayer, widget.scrollController),
    );
  }

  /// Sets the current layer with a sticker and closes the navigation.
  ///
  /// [sticker] is the widget to be set as the layer.
  void setLayer(Widget sticker) {
    Navigator.of(context).pop(
      StickerLayerData(sticker: sticker),
    );
  }
}
