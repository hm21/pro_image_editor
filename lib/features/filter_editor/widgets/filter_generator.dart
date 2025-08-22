// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../tune_editor/models/tune_adjustment_matrix.dart';
import '../types/filter_matrix.dart';
import '../utils/combine_color_matrix_utils.dart';

/// A widget for applying color filters to its child widget.
class ColorFilterGenerator extends StatefulWidget {
  /// Constructor for creating an instance of ColorFilterGenerator.
  const ColorFilterGenerator({
    super.key,
    required this.filters,
    required this.tuneAdjustments,
    required this.child,
  });

  /// The matrix of filters to apply.
  final FilterMatrix filters;

  /// The matrix of tune adjustments to apply.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The child widget to which the filters are applied.
  final Widget child;

  /// Creates the state for the ColorFilterGenerator widget.
  @override
  State<ColorFilterGenerator> createState() => ColorFilterGeneratorState();
}

/// The state class for the `ColorFilterGenerator` widget.
///
/// This class is responsible for managing the state of the
/// `ColorFilterGenerator` widget, which includes handling the generation and
/// application of color filters.
///
/// It extends the `State` class, which means it holds mutable state for the
/// `ColorFilterGenerator` widget.
class ColorFilterGeneratorState extends State<ColorFilterGenerator> {
  late List<double> _combinedMatrix;

  @override
  void initState() {
    super.initState();
    _recomputeMatrix();
  }

  @override
  void didUpdateWidget(covariant ColorFilterGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters.hashCode != widget.filters.hashCode ||
        oldWidget.tuneAdjustments.hashCode != widget.tuneAdjustments.hashCode) {
      _recomputeMatrix();
    }
  }

  /// Refreshes the filter editor by generating the filtered widget and
  /// updating the state.
  void refresh() {
    _recomputeMatrix();
    setState(() {});
  }

  void _recomputeMatrix() {
    _combinedMatrix = mergeColorMatrices(
      filterList: widget.filters,
      tuneAdjustmentList:
          widget.tuneAdjustments.map((item) => item.matrix).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_combinedMatrix),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<FilterMatrix>('filters', widget.filters))
      ..add(IterableProperty<TuneAdjustmentMatrix>(
          'tuneAdjustments', widget.tuneAdjustments))
      ..add(
          DiagnosticsProperty<List<double>>('combinedMatrix', _combinedMatrix));
  }
}
