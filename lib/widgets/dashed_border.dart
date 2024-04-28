import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../mixins/converted_configs.dart';
import '../mixins/editor_configs_mixin.dart';
import '../models/layer.dart';
import '../models/theme/theme_layer_interaction.dart';

class LayerDashedBorderHelper extends StatefulWidget with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;
  final Widget child;

  final Function() onRemoveLayer;
  final Function(ScaleUpdateDetails) onScaleRotate;

  /// Data for the layer.
  final Layer layerData;

  const LayerDashedBorderHelper({
    super.key,
    required this.layerData,
    required this.child,
    required this.configs,
    required this.onRemoveLayer,
    required this.onScaleRotate,
  });

  @override
  State<LayerDashedBorderHelper> createState() =>
      _LayerDashedBorderHelperState();
}

class _LayerDashedBorderHelperState extends State<LayerDashedBorderHelper>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  @override
  Widget build(BuildContext context) {
    return widget.child;
    /* TODO: Add dashed border widget 
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.all(imageEditorTheme.layerInteraction.buttonRadius),
          child: CustomPaint(
            foregroundPainter: DashedBorderPainter(
              theme: imageEditorTheme.layerInteraction,
            ),
            child: widget.child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: InteractivePoint(
            onTap: widget.onRemoveLayer,
            buttonRadius: imageEditorTheme.layerInteraction.buttonRadius,
            cursor: imageEditorTheme.layerInteraction.removeCursor,
            icon: icons.layerInteraction.remove,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InteractivePoint(
            onScaleUpdate: widget.onScaleRotate,
            buttonRadius: imageEditorTheme.layerInteraction.buttonRadius,
            cursor: imageEditorTheme.layerInteraction.rotateScaleCursor,
            icon: icons.layerInteraction.rotateScale,
          ),
        ),
      ],
    );
   */
  }
}

class DashedBorderPainter extends CustomPainter {
  final ThemeLayerInteraction theme;

  DashedBorderPainter({
    required this.theme,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth;

    const startVal = 3.0;
    final dashWidth = theme.dashWidth;
    final dashSpace = theme.dashSpace;
    // Draw top border
    var currentX = startVal;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(min(currentX + dashWidth, size.width), 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw right border
    var currentY = startVal;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(size.width, currentY),
        Offset(size.width, min(currentY + dashWidth, size.height)),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }

    // Draw bottom border
    currentX = startVal;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(min(currentX + dashWidth, size.width), size.height),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw left border
    currentY = startVal;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(0, currentY),
        Offset(0, min(currentY + dashWidth, size.height)),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class InteractivePoint extends StatelessWidget {
  final Function(ScaleUpdateDetails)? onScaleUpdate;
  final Function()? onTap;
  final IconData icon;
  final MouseCursor cursor;
  final double buttonRadius;

  const InteractivePoint({
    super.key,
    this.onScaleUpdate,
    this.onTap,
    required this.icon,
    required this.cursor,
    required this.buttonRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
      ),
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onTap: onTap,
          onScaleUpdate: onScaleUpdate,
          child: Icon(
            icon,
            color: const Color(0xFF000000),
            size: buttonRadius * 2,
          ),
        ),
      ),
    );
  }
}
