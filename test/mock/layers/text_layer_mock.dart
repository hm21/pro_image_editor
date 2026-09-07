import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

TextLayer textLayerMock = TextLayer(
  text: 'Mock-Layer',
  boxConstraints: const BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 80,
    maxHeight: 400,
  ),
  align: TextAlign.left,
  background: Colors.amber,
  color: Colors.blue,
  colorMode: LayerBackgroundMode.backgroundAndColorWithOpacity,
  customSecondaryColor: true,
  fontScale: 2.3,
  hit: false,
  maxTextWidth: 400,
  textStyle: const TextStyle(fontFamily: 'Roboto'),
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
  meta: {'text-mock': 'meta'},
  offset: const Offset(34, 67),
  rotation: pi * 2,
  scale: 3.1,
);
