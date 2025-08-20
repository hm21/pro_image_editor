import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/core/models/layers/paint_layer.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

PaintLayer paintLayerMock = PaintLayer(
  item: PaintedModel(
    mode: PaintMode.arrow,
    offsets: [const Offset(10, 20), const Offset(150, 300)],
    erasedOffsets: [],
    color: Colors.teal,
    strokeWidth: 3.4,
    opacity: 1,
    fill: true,
  ),
  opacity: 1,
  rawSize: const Size(140, 280),
  boxConstraints: const BoxConstraints(
    minWidth: 10,
    maxWidth: 699,
    minHeight: 22,
    maxHeight: 455,
  ),
  flipX: false,
  flipY: true,
  groupId: 'mock-group',
  interaction: LayerInteraction(
    enableEdit: false,
    enableMove: true,
    enableRotate: false,
    enableScale: true,
    enableSelection: false,
  ),
  meta: {
    'paint-mock': 'meta',
  },
  offset: const Offset(123, 652),
  rotation: pi / 2,
  scale: 3.75,
);
