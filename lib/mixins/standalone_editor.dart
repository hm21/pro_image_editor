import 'package:flutter/material.dart';
import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/editor_image.dart';
import '../models/history/filter_state_history.dart';
import '../models/init_configs/editor_init_configs.dart';
import '../models/layer.dart';
import 'converted_configs.dart';

/// A mixin providing access to standalone editor configurations and image.
mixin StandaloneEditor<T extends EditorInitConfigs> {
  /// Returns the initialization configurations for the editor.
  T get initConfigs;

  /// Returns the editor image
  EditorImage get editorImage;
}

/// A mixin providing access to standalone editor configurations and image within a state.
mixin StandaloneEditorState<T extends StatefulWidget,
    I extends EditorInitConfigs> on State<T>, ImageEditorConvertedConfigs {
  /// Returns the initialization configurations for the editor.
  I get initConfigs => (widget as StandaloneEditor<I>).initConfigs;

  /// Returns the image being edited.
  EditorImage get editorImage => (widget as StandaloneEditor<I>).editorImage;

  @override
  ProImageEditorConfigs get configs => initConfigs.configs;

  /// Returns the theme data for the editor.
  ThemeData get theme => initConfigs.theme;

  /// Returns the transformation configurations for the editor.
  TransformConfigs? get transformConfigs => initConfigs.transformConfigs;

  /// Returns the layers in the editor.
  List<Layer>? get layers => initConfigs.layers;

  /// Returns the callback function to update the UI.
  Function? get onUpdateUI => initConfigs.onUpdateUI;

  /// Returns the applied blur factor.
  double get appliedBlurFactor => initConfigs.appliedBlurFactor;

  /// Returns the applied filters.
  List<FilterStateHistory> get appliedFilters => initConfigs.appliedFilters;

  /// Returns the body size with layers.
  Size get bodySizeWithLayers => initConfigs.bodySizeWithLayers;

  /// Returns the image size with layers.
  Size get imageSizeWithLayers => initConfigs.imageSizeWithLayers;
}
