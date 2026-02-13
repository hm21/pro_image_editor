// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates how to create and use custom paint mode
/// path builders.
///
/// The [CustomPathBuilderExample] widget shows how users can provide their
/// own [PathBuilderBase] implementations to customize the rendering of
/// paint modes like arrows, lines, or completely custom shapes.
///
/// Example usage:
/// ```dart
/// CustomPathBuilderExample();
/// ```
class CustomPathBuilderExample extends StatefulWidget {
  /// Creates a new [CustomPathBuilderExample] widget.
  const CustomPathBuilderExample({super.key});

  @override
  State<CustomPathBuilderExample> createState() =>
      _CustomPathBuilderExampleState();
}

class _CustomPathBuilderExampleState extends State<CustomPathBuilderExample>
    with ExampleHelperState<CustomPathBuilderExample> {
  late final _configs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    // Custom i18n labels for the custom paint modes
    i18n: const I18n(
      paintEditor: I18nPaintEditor(
        custom1: 'Double Arrow',
        custom2: 'Wavy Line',
        custom3: 'Star',
      ),
    ),
    mainEditor: MainEditorConfigs(
      enableCloseButton: !isDesktopMode(context),
    ),
    paintEditor: PaintEditorConfigs(
      initialPaintMode: PaintMode.custom1,
      // Custom icons for the custom tools
      icons: const PaintEditorIcons(
        custom1: Icons.swap_horiz,
        custom2: Icons.waves,
        custom3: Icons.star_outline,
      ),
      // Only show our 3 custom tools
      tools: const [
        PaintMode.custom1, // Double Arrow
        PaintMode.custom2, // Wavy Line
        PaintMode.custom3, // Star
      ],
      // Register custom path builders for the custom paint modes
      customPathBuilders: {
        // Custom1: Double-headed arrow
        PaintMode.custom1: ({
          required item,
          required scale,
          required paintEditorConfigs,
        }) =>
            DoubleArrowPathBuilder(
              item: item,
              scale: scale,
              paintEditorConfigs: paintEditorConfigs,
            ),
        // Custom2: Wavy line
        PaintMode.custom2: ({
          required item,
          required scale,
          required paintEditorConfigs,
        }) =>
            WavyLinePathBuilder(
              item: item,
              scale: scale,
              paintEditorConfigs: paintEditorConfigs,
            ),
        // Custom3: Star shape
        PaintMode.custom3: ({
          required item,
          required scale,
          required paintEditorConfigs,
        }) =>
            StarPathBuilder(
              item: item,
              scale: scale,
              paintEditorConfigs: paintEditorConfigs,
            ),
      },
    ),
  );

  late final _callbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(
      editorMode: editorMode,
      enablePop: !isDesktopMode(context),
    ),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
    ),
  );

  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: _callbacks,
      configs: _configs,
    );
  }
}

// =============================================================================
// Custom Path Builders
// =============================================================================

/// A custom path builder that creates a double-headed arrow (arrows at both
/// ends of the line).
///
/// This demonstrates how to override the default arrow behavior by extending
/// [PathBuilderBase] and implementing custom rendering logic.
class DoubleArrowPathBuilder extends PathBuilderBase {
  /// Creates a double arrow path builder.
  DoubleArrowPathBuilder({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    // Draw the main line
    path
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    // Scale arrow size based on strokeWidth for consistent proportions
    final strokeFactor = painter.strokeWidth / 2;

    // Create arrowhead path (pointing right by default)
    Path createArrowHead() {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(-3 * strokeFactor, 2 * strokeFactor)
        ..lineTo(-3 * strokeFactor, -2 * strokeFactor)
        ..close();
    }

    // Direction from start to end
    final directionForward = (end - start).direction;
    // Direction from end to start (opposite)
    final directionBackward = directionForward + pi;

    // Arrow at the end point (pointing forward)
    final endTransform = Matrix4.identity()
      ..translateByDouble(end.dx, end.dy, 0.0, 1.0)
      ..rotateZ(directionForward);
    path.addPath(
      createArrowHead().transform(endTransform.storage),
      Offset.zero,
    );

    // Arrow at the start point (pointing backward)
    final startTransform = Matrix4.identity()
      ..translateByDouble(start.dx, start.dy, 0.0, 1.0)
      ..rotateZ(directionBackward);
    path.addPath(
      createArrowHead().transform(startTransform.storage),
      Offset.zero,
    );

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return super.hitTestLine(position);
  }
}

/// A custom path builder that creates a wavy/sine-wave line between two
/// points.
///
/// This demonstrates how to create completely custom drawing effects
/// by extending [PathBuilderBase].
class WavyLinePathBuilder extends PathBuilderBase {
  /// Creates a wavy line path builder.
  WavyLinePathBuilder({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    final distance = (end - start).distance;
    final direction = (end - start).direction;

    // Wave parameters - scale with stroke width for consistency
    final amplitude = painter.strokeWidth * 2;
    final wavelength = painter.strokeWidth * 4;

    // Number of wave segments
    final segments = (distance / 2).ceil();

    path.moveTo(start.dx, start.dy);

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;

      // Calculate perpendicular offset for the wave
      final waveOffset = sin(t * distance / wavelength * 2 * pi) * amplitude;

      // Perpendicular direction (90 degrees rotated)
      final perpX = -sin(direction) * waveOffset;
      final perpY = cos(direction) * waveOffset;

      path.lineTo(x + perpX, y + perpY);
    }

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestWithStroke(position);
  }
}

/// A custom path builder that creates a star shape.
///
/// This demonstrates how to override shape-based paint modes (like rect)
/// with completely different shapes by extending [PathBuilderBase].
class StarPathBuilder extends PathBuilderBase {
  /// Creates a star path builder.
  StarPathBuilder({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    // Calculate the center and radius from the bounding box
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 2;
    final outerRadius = min(radiusX, radiusY);
    final innerRadius = outerRadius * 0.4;

    // 5-pointed star
    const points = 5;
    const angleOffset = -pi / 2; // Start from the top

    path.moveTo(
      centerX + outerRadius * cos(angleOffset),
      centerY + outerRadius * sin(angleOffset),
    );

    for (int i = 1; i <= points * 2; i++) {
      final radius = i.isOdd ? innerRadius : outerRadius;
      final angle = angleOffset + (i * pi / points);
      path.lineTo(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    }

    path.close();

    return path;
  }

  @override
  Path? buildSecond() {
    // Return the same path for fill if item.fill is true
    if (item.fill) {
      return build();
    }
    return null;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
