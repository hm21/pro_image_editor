// Project imports:
import '../crop_rotate_editor/transform_factors.dart';
import 'editor_init_configs.dart';

typedef CropRotateEditorDone = Function(
    TransformConfigs transformations, double fitToScreenFactor);

class CropRotateEditorInitConfigs extends EditorInitConfigs {
  /// A callback function called when editing is completed.
  final CropRotateEditorDone? onDone;

  /// Determines whether we draw a "fake" hero widget or not.
  /// If this is set to `true` we need to hide the fake hero by ourself like below
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
}
