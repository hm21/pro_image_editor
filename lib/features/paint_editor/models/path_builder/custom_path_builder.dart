import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';

export '../painted_model.dart';

/// A factory function for creating custom [PathBuilderBase] instances.
///
/// This typedef defines the signature for a custom path builder factory,
/// allowing users to provide their own path builders for specific paint modes
/// or custom drawing tools.
///
/// Parameters:
/// - [item]: The painted model containing all drawing information.
/// - [scale]: The scale factor for rendering.
/// - [paintEditorConfigs]: The paint editor configuration.
///
/// Returns a [PathBuilderBase] instance that will be used to build and
/// draw the path.
///
/// Example:
/// ```dart
/// PathBuilderBase myCustomBuilder({
///   required PaintedModel item,
///   required double scale,
///   required PaintEditorConfigs paintEditorConfigs,
/// }) {
///   return MyCustomPathBuilder(
///     item: item,
///     scale: scale,
///     paintEditorConfigs: paintEditorConfigs,
///   );
/// }
/// ```
typedef CustomPathBuilderFactory = PathBuilderBase Function({
  required PaintedModel item,
  required double scale,
  required PaintEditorConfigs paintEditorConfigs,
});
