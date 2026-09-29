import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'layer.dart';

/// Contains one exported layer with its encoded bytes and layout metadata.
class ExportedLayer {
  /// Creates an [ExportedLayer] instance.
  const ExportedLayer({
    required this.layer,
    required this.bytes,
    required this.logicalSize,
    this.highlightBytes = const {},
  });

  /// The source layer that was exported.
  final Layer layer;

  /// Encoded image bytes for this layer.
  ///
  /// For a [TextLayer] with [TextLayer.highlights] this is the text with no
  /// highlight active.
  final Uint8List bytes;

  /// The logical size of the layer's content as laid out in the widget tree.
  ///
  /// This already includes the layer's scale factor (text layers bake it into
  /// font size, paint layers into the canvas size, etc.), so it matches the
  /// unrotated size the layer occupies in the editor.
  final Size logicalSize;

  /// Encoded images of a [TextLayer] with one of its [TextLayer.highlights]
  /// active, keyed by the highlight's index. Every image has the size of
  /// [bytes], so it can stand in for it at the same position.
  ///
  /// Empty for any other layer. Use [frames] to find out which image shows
  /// when.
  final Map<int, Uint8List> highlightBytes;

  /// The images to show over the layer's time range, in order and without
  /// gaps: an image from [highlightBytes] while its highlight is active, and
  /// [bytes] the rest of the time.
  ///
  /// The first frame starts at the layer's [Layer.startTime] and the last one
  /// ends at its [Layer.endTime]; either is `null` when the layer has none.
  /// A layer without highlights yields a single frame of [bytes].
  ///
  /// A video renderer that draws each frame as its own timed overlay shows the
  /// highlights exactly as the editor previews them. Enter and leave
  /// animations then belong on the first and last frame respectively.
  List<ExportedLayerFrame> get frames {
    final layer = this.layer;
    final start = layer.startTime;
    final end = layer.endTime;
    if (layer is! TextLayer || highlightBytes.isEmpty) {
      return [ExportedLayerFrame(bytes: bytes, startTime: start, endTime: end)];
    }

    // Every highlight edge that falls inside the layer's range starts a new
    // interval; within one interval the active highlight cannot change.
    final origin = start ?? Duration.zero;
    final cuts =
        <Duration>{
              for (final highlight in layer.highlights)
                if (highlight.isValid) ...[
                  origin + highlight.startTime,
                  origin + highlight.endTime,
                ],
            }
            .where(
              (cut) =>
                  (start == null || cut > start) && (end == null || cut < end),
            )
            .toList()
          ..sort();

    final bounds = <Duration?>[start, ...cuts, end];
    final frames = <ExportedLayerFrame>[];
    for (var i = 0; i < bounds.length - 1; i++) {
      final from = bounds[i];
      final to = bounds[i + 1];
      // An interval open towards the past is probed just before its end.
      final probe =
          from ?? (to ?? Duration.zero) - const Duration(microseconds: 1);
      final index = layer.highlightIndexAt(probe);
      final frameBytes = index == null ? bytes : highlightBytes[index] ?? bytes;

      if (frames.isNotEmpty && identical(frames.last.bytes, frameBytes)) {
        frames.last = frames.last._extendedTo(to);
      } else {
        frames.add(
          ExportedLayerFrame(bytes: frameBytes, startTime: from, endTime: to),
        );
      }
    }
    return frames;
  }
}

/// One image of an [ExportedLayer] and the time range it shows for.
@immutable
class ExportedLayerFrame {
  /// Creates a frame showing [bytes] from [startTime] until [endTime].
  const ExportedLayerFrame({
    required this.bytes,
    required this.startTime,
    required this.endTime,
  });

  /// The encoded image to show.
  final Uint8List bytes;

  /// When the frame starts, on the same timeline as [Layer.startTime], or
  /// `null` when it starts with the video.
  final Duration? startTime;

  /// When the frame ends, on the same timeline as [Layer.endTime], or `null`
  /// when it lasts until the video ends.
  final Duration? endTime;

  ExportedLayerFrame _extendedTo(Duration? endTime) =>
      ExportedLayerFrame(bytes: bytes, startTime: startTime, endTime: endTime);

  @override
  String toString() =>
      'ExportedLayerFrame(${bytes.length} bytes, $startTime - $endTime)';
}
