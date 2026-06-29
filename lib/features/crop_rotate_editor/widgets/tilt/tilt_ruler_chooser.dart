import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/shared/extensions/double_extension.dart';
import '../../enums/tilt_mode_enum.dart';
import '../../providers/tilt_provider.dart';
import 'tilt_ruler.dart';

/// A widget that displays the appropriate [TiltRuler] depending
/// on the currently active [TiltMode].
///
/// The [TiltRulerChooser] listens to the [TiltProvider] and shows
/// either a rotate, horizontal, or vertical ruler.
///
/// It animates between visibility states using [AnimatedSwitcher]
/// and resets with a unique [ValueKey] whenever the tilt reset
/// counter changes, ensuring a fresh ruler state.
///
/// If the tilt editor is not visible, this widget collapses into
/// a [SizedBox] that fills the available width.
class TiltRulerChooser extends StatelessWidget {
  /// Creates a chooser that switches between rulers for rotate,
  /// horizontal, and vertical tilt editing.
  const TiltRulerChooser({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = TiltProvider.of(context);
    final configs = provider.cropRotateConfigs;
    return AnimatedSwitcher(
      duration: configs.animationDuration,
      switchInCurve: Curves.ease,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: TiltProvider.of(context).isTiltEditorVisible
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _buildRuler(context),
            )
          : const SizedBox(width: double.infinity),
    );
  }

  Widget _buildRuler(BuildContext context) {
    final provider = TiltProvider.of(context);
    final tiltMode = provider.tiltMode;
    final configs = provider.cropRotateConfigs;
    final tiltConfigs = provider.tiltConfigs;
    final resetCount = provider.tiltResetCount;

    return switch (tiltMode) {
      TiltMode.rotate => TiltRuler(
        key: ValueKey('Tilt-Ruler-Rotate-$resetCount'),
        value: provider.tiltRotate,
        min: tiltConfigs.tiltRotateMin.degToRad,
        max: tiltConfigs.tiltRotateMax.degToRad,
        configs: configs,
        onChangeUpdate: (val) => provider.onTiltChangeUpdate(tiltMode, val),
        onChangeEnd: (val) => provider.onTiltChangeEnd(tiltMode, val),
      ),
      TiltMode.horizontal => TiltRuler(
        key: ValueKey('Tilt-Ruler-Horizontal-$resetCount'),
        value: provider.tiltHorizontal,
        min: tiltConfigs.tiltHorizontalMin.degToRad,
        max: tiltConfigs.tiltHorizontalMax.degToRad,
        configs: configs,
        onChangeUpdate: (val) => provider.onTiltChangeUpdate(tiltMode, val),
        onChangeEnd: (val) => provider.onTiltChangeEnd(tiltMode, val),
      ),
      TiltMode.vertical => TiltRuler(
        key: ValueKey('Tilt-Ruler-Vertical-$resetCount'),
        value: provider.tiltVertical,
        min: tiltConfigs.tiltVerticalMin.degToRad,
        max: tiltConfigs.tiltVerticalMax.degToRad,
        configs: configs,
        onChangeUpdate: (val) => provider.onTiltChangeUpdate(tiltMode, val),
        onChangeEnd: (val) => provider.onTiltChangeEnd(tiltMode, val),
      ),
    };
  }
}
