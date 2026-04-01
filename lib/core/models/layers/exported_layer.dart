import 'dart:typed_data';
import 'dart:ui';

import 'layer.dart';

/// Contains one exported layer with its encoded bytes and layout metadata.
class ExportedLayer {
  /// Creates an [ExportedLayer] instance.
  const ExportedLayer({
    required this.layer,
    required this.bytes,
    required this.logicalSize,
  });

  /// The source layer that was exported.
  final Layer layer;

  /// Encoded image bytes for this layer.
  final Uint8List bytes;

  /// The logical size of the layer's content as laid out in the widget tree.
  ///
  /// This already includes the layer's scale factor (text layers bake it into
  /// font size, paint layers into the canvas size, etc.), so it matches the
  /// unrotated size the layer occupies in the editor.
  final Size logicalSize;
}
