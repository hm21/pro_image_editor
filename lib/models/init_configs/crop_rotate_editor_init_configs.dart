import '../crop_rotate_editor/transform_factors.dart';
import 'editor_init_configs.dart';

class CropRotateEditorInitConfigs extends EditorInitConfigs {
  /// Determines whether to return the image as a Uint8List when closing the editor.
  final bool convertToUint8List;

  ///TODO: doc
  final Function(TransformConfigs)? onDone;

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
    super.onUpdateUI,
    super.mainImageSize,
    super.mainBodySize,
    super.appliedFilters,
    super.appliedBlurFactor,
    required super.theme,
    this.onDone,
    this.convertToUint8List = false,
    this.enableFakeHero = false,
  });
}
