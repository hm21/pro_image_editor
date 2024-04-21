import 'package:flutter/material.dart';
import '../../pro_image_editor.dart';
import '../crop_rotate_editor/transform_factors.dart';
import '../history/filter_state_history.dart';
import '../layer.dart';

/// Configuration class for initializing the image editor.
///
/// This class holds various configurations needed to initialize the image editor.
abstract class EditorInitConfigs {
  /// The configuration options for the image editor.
  final ProImageEditorConfigs configs;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// The size of the image with layers applied.
  final Size imageSizeWithLayers;

  /// The size of the body with layers applied.
  final Size bodySizeWithLayers;

  /// The list of applied filter history.
  final List<FilterStateHistory> appliedFilters;

  /// The applied blur factor.
  final double appliedBlurFactor;

  /// The transformation configurations for the editor.
  final TransformConfigs? transformConfigs;

  /// The theme data for the editor.
  final ThemeData theme;

  /// The layers in the editor.
  final List<Layer>? layers;

  /// Creates a new instance of [EditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [configs] parameter specifies the configuration options for the image editor.
  /// The [onUpdateUI] parameter is a callback function that can be used to update the UI from custom widgets.
  /// The [imageSizeWithLayers] parameter specifies the size of the image with layers applied.
  /// The [bodySizeWithLayers] parameter specifies the size of the body with layers applied.
  /// The [appliedFilters] parameter specifies the list of applied filter history.
  /// The [appliedBlurFactor] parameter specifies the applied blur factor.
  /// The [transformConfigs] parameter specifies the transformation configurations for the editor.
  /// The [layers] parameter specifies the layers in the editor.
  const EditorInitConfigs({
    required this.theme,
    this.configs = const ProImageEditorConfigs(),
    this.onUpdateUI,
    this.imageSizeWithLayers = Size.zero,
    this.bodySizeWithLayers = Size.zero,
    this.transformConfigs,
    this.appliedFilters = const [],
    this.appliedBlurFactor = 0,
    this.layers,
  });
}
