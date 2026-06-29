import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/core/models/editor_configs/crop_rotate_editor_configs.dart';

/// A horizontal ruler widget for selecting tilt values.
///
/// Displays a scrollable scale with tick marks. The center indicator
/// represents the current tilt value.
///
/// The ruler maps scroll position to a value between [min] and [max].
/// Callbacks notify about changes during scrolling and when scrolling
/// ends.
class TiltRuler extends StatefulWidget {
  /// Creates a [TiltRuler] with a value, range, callbacks and configs.
  const TiltRuler({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChangeUpdate,
    required this.onChangeEnd,
    required this.configs,
  });

  /// The current tilt value represented by the ruler.
  final double value;

  /// The minimum tilt value that can be selected.
  final double min;

  /// The maximum tilt value that can be selected.
  final double max;

  /// Called repeatedly as the ruler scrolls and the value updates.
  final ValueChanged<double> onChangeUpdate;

  /// Called once when the scroll ends and the final value is selected.
  final ValueChanged<double> onChangeEnd;

  /// Configuration options for the crop/rotate editor.
  final CropRotateEditorConfigs configs;

  @override
  State<TiltRuler> createState() => _TiltRulerState();
}

class _TiltRulerState extends State<TiltRuler> {
  late ScrollController _scrollController;
  final double _pixelsPerUnit = 20.0;
  late final TiltStyle _style = widget.configs.style.tiltStyle;
  late final TiltWidgets _widgets = widget.configs.widgets.tiltWidgets;

  final _margin = const EdgeInsets.symmetric(vertical: 18);
  final _itemCount = 40;
  late final _range = widget.max - widget.min;
  bool _isActive = false;
  bool _isResetActive = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(initialScrollOffset: _offsetFromValue);
  }

  @override
  void didUpdateWidget(TiltRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isActive && !_isResetActive) {
      _isResetActive = true;
      _scrollController
          .animateTo(
            _offsetFromValue,
            duration: const Duration(milliseconds: 220),
            curve: Curves.ease,
          )
          .whenComplete(() {
            _isResetActive = false;
            if (mounted) setState(() {});
          });
    }
  }

  double get _offsetFromValue {
    // normalize value between 0.0 and 1.0
    final normalized = (widget.value - widget.min) / _range;

    // full scrollable extent
    final fullExtent = _itemCount * _pixelsPerUnit;

    // initial offset
    return fullExtent * normalized;
  }

  double get _currentValue {
    final percent = _scrollController.offset / (_pixelsPerUnit * _itemCount);
    final value = widget.min + (_range * percent);
    return value.clamp(widget.min, widget.max);
  }

  bool onScroll(ScrollNotification notification) {
    if (_isResetActive) return true;
    switch (notification) {
      case ScrollStartNotification _:
        setState(() => _isActive = true);
        break;
      case ScrollUpdateNotification _:
        widget.onChangeUpdate(_currentValue);
        break;
      case ScrollEndNotification _:
        widget.onChangeEnd(_currentValue);
        setState(() => _isActive = false);
        break;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_widgets.ruler != null) {
      return _widgets.ruler!(
        widget.value,
        widget.onChangeUpdate,
        widget.onChangeEnd,
      );
    }
    debugPaintPointersEnabled = false;

    return Container(
      color: widget.configs.style.background.withAlpha(120),
      height: _style.barHeight,
      child: ScrollConfiguration(
        behavior: _DragScrollBehavior(),
        child: NotificationListener<ScrollNotification>(
          onNotification: onScroll,
          child: MouseRegion(
            cursor: _style.cursor,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [_buildTickMarks(), _buildIndicator()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTickMarks() {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _itemCount + 1,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth / 2 - _pixelsPerUnit / 2,
          ),
          itemBuilder: (context, index) {
            final isBig = index % 10 == 0;
            final isZero = index == (_itemCount / 2).toInt();

            return _widgets.tickMark?.call(isBig, isZero) ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isZero)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _style.tickMarkColor,
                        ),
                      ),
                    Container(
                      width: _pixelsPerUnit,
                      alignment: Alignment.bottomCenter,
                      padding: _margin.copyWith(top: isZero ? 6 : null),
                      child: Container(
                        width: _style.tickMarkWidth * (isBig ? 1.5 : 1),
                        height: _style.tickMarkHeight,
                        color: _style.tickMarkColor.withAlpha(
                          isBig ? 255 : 128,
                        ),
                      ),
                    ),
                  ],
                );
          },
        );
      },
    );
  }

  Widget _buildIndicator() {
    return _widgets.indicator ??
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: _style.indicatorWidth * (_isActive ? 1.5 : 1),
          height: _style.indicatorHeight,
          margin: _margin.copyWith(top: 0),
          color: _isActive ? _style.activeColor : _style.indicatorColor,
        );
  }
}

class _DragScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
