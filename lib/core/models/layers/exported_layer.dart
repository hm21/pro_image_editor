import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'layer.dart';
import 'text_layer_timeline.dart';

/// Contains one exported layer with its encoded bytes and layout metadata.
class ExportedLayer {
  /// Creates an [ExportedLayer] instance.
  const ExportedLayer({
    required this.layer,
    required this.bytes,
    required this.logicalSize,
    this.highlightBytes = const {},
    this.revealBytes = const {},
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

  /// Encoded images of a [TextLayer] whose text is only partly revealed by a
  /// [LayerAnimationType.typewriter] or [LayerAnimationType.wordByWord]
  /// animation, keyed by what each one shows. Every image has the size of
  /// [bytes], since the hidden text keeps its place.
  ///
  /// Empty for a layer without such an animation. Use [frames] to find out
  /// which image shows when.
  final Map<ExportedTextState, Uint8List> revealBytes;

  /// The images to show over the layer's time range, in order and without
  /// gaps: an image from [revealBytes] while the text is partly revealed,
  /// one from [highlightBytes] while a highlight is active, and [bytes] the
  /// rest of the time.
  ///
  /// The first frame starts at the layer's [Layer.startTime] and the last one
  /// ends at its [Layer.endTime]; either is `null` when the layer has none.
  /// A layer without highlights or reveals yields a single frame of [bytes].
  ///
  /// A video renderer that draws each frame as its own timed overlay shows the
  /// highlights and the reveal exactly as the editor previews them. The
  /// layer's other animations then have to keep counting from the layer's own
  /// range across all frames — in `pro_video_editor`, by giving every frame
  /// the layer's animations together with its range as
  /// `ImageLayer.animationStartTime` and `ImageLayer.animationEndTime`.
  ///
  /// A reveal is cut into frames at a resolution of one millisecond. A
  /// [AnimationPhase.loop] reveal on a layer without an [Layer.endTime]
  /// cannot be cut, as it never ends, and shows its whole text.
  List<ExportedLayerFrame> get frames {
    final layer = this.layer;
    final start = layer.startTime;
    final end = layer.endTime;
    if (layer is! TextLayer ||
        (highlightBytes.isEmpty && revealBytes.isEmpty)) {
      return [ExportedLayerFrame(bytes: bytes, startTime: start, endTime: end)];
    }

    final frames = <ExportedLayerFrame>[];
    for (final span in textLayerTimeline(
      layer,
      // The reveal images are keyed by the highlight they show as well, even
      // when no image of a highlight alone was captured.
      highlights:
          highlightBytes.isNotEmpty ||
          revealBytes.keys.any((state) => state.highlightIndex != null),
      reveals: revealBytes.isNotEmpty,
    )) {
      final frameBytes = _bytesFor(span.state);
      if (frames.isNotEmpty && identical(frames.last.bytes, frameBytes)) {
        frames.last = frames.last._extendedTo(span.endTime);
      } else {
        frames.add(
          ExportedLayerFrame(
            bytes: frameBytes,
            startTime: span.startTime,
            endTime: span.endTime,
          ),
        );
      }
    }
    return frames;
  }

  Uint8List _bytesFor(ExportedTextState state) {
    if (state.revealedLength != null) return revealBytes[state] ?? bytes;
    if (state.highlightIndex case final index?) {
      return highlightBytes[index] ?? bytes;
    }
    return bytes;
  }
}

/// What a [TextLayer] shows at one moment: how much of its text is revealed
/// and which of its highlights is active.
@immutable
class ExportedTextState {
  /// Creates a state with the first [revealedLength] UTF-16 code units of the
  /// text revealed and the highlight at [highlightIndex] active.
  const ExportedTextState({this.revealedLength, this.highlightIndex});

  /// How many UTF-16 code units of the text, from its start, show, or `null`
  /// when all of it does. See [TextLayer.revealedLengthAt].
  final int? revealedLength;

  /// The index of the active entry in [TextLayer.highlights], or `null` when
  /// none is active.
  final int? highlightIndex;

  @override
  bool operator ==(Object other) =>
      other is ExportedTextState &&
      other.revealedLength == revealedLength &&
      other.highlightIndex == highlightIndex;

  @override
  int get hashCode => Object.hash(revealedLength, highlightIndex);

  @override
  String toString() =>
      'ExportedTextState(revealedLength: $revealedLength, '
      'highlightIndex: $highlightIndex)';
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
