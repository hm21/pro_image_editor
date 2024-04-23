import 'package:flutter/material.dart';

import '../../models/editor_configs/pro_image_editor_configs.dart';
import '../../models/transform_helper.dart';

class TransformEditorSize extends StatefulWidget {
  final ProImageEditorConfigs configs;
  final Widget child;

  final EdgeInsets? paddingHelper;
  final Clip clipBehavior;

  final TransformHelper transformHelper;

  const TransformEditorSize({
    super.key,
    required this.configs,
    required this.child,
    this.paddingHelper,
    this.transformHelper = const TransformHelper(
      editorBodySize: Size.zero,
      mainBodySize: Size.zero,
      mainImageSize: Size.zero,
    ),
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<TransformEditorSize> createState() => _TransformEditorSizeState();
}

class _TransformEditorSizeState extends State<TransformEditorSize> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.translate(
        offset: widget.transformHelper.offset,
        child: Transform.scale(
          scale: widget.transformHelper.scale,
          child: widget.child,
        ),
      ),
    );
  }
}
