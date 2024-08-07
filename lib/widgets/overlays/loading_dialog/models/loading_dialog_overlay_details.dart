import 'package:flutter/material.dart';
import 'package:pro_image_editor/widgets/overlays/loading_dialog/animations/loading_dialog_base_animation.dart';

class LoadingOverlayDetails {
  /// The overlay entry associated with this overlay.
  OverlayEntry entry;

  /// Determines if the overlay is dismissible.
  bool isDismissible;

  /// A global key for the opacity animation state.
  GlobalKey<LoadingDialogOverlayAnimationState> animationKey;

  LoadingOverlayDetails({
    required this.entry,
    required this.isDismissible,
    required this.animationKey,
  });
}
