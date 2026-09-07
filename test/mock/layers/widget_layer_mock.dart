import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/core/models/layers/widget_layer.dart';

WidgetLayer widgetLayerMock = WidgetLayer(
  widget: Container(width: 100, height: 200, color: Colors.red),
  exportConfigs: const WidgetLayerExportConfigs(id: 'widget-mock-container'),
  boxConstraints: const BoxConstraints(
    minWidth: 1,
    maxWidth: 999,
    minHeight: 3,
    maxHeight: 2000,
  ),
  flipX: true,
  flipY: false,
  groupId: 'mock-group',
  interaction: LayerInteraction(
    enableEdit: true,
    enableMove: false,
    enableRotate: true,
    enableScale: false,
    enableSelection: true,
  ),
  meta: {'widget-mock': 'meta'},
  offset: const Offset(50, 30),
  rotation: pi,
  scale: 2.25,
);
