import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';

/// Provides tilt editing state and callbacks to descendant widgets.
///
/// The [TiltProvider] is an [InheritedWidget] that holds the current tilt
/// values (rotation, vertical, and horizontal) as well as configuration
/// and callbacks for handling tilt changes.
///
/// This allows any widget in the tree to react to tilt interactions
/// without manually passing state down the widget tree.
class TiltProvider extends InheritedWidget {
  /// Creates a [TiltProvider] that exposes tilt editing state and callbacks.
  const TiltProvider({
    required super.child,
    required this.tiltRotate,
    required this.tiltVertical,
    required this.tiltHorizontal,
    required this.cropRotateConfigs,
    required this.i18n,
    required this.isTiltEditorVisible,
    required this.tiltMode,
    required this.tiltResetCount,
    required this.onTiltChangeUpdate,
    required this.onTiltChangeEnd,
    required this.onToggleTiltBar,
    required this.onUpdateResetCount,
    super.key,
  });

  /// The current rotation angle applied during tilt interaction.
  final double tiltRotate;

  /// The current vertical tilt value (up/down).
  final double tiltVertical;

  /// The current horizontal tilt value (left/right).
  final double tiltHorizontal;

  /// Called while the tilt value is changing. Provides the active [TiltMode]
  /// and the updated tilt [value].
  final Function(TiltMode mode, double value) onTiltChangeUpdate;

  /// Called when the tilt gesture ends. Provides the last active [TiltMode]
  /// and the final tilt [value].
  final Function(TiltMode mode, double value) onTiltChangeEnd;

  /// Called when toggling the tilt editor visibility.
  ///
  /// [isVisible] is `true` if the tilt editor should be shown,
  /// or `false` if it should be hidden.
  final Function(bool isVisible) onToggleTiltBar;

  /// Called when the tilt reset count should be updated.
  ///
  /// Typically used to track how many times the tilt has been reset.
  final Function() onUpdateResetCount;

  /// Configuration settings for crop and rotate operations.
  final CropRotateEditorConfigs cropRotateConfigs;

  /// Shortcut to the tilt-specific configuration from [cropRotateConfigs].
  TiltConfigs get tiltConfigs => cropRotateConfigs.tiltConfigs;

  /// Provides localized strings for tooltips and labels.
  final I18nCropRotateEditor i18n;

  /// Whether the tilt editor is currently visible.
  final bool isTiltEditorVisible;

  /// The currently active tilt mode (rotate, horizontal, vertical).
  final TiltMode tiltMode;

  /// Counter for how many times tilt has been reset.
  final int tiltResetCount;

  /// Returns the nearest [TiltProvider] up the widget tree.
  ///
  /// Throws if no [TiltProvider] is found.
  static TiltProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TiltProvider>()!;
  }

  /// Returns the nearest [TiltProvider] up the widget tree, or `null`
  /// if none is found.
  static TiltProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TiltProvider>();
  }

  /// Sets the visibility state of the tilt editor.
  void setTiltEditorState(bool value) {
    onToggleTiltBar(value);
  }

  /// Applies the current tilt value for the given [mode].
  ///
  /// Invokes [onTiltChangeUpdate] with the latest value.
  void setTiltMode(TiltMode mode) {
    switch (mode) {
      case TiltMode.rotate:
        onTiltChangeUpdate(mode, tiltRotate);
        break;
      case TiltMode.horizontal:
        onTiltChangeUpdate(mode, tiltHorizontal);
        break;
      case TiltMode.vertical:
        onTiltChangeUpdate(mode, tiltVertical);
        break;
    }
  }

  /// Resets all tilt values back to `0`.
  ///
  /// Invokes [onTiltChangeUpdate] and [onTiltChangeEnd] accordingly,
  /// then increments the reset counter via [onUpdateResetCount].
  void reset() {
    onTiltChangeUpdate(TiltMode.rotate, 0);
    onTiltChangeUpdate(TiltMode.horizontal, 0);
    onTiltChangeUpdate(TiltMode.vertical, 0);
    onTiltChangeEnd(tiltMode, 0);
    onUpdateResetCount();
  }

  @override
  bool updateShouldNotify(covariant TiltProvider oldWidget) {
    return tiltMode != oldWidget.tiltMode ||
        isTiltEditorVisible != oldWidget.isTiltEditorVisible ||
        tiltResetCount != oldWidget.tiltResetCount;
  }
}
