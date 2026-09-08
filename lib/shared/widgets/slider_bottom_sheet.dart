import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '/core/enums/design_mode.dart';
import '/shared/styles/platform_text_styles.dart';
import '/shared/widgets/bottom_sheets_header_row.dart';
import 'reactive_widgets/reactive_custom_widget.dart';

/// A bottom sheet widget with a slider, allowing users to adjust values within
/// a specified range. The widget supports customization and dynamic UI updates.
class SliderBottomSheet<T> extends StatefulWidget {
  /// Creates a `SliderBottomSheet` with the provided parameters for
  /// customization and user interaction.
  ///
  /// - [title]: The title displayed at the top of the bottom sheet.
  /// - [headerTextStyle]: The text style for the title.
  /// - [resetIcon]: An optional icon for resetting the slider's value.
  /// - [closeButton]: A builder function for a custom close button.
  /// - [customSlider]: A builder function for a custom slider.
  /// - [showFactorInTitle]: Whether to show the factor value in the title.
  /// - [min]: The minimum value for the slider.
  /// - [max]: The maximum value for the slider.
  /// - [divisions]: The number of discrete divisions on the slider.
  /// - [rebuildController]: A stream controller for triggering UI updates.
  /// - [state]: The state object associated with the bottom sheet.
  /// - [designMode]: The design mode of the editor.
  /// - [theme]: Theme data for styling the bottom sheet.
  /// - [value]: The current value of the slider.
  /// - [onValueChanged]: Callback triggered when the slider value changes.
  const SliderBottomSheet({
    super.key,
    required this.title,
    required this.headerTextStyle,
    required this.min,
    required this.max,
    required this.divisions,
    required this.closeButton,
    required this.customSlider,
    required this.state,
    required this.value,
    required this.designMode,
    required this.theme,
    required this.rebuildController,
    required this.onValueChanged,
    this.resetIcon,
    this.showFactorInTitle = false,
  });

  /// The title displayed at the top of the bottom sheet.
  final String title;

  /// The text style for the title.
  final TextStyle? headerTextStyle;

  /// An optional icon for resetting the slider's value.
  final IconData? resetIcon;

  /// A builder function for a custom close button.
  final Widget Function(T, dynamic Function())? closeButton;

  /// A builder function for a custom slider.
  final ReactiveWidget<Widget> Function(
    T,
    Stream<void>,
    double,
    dynamic Function(double),
    dynamic Function(double),
  )?
  customSlider;

  /// Whether to show the factor value in the title.
  final bool showFactorInTitle;

  /// The minimum value for the slider.
  final double min;

  /// The maximum value for the slider.
  final double max;

  /// The number of discrete divisions on the slider.
  final int? divisions;

  /// A stream controller for triggering UI updates.
  final StreamController<void> rebuildController;

  /// The state object associated with the bottom sheet.
  final T state;

  /// The design mode of the editor.
  final ImageEditorDesignMode designMode;

  /// Theme data for styling the bottom sheet.
  final ThemeData theme;

  /// The current value of the slider.
  final double value;

  /// Callback triggered when the slider value changes.
  final Function(double value) onValueChanged;

  @override
  State<SliderBottomSheet<T>> createState() => _SliderBottomSheetState<T>();
}

class _SliderBottomSheetState<T> extends State<SliderBottomSheet<T>> {
  late double _value = widget.value;
  late final double _presetValue = widget.value;

  void updateValue(double value) {
    widget.onValueChanged(value);
    _value = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        textStyle: platformTextStyle(context, widget.designMode),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildHeader(), _buildBody()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String factorText = widget.showFactorInTitle
        ? ' ${_value.toStringAsFixed(1)}x'
        : '';

    return BottomSheetHeaderRow(
      title: '${widget.title}$factorText',
      theme: widget.theme,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      textStyle: widget.headerTextStyle,
      closeButton: widget.closeButton != null
          ? (fn) => widget.closeButton!(widget.state, fn)
          : null,
    );
  }

  Widget _buildBody() {
    return widget.customSlider?.call(
          widget.state,
          widget.rebuildController.stream,
          _value,
          updateValue,
          (onChangedEnd) {},
        ) ??
        Row(
          children: [
            Expanded(
              child: Slider.adaptive(
                max: widget.max,
                min: widget.min,
                divisions: widget.divisions,
                value: _value,
                onChanged: updateValue,
              ),
            ),
            if (widget.resetIcon != null) ...[
              const SizedBox(width: 8),
              _buildResetButton(),
              const SizedBox(width: 2),
            ],
          ],
        );
  }

  Widget _buildResetButton() {
    return IconTheme(
      data: Theme.of(context).primaryIconTheme,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _value != _presetValue
            ? IconButton(
                onPressed: () {
                  updateValue(_presetValue);
                },
                icon: Icon(widget.resetIcon),
              )
            : IconButton(
                color: Colors.transparent,
                onPressed: null,
                icon: Icon(widget.resetIcon),
              ),
      ),
    );
  }
}
