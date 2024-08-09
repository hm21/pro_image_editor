// Project imports:
import '../crop_rotate_editor/transform_factors.dart';
import 'editor_init_configs.dart';

/// A typedef representing a callback function signature for completing the
/// crop and rotate editing process.
///
/// This typedef defines a function that handles the completion of editing
/// transformations, passing the final transformation configurations and
/// fit-to-screen factor.
typedef CropRotateEditorDone = Function(
  TransformConfigs transformations,
  double fitToScreenFactor,
);

/// Configuration settings for initializing the Crop and Rotate Editor.
///
/// This class provides various configuration options for initializing the
/// crop and rotate editor, including callbacks, transformation settings, and
/// additional editor parameters.
class CropRotateEditorInitConfigs extends EditorInitConfigs {
  /// Creates an instance of [CropRotateEditorInitConfigs].
  ///
  /// This constructor allows customization of the crop and rotate editor
  /// initialization by setting transformation configurations, layers,
  /// callbacks, and other editor-related settings.
  ///
  /// Example:
  /// ```
  /// CropRotateEditorInitConfigs(
  ///   configs: myConfigs,
  ///   transformConfigs: myTransformConfigs,
  ///   layers: myLayers,
  ///   callbacks: myCallbacks,
  ///   theme: myTheme,
  ///   onDone: (transformations, fitToScreenFactor) {
  ///     // Handle the done action
  ///   },
  /// )
  /// ```
  const CropRotateEditorInitConfigs({
    super.configs,
    super.transformConfigs,
    super.layers,
    super.callbacks,
    super.mainImageSize,
    super.mainBodySize,
    super.appliedFilters,
    super.appliedBlurFactor,
    super.onCloseEditor,
    super.onImageEditingComplete,
    super.onImageEditingStarted,
    super.convertToUint8List,
    required super.theme,
    this.onDone,
    this.enableFakeHero = false,
  });

  /// A callback function called when editing is completed.
  final CropRotateEditorDone? onDone;

  /// Determines whether we draw a "fake" hero widget or not.
  /// If this is set to `true` we need to hide the fake hero by ourself like
  /// below
  /// ```dart
  /// return Navigator.push<T?>(
  ///   context,
  ///   PageRouteBuilder(
  ///     opaque: false,
  ///     transitionDuration: duration,
  ///     reverseTransitionDuration: duration,
  ///     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  ///       return FadeTransition(
  ///         opacity: animation,
  ///         child: child,
  ///       );
  ///     },
  ///     pageBuilder: (context, animation, secondaryAnimation) {
  ///       void animationStatusListener(AnimationStatus status) {
  ///         if (status == AnimationStatus.completed) {
  ///           if (cropRotateEditor.currentState != null) {
  ///             /// Remove the fake hero like that
  ///             cropRotateEditor.currentState!.hideFakeHero();
  ///           }
  ///         } else if (status == AnimationStatus.dismissed) {
  ///           animation.removeStatusListener(animationStatusListener);
  ///         }
  ///       }
  ///       animation.addStatusListener(animationStatusListener);
  ///       return page;
  ///     },
  ///   ),
  /// );
  /// ```
  final bool enableFakeHero;
}
