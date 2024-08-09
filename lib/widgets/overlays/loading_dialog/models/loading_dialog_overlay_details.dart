import 'package:flutter/material.dart';
import 'package:pro_image_editor/widgets/overlays/loading_dialog/animations/loading_dialog_base_animation.dart';

/// A class that encapsulates details for a loading overlay.
///
/// This class manages the configuration and state of a loading overlay,
/// including its entry, dismissibility, and associated animations.
class LoadingOverlayDetails {
  /// Creates an instance of [LoadingOverlayDetails].
  ///
  /// The constructor initializes the overlay entry, dismissibility, and
  /// animation key for managing the loading overlay's behavior and appearance.
  ///
  /// Example:
  /// ```
  /// LoadingOverlayDetails(
  ///   entry: myOverlayEntry,
  ///   isDismissible: true,
  ///   animationKey: GlobalKey<LoadingDialogOverlayAnimationState>(),
  /// )
  /// ```
  LoadingOverlayDetails({
    required this.entry,
    required this.isDismissible,
    required this.animationKey,
  });

  /// The overlay entry associated with this overlay.
  ///
  /// This [OverlayEntry] represents the widget that is inserted into the
  /// overlay, controlling its visibility and interactions.
  OverlayEntry entry;

  /// Determines if the overlay is dismissible.
  ///
  /// This boolean flag specifies whether the overlay can be dismissed by user
  /// interactions, allowing for flexible control over its persistence.
  bool isDismissible;

  /// A global key for the opacity animation state.
  ///
  /// This [GlobalKey] is used to manage the state of the opacity animation for
  /// the loading overlay, enabling smooth visual transitions.
  GlobalKey<LoadingDialogOverlayAnimationState> animationKey;
}
