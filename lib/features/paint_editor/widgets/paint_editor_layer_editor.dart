import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '/shared/widgets/layer/widgets/layer_widget_paint_item.dart';

/// A widget that allows editing a [PaintLayer]'s properties such as
/// opacity, color, stroke width, and fill mode.
class PaintEditorLayerEditor extends StatefulWidget {
  /// Creates a [PaintEditorLayerEditor].
  ///
  /// The [layer] to be edited and the global [configs] must be provided.
  const PaintEditorLayerEditor({
    super.key,
    required this.layer,
    required this.configs,
  });

  /// The paint layer that is being edited.
  final PaintLayer layer;

  /// The configuration settings for the paint editor.
  final ProImageEditorConfigs configs;

  @override
  State<PaintEditorLayerEditor> createState() => _PaintEditorLayerEditorState();
}

class _PaintEditorLayerEditorState extends State<PaintEditorLayerEditor> {
  late final ProImageEditorConfigs _configs = widget.configs;
  late final PaintEditorWidgets _customWidgets = _configs.paintEditor.widgets;
  late final PaintLayer _layer = widget.layer;

  PaintedModel get _paintItem => _layer.item;
  late final _style = _configs.paintEditor.style;

  void _setFillState(bool enableFill) {
    _layer.item = _paintItem.copyWith(fill: enableFill);
    setState(() {});
  }

  void _setOpacity(double value) {
    _layer.opacity = value;
    setState(() {});
  }

  void _setStrokeWidth(double value) {
    _layer.item = _paintItem.copyWith(strokeWidth: value);
    setState(() {});
  }

  void _setColor(Color color) {
    _layer.item = _paintItem.copyWith(color: color);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedPopScope(
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(
              color: _style.editSheetColor,
            ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          children: [
            _buildPainting(),
            _buildBarColorPicker(),
            const SizedBox(height: 24),
            _buildOpacity(),
            _buildStrokeWidthSlider(),
            if (_paintItem.canBeFilled) _buildFillItem(),
            const SizedBox(height: 8),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildPainting() {
    if (_customWidgets.editPreview != null) {
      return _customWidgets.editPreview!(_layer);
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _style.editSheetPreviewAreaColor,
        borderRadius: BorderRadius.circular(_style.editSheetPreviewAreaRadius),
      ),
      padding: const EdgeInsets.all(7),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 140,
      child: FittedBox(
        child: SizedBox.fromSize(
          size: _layer.rawSize,
          child: LayerWidgetPaintItem(
            willChange: true,
            layer: _layer,
            paintEditorConfigs: _configs.paintEditor,
          ),
        ),
      ),
    );
  }

  Widget _buildBarColorPicker() {
    if (_customWidgets.editColorSlider != null) {
      return _customWidgets.editColorSlider!(_layer, _setColor);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12.0,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(_configs.i18n.paintEditor.color),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 12),
          child: LayoutBuilder(builder: (_, constraints) {
            return BarColorPicker(
              colorListener: (value) {
                _setColor(Color(value));
              },
              animationDuration: Duration.zero,
              padding: EdgeInsets.zero,
              configs: _configs,
              thumbRadius: 8,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.color,
              color: widget.layer.item.color,
              length: constraints.maxWidth - 16,
              horizontal: true,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOpacity() {
    if (_customWidgets.editOpacitySlider != null) {
      return _customWidgets.editOpacitySlider!(_layer, _setOpacity);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_configs.i18n.paintEditor.opacity),
          Slider(
            value: _layer.opacity,
            max: _configs.paintEditor.maxOpacity,
            min: _configs.paintEditor.minOpacity,
            divisions: _configs.paintEditor.divisionsOpacity,
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            label: _layer.opacity.toStringAsFixed(2),
            onChanged: _setOpacity,
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeWidthSlider() {
    if (_customWidgets.editStrokeWidthSlider != null) {
      return _customWidgets.editStrokeWidthSlider!(_layer, _setStrokeWidth);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_configs.i18n.paintEditor.strokeWidth),
          Slider(
            value: _paintItem.strokeWidth,
            max: _configs.paintEditor.maxStrokeWidth,
            min: _configs.paintEditor.minStrokeWidth,
            divisions: _configs.paintEditor.divisionsStrokeWidth,
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            label: _paintItem.strokeWidth.toStringAsFixed(1),
            onChanged: _paintItem.fill && _paintItem.canBeFilled
                ? null
                : _setStrokeWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildFillItem() {
    if (_customWidgets.editFillSwitch != null) {
      return _customWidgets.editFillSwitch!(_layer, _setFillState);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          title: Text(_configs.i18n.paintEditor.fill),
          value: _paintItem.fill,
          onChanged: _setFillState,
        ),
      ],
    );
  }

  Widget _buildAction() {
    if (_customWidgets.editActionButtons != null) {
      return _customWidgets.editActionButtons!(_layer);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_configs.i18n.paintEditor.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _layer),
            child: Text(_configs.i18n.paintEditor.done),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<PaintLayer>('layer', widget.layer))
      ..add(
          DiagnosticsProperty<ProImageEditorConfigs>('configs', widget.configs))
      ..add(EnumProperty<PaintMode>('mode', _paintItem.mode))
      ..add(ColorProperty('color', _paintItem.color))
      ..add(DoubleProperty('strokeWidth', _paintItem.strokeWidth))
      ..add(DoubleProperty('opacity', _layer.opacity))
      ..add(FlagProperty('fill', value: _paintItem.fill, ifTrue: 'filled'))
      ..add(FlagProperty('canBeFilled',
          value: _paintItem.canBeFilled, ifTrue: 'can be filled'))
      ..add(DiagnosticsProperty<Size>('rawSize', _layer.rawSize));
  }
}
