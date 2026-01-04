// ignore_for_file: deprecated_member_use_from_same_package
// TODO: Remove the deprecated values when releasing version 12.0.0.

import 'package:flutter/widgets.dart';

import '/core/models/layers/layer.dart';
import '../icons/sticker_editor_icons.dart';
import '../styles/sticker_editor_style.dart';
import 'utils/base_editor_layer_configs.dart';
import 'utils/base_sub_editor_configs.dart';
export '../icons/sticker_editor_icons.dart';
export '../styles/sticker_editor_style.dart';

/// Configuration options for a sticker editor.
///
/// `StickerEditorConfigs` allows you to define various settings for a sticker
/// editor. You can configure features like enabling/disabling the editor,
/// initial sticker width, and a custom method to build stickers.
///
/// Example usage:
/// ```dart
/// StickerEditorConfigs(
///   enabled: false,
///   initWidth: 150,
///   buildStickers: (setLayer) {
///     return Container(); // Replace with your builder to load and display stickers.
///   },
/// );
/// ```
class StickerEditorConfigs
    implements BaseEditorLayerConfigs, BaseSubEditorConfigs {
  /// Creates an instance of StickerEditorConfigs with optional settings.
  ///
  /// By default, the editor is disabled (if not specified), and other
  /// properties are set to reasonable defaults.
  const StickerEditorConfigs({
    this.layerFractionalOffset = const Offset(-0.5, -0.5),
    this.enableGesturePop = true,
    this.builder,
    this.initWidth = 100,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    @Deprecated(
      'Use tools inside MainEditorConfigs instead, e.g. tools: '
      '[SubEditorMode.sticker]',
    )
    this.enabled = true,
    this.style = const StickerEditorStyle(),
    this.icons = const StickerEditorIcons(),
  })  : assert(initWidth > 0, 'initWidth must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');

  /// {@macro layerFractionalOffset}
  @override
  final Offset layerFractionalOffset;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Indicates whether the sticker editor is enabled.
  ///
  /// When set to `true`, the sticker editor is active and users can interact
  /// with it.
  /// If `false`, the editor is disabled and does not respond to user inputs.
  @Deprecated(
    'Use tools inside MainEditorConfigs instead, e.g. tools: '
    '[SubEditorMode.sticker]',
  )
  final bool enabled;

  /// The initial width of the stickers in the editor.
  ///
  /// Specifies the starting width of the stickers when they are first placed
  /// in the editor. This value is in logical pixels and is normally used as
  /// a fallback when no explicit width is provided.
  final double initWidth;

  /// A callback that builds the stickers.
  ///
  /// This typedef is a function that takes a function as a parameter and
  /// returns a Widget. The function parameter `setLayer` is used to set a
  /// layer in the editor. This callback allows for customizing the appearance
  /// and behavior of stickers in the editor.
  final StickerBuilder? builder;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Style configuration for the sticker editor.
  final StickerEditorStyle style;

  /// Icons used in the sticker editor.
  final StickerEditorIcons icons;

  /// Creates a copy of this `StickerEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [StickerEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  StickerEditorConfigs copyWith({
    Offset? layerFractionalOffset,
    bool? enableGesturePop,
    bool? enabled,
    double? initWidth,
    StickerBuilder? builder,
    double? minScale,
    double? maxScale,
    StickerEditorStyle? style,
    StickerEditorIcons? icons,
  }) {
    return StickerEditorConfigs(
      layerFractionalOffset:
          layerFractionalOffset ?? this.layerFractionalOffset,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      enabled: enabled ?? this.enabled,
      initWidth: initWidth ?? this.initWidth,
      builder: builder ?? this.builder,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      style: style ?? this.style,
      icons: icons ?? this.icons,
    );
  }
}

/// A typedef representing a function signature for building sticker widgets.
///
/// This typedef defines a function that builds a widget for stickers in an
/// editor, allowing customization of how stickers are displayed and
/// manipulated within the user interface.
typedef BuildStickers = Widget Function(
  Function(
    Widget widget, {
    WidgetLayerExportConfigs? exportConfigs,
  }) setLayer,
  ScrollController scrollController,
);

/// A typedef representing a function signature for building sticker widgets.
///
/// This typedef defines a function that builds a widget for stickers in an
/// editor, allowing customization of how stickers are displayed and
/// manipulated within the user interface.
typedef StickerBuilder = Widget Function(
  Function(WidgetLayer widgetLayer) setLayer,
  ScrollController scrollController,
);
