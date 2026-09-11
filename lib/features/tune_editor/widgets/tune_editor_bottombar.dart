import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/tune_editor_configs.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../models/tune_adjustment_matrix.dart';
import '../tune_editor.dart';

/// A bottom bar for the tune editor, providing UI for adjusting image
/// properties like brightness, contrast, and other tunable parameters.
class TuneEditorBottombar extends StatefulWidget {
  /// Creates a `TuneEditorBottombar` with the provided configurations,
  /// adjustment options, and callbacks for user interactions.
  ///
  /// - [tuneEditorConfigs]: Configuration settings for the tune editor.
  /// - [tuneAdjustmentList]: A list of available tune adjustment items.
  /// - [tuneAdjustmentMatrix]: A list of matrices representing applied
  ///   adjustments.
  /// - [selectedIndex]: The index of the currently selected adjustment item.
  /// - [rebuildController]: A stream controller for triggering UI rebuilds.
  /// - [bottomBarScrollCtrl]: Controls the scroll behavior of the bottom bar.
  /// - [state]: Represents the current state of the tune editor.
  /// - [onChangedStart]: Callback triggered at the start of an adjustment.
  /// - [onChanged]: Callback triggered during adjustment changes.
  /// - [onChangedEnd]: Callback triggered when an adjustment is completed.
  /// - [onSelect]: Callback triggered when a tune adjustment item is selected.
  const TuneEditorBottombar({
    super.key,
    required this.tuneEditorConfigs,
    required this.tuneAdjustmentList,
    required this.tuneAdjustmentMatrix,
    required this.rebuildController,
    required this.onChangedStart,
    required this.onChanged,
    required this.onChangedEnd,
    required this.bottomBarScrollCtrl,
    required this.state,
    required this.onSelect,
    required this.selectedIndex,
  });

  /// Configuration settings for the tune editor.
  final TuneEditorConfigs tuneEditorConfigs;

  /// A list of tune adjustment items available in the editor.
  final List<TuneAdjustmentItem> tuneAdjustmentList;

  /// A list of matrices representing the adjustments applied to the image.
  final List<TuneAdjustmentMatrix> tuneAdjustmentMatrix;

  /// The index of the currently selected tune adjustment item.
  final int selectedIndex;

  /// A stream controller for triggering UI rebuilds.
  final StreamController<void> rebuildController;

  /// Controls the scroll behavior of the bottom bar.
  final ScrollController bottomBarScrollCtrl;

  /// Represents the current state of the tune editor.
  final TuneEditorState state;

  /// Callback triggered at the start of an adjustment.
  final Function(double value) onChangedStart;

  /// Callback triggered during adjustment changes.
  final Function(double value) onChanged;

  /// Callback triggered when an adjustment is completed.
  final Function(double value) onChangedEnd;

  /// Callback triggered when a tune adjustment item is selected.
  final Function(int index) onSelect;

  @override
  State<TuneEditorBottombar> createState() => _TuneEditorBottombarState();
}

class _TuneEditorBottombarState extends State<TuneEditorBottombar> {
  final _textStyle = const TextStyle(fontSize: 10.0);

  final _iconSize = 22.0;

  late final ValueNotifier<double> _sliderValue = ValueNotifier(
    widget.tuneAdjustmentMatrix[widget.selectedIndex].value,
  );

  @override
  void didUpdateWidget(covariant TuneEditorBottombar oldWidget) {
    _sliderValue.value =
        widget.tuneAdjustmentMatrix[widget.selectedIndex].value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: widget.tuneEditorConfigs.style.bottomBarBackground,
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [_buildSlider(), _buildItems()],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    var activeOption = widget.tuneAdjustmentList[widget.selectedIndex];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: RepaintBoundary(
        child: SizedBox(
          height: 40,
          child: ValueListenableBuilder(
            valueListenable: _sliderValue,
            builder: (_, value, _) {
              return widget.tuneEditorConfigs.widgets.slider?.call(
                    widget.state,
                    widget.rebuildController.stream,
                    value,
                    (val) {
                      _sliderValue.value = val;
                      widget.onChanged(val);
                    },
                    widget.onChangedEnd,
                  ) ??
                  Slider(
                    min: activeOption.min,
                    max: activeOption.max,
                    divisions: activeOption.divisions,
                    label: (value * activeOption.labelMultiplier)
                        .round()
                        .toString(),
                    value: value,
                    onChangeStart: (val) {
                      _sliderValue.value = val;
                      widget.onChangedStart(val);
                    },
                    onChanged: (val) {
                      _sliderValue.value = val;
                      widget.onChanged(val);
                    },
                    onChangeEnd: widget.onChangedEnd,
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItems() {
    return SizedBox(
      height: kBottomNavigationBarHeight,
      child: EditorScrollbar(
        controller: widget.bottomBarScrollCtrl,
        child: SingleChildScrollView(
          controller: widget.bottomBarScrollCtrl,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.tuneAdjustmentList.length, (
                index,
              ) {
                var item = widget.tuneAdjustmentList[index];
                final isSelected = widget.selectedIndex == index;
                var color = isSelected
                    ? widget.tuneEditorConfigs.style.bottomBarActiveItemColor
                    : widget.tuneEditorConfigs.style.bottomBarInactiveItemColor;
                Widget button = FlatIconTextButton(
                  label: Text(
                    item.label,
                    style: _textStyle.copyWith(color: color),
                  ),
                  icon: Icon(item.icon, size: _iconSize, color: color),
                  onPressed: () => widget.onSelect(index),
                );
                final decoration = isSelected
                    ? widget
                          .tuneEditorConfigs
                          .style
                          .bottomBarActiveItemDecoration
                    : null;
                if (decoration != null) {
                  button = DecoratedBox(decoration: decoration, child: button);
                }
                return button;
              }),
            ),
          ),
        ),
      ),
    );
  }
}
