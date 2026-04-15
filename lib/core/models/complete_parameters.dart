import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '/features/audio_editor/models/audio_track.dart';
import '/features/clips_editor/models/video_clip.dart';
import '/features/filter_editor/types/filter_state.dart';
import '/features/filter_editor/utils/combine_color_matrix_utils.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import 'layers/exported_layer.dart';
import 'layers/layer.dart';

/// A data class that contains all parameters needed for applying visual
/// transformations and filters to a video frame or image.
///
/// Includes cropping, rotation, flipping, blur, and color adjustments.
class CompleteParameters {
  /// Creates a [CompleteParameters] instance from a [Map].
  ///
  /// Useful for deserialization from storage or network responses.
  factory CompleteParameters.fromMap(Map<String, dynamic> map) {
    return CompleteParameters(
      blur: map['blur']?.toDouble() ?? 0.0,
      matrixFilterList: List<List<double>>.from(
        map['matrixFilterList']?.map((x) => List<double>.from(x)) ?? [],
      ),
      matrixTuneAdjustmentsList: List<List<double>>.from(
        map['matrixTuneAdjustmentsList']?.map((x) => List<double>.from(x)) ??
            [],
      ),
      startTime: map['startTime'] != null
          ? Duration(microseconds: map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? Duration(microseconds: map['endTime'])
          : null,
      cropWidth: map['cropWidth']?.toInt(),
      cropHeight: map['cropHeight']?.toInt(),
      rotateTurns: map['rotateTurns']?.toInt() ?? 0,
      cropX: map['cropX']?.toInt(),
      cropY: map['cropY']?.toInt(),
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      image: Uint8List.fromList(List<int>.from(map['image'] ?? [])),
      isTransformed: map['isTransformed'] ?? false,
      layers: List<Layer>.from(
        map['layers']?.map((x) => Layer.fromMap(x)) ?? [],
      ),
      originalImageSize: map['originalImageSize'] != null
          ? Size(
              (map['originalImageSize']['width'] as num).toDouble(),
              (map['originalImageSize']['height'] as num).toDouble(),
            )
          : null,
      temporaryDecodedImageSize: map['temporaryDecodedImageSize'] != null
          ? Size(
              (map['temporaryDecodedImageSize']['width'] as num).toDouble(),
              (map['temporaryDecodedImageSize']['height'] as num).toDouble(),
            )
          : null,
      bodySize: map['bodySize'] != null
          ? Size(
              (map['bodySize']['width'] as num).toDouble(),
              (map['bodySize']['height'] as num).toDouble(),
            )
          : null,
      editorSize: map['editorSize'] != null
          ? Size(
              (map['editorSize']['width'] as num).toDouble(),
              (map['editorSize']['height'] as num).toDouble(),
            )
          : null,
      meta: Map<String, dynamic>.from(map['meta'] ?? {}),
    );
  }

  /// Creates a [CompleteParameters] instance from a JSON string.
  factory CompleteParameters.fromJson(String source) =>
      CompleteParameters.fromMap(json.decode(source));

  /// Creates a [CompleteParameters] instance with all required values.
  CompleteParameters({
    required this.blur,
    required this.matrixFilterList,
    required this.matrixTuneAdjustmentsList,
    required this.startTime,
    required this.endTime,
    required this.cropWidth,
    required this.cropHeight,
    required this.rotateTurns,
    required this.cropX,
    required this.cropY,
    required this.flipX,
    required this.flipY,
    required this.image,
    required this.isTransformed,
    required this.layers,
    this.filterStates = const [],
    this.tuneAdjustments = const [],
    this.capturedLayers = const [],
    this.videoClips = const [],
    @Deprecated('Use audioTracks instead') this.customAudioTrack,
    this.audioTracks = const [],
    required this.originalImageSize,
    required this.temporaryDecodedImageSize,
    required this.bodySize,
    required this.editorSize,
    this.meta = const {},
  });

  /// The blur strength to apply (in logical pixels).
  final double blur;

  /// List of color filter matrices (e.g. sepia, noir).
  final List<List<double>> matrixFilterList;

  /// List of color tuning adjustment matrices (e.g. brightness, contrast).
  final List<List<double>> matrixTuneAdjustmentsList;

  /// All active color filters including both tuning and filter matrices.
  List<List<double>> get colorFilters => [
    ...matrixTuneAdjustmentsList,
    ...matrixFilterList,
  ];

  /// Combined color filter matrix from all filters and adjustments.
  List<double> get colorFiltersCombined {
    return mergeColorMatrices(
      filterList: matrixFilterList,
      tuneAdjustmentList: matrixTuneAdjustmentsList,
    );
  }

  /// The time where processing should start.
  final Duration? startTime;

  /// The time where processing should end.
  final Duration? endTime;

  /// The target crop width in pixels (optional).
  final int? cropWidth;

  /// The target crop height in pixels (optional).
  final int? cropHeight;

  /// Number of clockwise 90° rotations to apply.
  final int rotateTurns;

  /// The horizontal crop offset (optional).
  final int? cropX;

  /// The vertical crop offset (optional).
  final int? cropY;

  /// Whether to flip the image horizontally.
  final bool flipX;

  /// Whether to flip the image vertically.
  final bool flipY;

  /// The image data as a [Uint8List].
  final Uint8List image;

  /// Whether the video has any transformation (e.g. crop, scale, rotate, flip).
  /// This flag is typically used to optimize rendering or skip transformation
  /// logic when it's not needed.
  final bool isTransformed;

  /// A list of visual layers (e.g. text, stickers, overlays) that should be
  /// rendered on top of the video during export.
  final List<Layer> layers;

  /// The active filter states with their timeline metadata.
  ///
  /// Each [FilterState] contains the filter matrices and optional
  /// video-timeline metadata (startTime, endTime, enter/exit transitions).
  final List<FilterState> filterStates;

  /// The active tune adjustments with their timeline metadata.
  ///
  /// Each [TuneAdjustmentMatrix] contains the adjustment matrix and optional
  /// video-timeline metadata (startTime, endTime, enter/exit transitions).
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The captured layer images, if [MainEditorConfigs.captureLayersOnDone]
  /// was enabled.
  ///
  /// Each [ExportedLayer] contains the layer metadata, its rendered image
  /// bytes, and its logical size.
  final List<ExportedLayer> capturedLayers;

  /// The list of video clips currently included in the editor timeline.
  ///
  /// Each [VideoClip] represents a segment of video with its own
  /// source, duration, and transformation settings.
  final List<VideoClip> videoClips;

  /// An optional custom audio track to overlay on top of the video clips.
  ///
  /// When provided, this [AudioTrack] replaces or mixes with the
  /// original audio from the video sources depending on the editor settings.
  @Deprecated('Use audioTracks instead')
  final AudioTrack? customAudioTrack;

  /// The list of custom audio tracks to overlay on top of the video clips.
  ///
  /// When provided, these [AudioTrack]s replace or mix with the
  /// original audio from the video sources depending on the editor settings.
  final List<AudioTrack> audioTracks;

  /// The raw original image size before any scaling or cropping.
  final Size? originalImageSize;

  /// A temporary decoded image size used during screen resizing.
  final Size? temporaryDecodedImageSize;

  /// The size of the editor body area.
  final Size? bodySize;

  /// The overall size of the editor widget.
  final Size? editorSize;

  /// Custom metadata associated with the current editor state.
  final Map<String, dynamic> meta;

  /// Creates a copy of this [CompleteParameters] object with optional new
  /// values for specific fields.
  CompleteParameters copyWith({
    double? blur,
    List<List<double>>? matrixFilterList,
    List<List<double>>? matrixTuneAdjustmentsList,
    List<FilterState>? filterStates,
    List<TuneAdjustmentMatrix>? tuneAdjustments,
    List<ExportedLayer>? capturedLayers,
    Duration? startTime,
    Duration? endTime,
    int? cropWidth,
    int? cropHeight,
    int? rotateTurns,
    int? cropX,
    int? cropY,
    bool? flipX,
    bool? flipY,
    Uint8List? image,
    bool? isTransformed,
    List<Layer>? layers,
    List<VideoClip>? videoClips,
    @Deprecated('Use audioTracks instead') AudioTrack? customAudioTrack,
    List<AudioTrack>? audioTracks,
    Size? originalImageSize,
    Size? temporaryDecodedImageSize,
    Size? bodySize,
    Size? editorSize,
    Map<String, dynamic>? meta,
  }) {
    return CompleteParameters(
      blur: blur ?? this.blur,
      matrixFilterList: matrixFilterList ?? this.matrixFilterList,
      matrixTuneAdjustmentsList:
          matrixTuneAdjustmentsList ?? this.matrixTuneAdjustmentsList,
      filterStates: filterStates ?? this.filterStates,
      tuneAdjustments: tuneAdjustments ?? this.tuneAdjustments,
      capturedLayers: capturedLayers ?? this.capturedLayers,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cropWidth: cropWidth ?? this.cropWidth,
      cropHeight: cropHeight ?? this.cropHeight,
      rotateTurns: rotateTurns ?? this.rotateTurns,
      cropX: cropX ?? this.cropX,
      cropY: cropY ?? this.cropY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      image: image ?? this.image,
      isTransformed: isTransformed ?? this.isTransformed,
      layers: layers ?? this.layers,
      videoClips: videoClips ?? this.videoClips,
      // ignore: deprecated_member_use_from_same_package
      customAudioTrack: customAudioTrack ?? this.customAudioTrack,
      audioTracks: audioTracks ?? this.audioTracks,
      originalImageSize: originalImageSize ?? this.originalImageSize,
      temporaryDecodedImageSize:
          temporaryDecodedImageSize ?? this.temporaryDecodedImageSize,
      bodySize: bodySize ?? this.bodySize,
      editorSize: editorSize ?? this.editorSize,
      meta: meta ?? this.meta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CompleteParameters &&
        other.blur == blur &&
        listEquals(other.matrixFilterList, matrixFilterList) &&
        listEquals(
          other.matrixTuneAdjustmentsList,
          matrixTuneAdjustmentsList,
        ) &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.cropWidth == cropWidth &&
        other.cropHeight == cropHeight &&
        other.rotateTurns == rotateTurns &&
        other.cropX == cropX &&
        other.cropY == cropY &&
        other.flipX == flipX &&
        other.flipY == flipY &&
        other.image == image &&
        other.isTransformed == isTransformed &&
        other.videoClips == videoClips &&
        // ignore: deprecated_member_use_from_same_package
        other.customAudioTrack == customAudioTrack &&
        listEquals(other.audioTracks, audioTracks) &&
        other.originalImageSize == originalImageSize &&
        other.temporaryDecodedImageSize == temporaryDecodedImageSize &&
        other.bodySize == bodySize &&
        other.editorSize == editorSize &&
        mapEquals(other.meta, meta) &&
        listEquals(other.layers, layers);
  }

  @override
  int get hashCode {
    return blur.hashCode ^
        matrixFilterList.hashCode ^
        matrixTuneAdjustmentsList.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        cropWidth.hashCode ^
        cropHeight.hashCode ^
        rotateTurns.hashCode ^
        cropX.hashCode ^
        cropY.hashCode ^
        flipX.hashCode ^
        flipY.hashCode ^
        image.hashCode ^
        isTransformed.hashCode ^
        videoClips.hashCode ^
        // ignore: deprecated_member_use_from_same_package
        customAudioTrack.hashCode ^
        audioTracks.hashCode ^
        originalImageSize.hashCode ^
        temporaryDecodedImageSize.hashCode ^
        bodySize.hashCode ^
        editorSize.hashCode ^
        meta.hashCode ^
        layers.hashCode;
  }

  /// Converts this [CompleteParameters] instance to a [Map].
  ///
  /// Useful for serialization and storage purposes.
  Map<String, dynamic> toMap() {
    return {
      'blur': blur,
      'matrixFilterList': matrixFilterList,
      'matrixTuneAdjustmentsList': matrixTuneAdjustmentsList,
      'startTime': startTime?.inMicroseconds,
      'endTime': endTime?.inMicroseconds,
      'cropWidth': cropWidth,
      'cropHeight': cropHeight,
      'rotateTurns': rotateTurns,
      'cropX': cropX,
      'cropY': cropY,
      'flipX': flipX,
      'flipY': flipY,
      'image': image.toList(),
      'isTransformed': isTransformed,
      'layers': layers.map((x) => x.toMap()).toList(),
      if (originalImageSize != null)
        'originalImageSize': {
          'width': originalImageSize!.width,
          'height': originalImageSize!.height,
        },
      if (temporaryDecodedImageSize != null)
        'temporaryDecodedImageSize': {
          'width': temporaryDecodedImageSize!.width,
          'height': temporaryDecodedImageSize!.height,
        },
      if (bodySize != null)
        'bodySize': {'width': bodySize!.width, 'height': bodySize!.height},
      if (editorSize != null)
        'editorSize': {
          'width': editorSize!.width,
          'height': editorSize!.height,
        },
      'meta': meta,
    };
  }

  /// Converts this [CompleteParameters] instance to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'CompleteParameters(blur: $blur, '
        'matrixFilterList: $matrixFilterList, '
        'matrixTuneAdjustmentsList: $matrixTuneAdjustmentsList, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'cropWidth: $cropWidth, '
        'cropHeight: $cropHeight, '
        'rotateTurns: $rotateTurns, '
        'cropX: $cropX, '
        'cropY: $cropY, '
        'flipX: $flipX, '
        'flipY: $flipY, '
        'image: $image, '
        'isTransformed: $isTransformed, '
        'originalImageSize: $originalImageSize, '
        'temporaryDecodedImageSize: $temporaryDecodedImageSize, '
        'bodySize: $bodySize, '
        'editorSize: $editorSize, '
        'meta: $meta, '
        'layers: $layers)';
  }
}
