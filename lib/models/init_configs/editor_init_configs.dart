// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/types/filter_matrix.dart';
import '../../pro_image_editor.dart';
import '../crop_rotate_editor/transform_factors.dart';
import '../tune_editor/tune_adjustment_matrix.dart';

/// Configuration class for initializing the image editor.
///
/// This class holds various configurations needed to initialize the image
/// editor.
abstract class EditorInitConfigs {
  /// Creates a new instance of [EditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [configs] parameter specifies the configuration options for the image
  /// editor.
  /// The [callbacks] parameter specifies the callback options for the image
  /// editor.
  /// The [mainImageSize] parameter specifies the size of the image with layers
  /// applied.
  /// The [mainBodySize] parameter specifies the size of the body with layers
  /// applied.
  /// The [appliedFilters] parameter specifies the list of applied filters.
  /// The [appliedBlurFactor] parameter specifies the applied blur factor.
  /// The [transformConfigs] parameter specifies the transformation
  /// configurations for the editor.
  /// The [layers] parameter specifies the layers in the editor.
  const EditorInitConfigs({
    required this.theme,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
    this.mainImageSize,
    this.mainBodySize,
    this.transformConfigs,
    this.appliedFilters = const [],
    this.appliedTuneAdjustments = const [],
    this.appliedBlurFactor = 0,
    this.layers,
    this.onCloseEditor,
    this.onImageEditingComplete,
    this.onImageEditingStarted,
    this.convertToUint8List = false,
  });

  /// The configuration options for the image editor.
  final ProImageEditorConfigs configs;

  /// The callbacks for the image editor.
  final ProImageEditorCallbacks callbacks;

  /// The size of the image in the main editor.
  final Size? mainImageSize;

  /// The size of the body with layers applied.
  final Size? mainBodySize;

  /// The list of applied filters.
  final FilterMatrix appliedFilters;

  /// The list of applied tune adjustments.
  final List<TuneAdjustmentMatrix> appliedTuneAdjustments;

  /// The applied blur factor.
  final double appliedBlurFactor;

  /// The transformation configurations for the editor.
  final TransformConfigs? transformConfigs;

  /// The theme data for the editor.
  final ThemeData theme;

  /// The layers in the editor.
  final List<Layer>? layers;

  /// Determines whether to return the image as a Uint8List when closing the
  /// editor.
  final bool convertToUint8List;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a `Uint8List` with the format `jpg`.
  ///
  /// The edited image is provided as a Uint8List to the
  /// [onImageEditingComplete] function when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px"/>
  final ImageEditingCompleteCallback? onImageEditingComplete;

  /// A callback function that is triggered when the image generation is
  /// started.
  final Function()? onImageEditingStarted;

  /// A callback function that will be called before the image editor will
  /// close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  final ImageEditingEmptyCallback? onCloseEditor;
}
