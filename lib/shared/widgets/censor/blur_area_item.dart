import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'abstract/censor_area_item.dart';
import 'constants/censor_backdrop_key.dart';

/// A widget that applies a blur effect to a defined area.
///
/// This class extends [CensorAreaItem] and implements the blur effect
/// using a [BackdropFilter] with a blur filter. The intensity of the blur
/// is controlled by the [CensorConfigs] properties [blurSigmaX] and
/// [blurSigmaY].
class BlurAreaItem extends CensorAreaItem {
  /// Creates a [BlurAreaItem] with the specified [censorConfigs] and
  /// optional [size].
  const BlurAreaItem({
    super.key,
    required super.censorConfigs,
    super.size,
    super.strength,
  });

  /// Builds a [BackdropFilter] that applies a blur effect based on the provided
  /// [censorConfigs].
  ///
  /// The blur intensity is controlled by [censorConfigs.blurSigmaX] and
  /// [censorConfigs.blurSigmaY].
  @override
  Widget buildBackdropFilter({
    required Widget child,
    required BuildContext context,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: strength ?? censorConfigs.blurSigmaX,
        sigmaY: strength ?? censorConfigs.blurSigmaY,
      ),
      blendMode: censorConfigs.blurBlendMode,
      backdropGroupKey: kCensorBackdropGroupKey,
      child: child,
    );
  }
}
