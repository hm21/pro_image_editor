// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/types/filter_matrix.dart';

import '../../../models/tune_editor/tune_adjustment_matrix.dart';

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
  State<ColorFilterGenerator> createState() => _ColorFilterGeneratorState();
}

class _ColorFilterGeneratorState extends State<ColorFilterGenerator> {
  late Widget _filteredWidget;

  late FilterMatrix _tempFilters;
  late List<TuneAdjustmentMatrix> _tempTuneAdjustments;

  @override
  void initState() {
    _generateFilteredWidget();
    super.initState();
  }

  void _generateFilteredWidget() {
    Widget tree = widget.child;
    _tempFilters = widget.filters;
    _tempTuneAdjustments = widget.tuneAdjustments;

    var list = [
      ...widget.filters,
      ...widget.tuneAdjustments.map((item) => item.matrix),
    ];

    for (int i = 0; i < list.length; i++) {
      tree = ColorFiltered(
        colorFilter: ColorFilter.matrix(list[i]),
        child: tree,
      );
    }
    _filteredWidget = tree;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filters.hashCode != _tempFilters.hashCode ||
        widget.tuneAdjustments.hashCode != _tempTuneAdjustments.hashCode) {
      _generateFilteredWidget();
    }
    return _filteredWidget;
  }
}
