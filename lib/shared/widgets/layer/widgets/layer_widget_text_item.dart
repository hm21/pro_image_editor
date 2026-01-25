import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/text_editor_configs.dart';
import '/core/models/layers/text_layer.dart';
import '../../../../features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';

/// A widget representing a text layer in the sticker editor.
class LayerWidgetTextItem extends StatelessWidget {
  /// Creates a [LayerWidgetTextItem] with the given text layer and editor
  /// configurations.
  const LayerWidgetTextItem({
    super.key,
    required this.layer,
    required this.textEditorConfigs,
    required this.showMoveCursor,
    required this.onHitChanged,
  });

  /// The text layer represented by this widget.
  final TextLayer layer;

  /// Configuration settings for the text editor.
  final TextEditorConfigs textEditorConfigs;

  /// Notifies whether the move cursor should be shown.
  final ValueNotifier<bool> showMoveCursor;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit) onHitChanged;

  void _handleLayerHit(bool hasHit) {
    // Update hit detection and cursor visibility state.
    if (layer.hit != hasHit || showMoveCursor.value != hasHit) {
      layer.hit = hasHit;
      showMoveCursor.value = hasHit;
    }
    layer.hit = hasHit;
    onHitChanged(hasHit);
  }

  @override
  Widget build(BuildContext context) {
    var fontSize = textEditorConfigs.initFontSize * layer.scale;
    var style = TextStyle(
      fontSize: fontSize * layer.fontScale,
      color: layer.color,
      overflow: TextOverflow.ellipsis,
    );

    final maxTextWidth = layer.maxTextWidth;

    // Get the full style including shadows
    TextStyle finalStyle;
    if (layer.textStyle != null) {
      finalStyle = layer.textStyle!.copyWith(
        fontSize: style.fontSize,
        fontWeight: layer.textStyle!.fontWeight ?? style.fontWeight,
        color: style.color,
        fontFamily: layer.textStyle!.fontFamily ?? style.fontFamily,
        shadows: layer.textStyle!.shadows ?? style.shadows,
      );
    } else {
      finalStyle = style;
    }

    return RoundedBackgroundText(
      enableHitBoxCorrection: true,
      maxTextWidth:
          maxTextWidth == null ? double.infinity : maxTextWidth * layer.scale,
      onHitTestResult: _handleLayerHit,
      layer.text.toString(),
      backgroundColor: layer.background,
      textAlign: layer.align,
      style: finalStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
