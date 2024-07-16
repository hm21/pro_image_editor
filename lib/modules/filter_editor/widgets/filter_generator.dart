// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/types/filter_matrix.dart';

class ColorFilterGenerator extends StatefulWidget {
  final FilterMatrix filters;
  final Widget child;

  const ColorFilterGenerator({
    super.key,
    required this.filters,
    required this.child,
  });

  @override
  State<ColorFilterGenerator> createState() => _ColorFilterGeneratorState();
}

class _ColorFilterGeneratorState extends State<ColorFilterGenerator> {
  late Widget _filterdWidget;

  late FilterMatrix _tempFilters;

  @override
  void initState() {
    _generateFilteredWidget();
    super.initState();
  }

  void _generateFilteredWidget() {
    Widget tree = widget.child;
    _tempFilters = widget.filters;

    for (int i = 0; i < widget.filters.length; i++) {
      tree = ColorFiltered(
        colorFilter: ColorFilter.matrix(widget.filters[i]),
        child: tree,
      );
    }
    _filterdWidget = tree;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filters.hashCode != _tempFilters.hashCode) {
      _generateFilteredWidget();
    }
    return _filterdWidget;
  }
}
