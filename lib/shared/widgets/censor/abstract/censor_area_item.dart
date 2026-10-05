import 'package:flutter/widgets.dart';
import '/core/models/editor_configs/paint_editor/censor_configs.dart';

/// An abstract widget that represents a censored area with configurable
/// blur intensity and shape.
///
/// This widget is designed to be extended and provides a flexible structure
/// for applying a censoring effect using a [BackdropFilter]. It allows the
/// area to be clipped into an oval or rectangle shape based on
/// [CensorConfigs.enableRoundArea].
///
/// Subclasses must implement [buildBackdropFilter] to define the filtering
/// effect.
abstract class CensorAreaItem extends StatelessWidget {
  /// Creates a [CensorAreaItem] with the specified [censorConfigs] and
  /// optional [size].
  ///
  /// If [size] is `null`, the widget expands to fit its parent.
  const CensorAreaItem({
    super.key,
    required this.censorConfigs,
    this.size,
    this.strength,
  });

  /// The dimensions of the censored area.
  ///
  /// If `null`, the widget will expand to fill the available space.
  final Size? size;

  /// Configuration for the censoring effect, including blur intensity and
  /// shape.
  final CensorConfigs censorConfigs;

  /// The strength of this area, overriding the one in [censorConfigs]; see
  /// `PaintedModel.censorStrength`.
  final double? strength;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        /// Important to absorb events here as there is no hitTesting which
        /// will absorb it.
      },
      child: _buildClipper(
        child: buildBackdropFilter(context: context, child: _buildArea()),
      ),
    );
  }

  /// Builds a [BackdropFilter] to apply the censoring effect.
  ///
  /// Subclasses must implement this method to define how the filter is applied.
  Widget buildBackdropFilter({
    required Widget child,
    required BuildContext context,
  });

  /// Clips the censoring area to either an oval or a rounded rectangle,
  /// depending on the configuration in [censorConfigs].
  Widget _buildClipper({required Widget child}) {
    if (censorConfigs.enableRoundArea) {
      return ClipOval(child: child);
    }
    return ClipRRect(child: child);
  }

  /// Creates a container with the specified [size], or expands to fill its
  /// parent.
  Widget _buildArea() {
    if (size != null) {
      return SizedBox(width: size!.width, height: size!.height);
    }
    return const SizedBox.expand();
  }
}
