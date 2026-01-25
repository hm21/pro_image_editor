import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '../../../shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';
import '../controllers/main_editor_controllers.dart';
import '../services/layer_interaction_manager.dart';
import '../services/sizes_manager.dart';

/// A widget that displays helper lines in the main editor to assist with
/// alignment and positioning of elements.
class MainEditorHelperLines extends StatelessWidget {
  /// Creates a `MainEditorHelperLines` widget with the necessary managers,
  /// controllers, and configurations.
  ///
  /// - [sizesManager]: Manages size-related settings and adjustments.
  /// - [layerInteractionManager]: Handles interactions with editor layers.
  /// - [controllers]: Manages the main editor's controllers.
  /// - [interactiveViewer]: A key for managing the interactive viewer state.
  /// - [helperLines]: Configurations for displaying helper lines.
  /// - [configs]: Configuration settings for the editor.
  const MainEditorHelperLines({
    super.key,
    required this.sizesManager,
    required this.layerInteractionManager,
    required this.controllers,
    required this.interactiveViewer,
    required this.helperLines,
    required this.configs,
  });

  /// Manages size-related settings and adjustments.
  final SizesManager sizesManager;

  /// Handles interactions with editor layers.
  final LayerInteractionManager layerInteractionManager;

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// A key for managing the interactive viewer state.
  final GlobalKey<ExtendedInteractiveViewerState> interactiveViewer;

  /// Configurations for displaying helper lines.
  final HelperLineConfigs helperLines;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  static const double _strokeWidth = 1.25;
  static const int _duration = 100;

  bool get _isLayerInRemovalZone => layerInteractionManager.hoverRemoveBtn;

  @override
  Widget build(BuildContext context) {
    if (!layerInteractionManager.showHelperLines) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: StreamBuilder(
          stream: controllers.removeBtnCtrl.stream,
          builder: (_, __) {
            return StreamBuilder<void>(
              stream: controllers.helperLineCtrl.stream,
              builder: (context, snapshot) {
                final viewer = interactiveViewer.currentState;

                final scale = viewer?.scaleFactor ?? 1;

                final offset = viewer?.offset ?? Offset.zero;
                final screenSize = sizesManager.editorSize;
                final editorBodySize = sizesManager.bodySize;

                if (configs.helperLines.isDisabledAtZoom && scale > 1) {
                  return const SizedBox.shrink();
                }

                return Transform.translate(
                  offset: offset,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (helperLines.showVerticalLine)
                        _buildLine(
                          key: const ValueKey('Screen-Vertical-Guide-Line'),
                          width:
                              layerInteractionManager.showVerticalHelperLine &&
                                      !_isLayerInRemovalZone
                                  ? _strokeWidth
                                  : 0,
                          height: screenSize.height * scale,
                          left: editorBodySize.width / 2 * scale,
                          top: 0,
                          color: helperLines.style.verticalColor,
                        ),
                      if (helperLines.showHorizontalLine)
                        _buildLine(
                          key: const ValueKey('Screen-Horizontal-Guide-Line'),
                          width: screenSize.width * scale,
                          height: layerInteractionManager
                                      .showHorizontalHelperLine &&
                                  !_isLayerInRemovalZone
                              ? _strokeWidth
                              : 0,
                          left: 0,
                          top: editorBodySize.height / 2 * scale,
                          color: helperLines.style.horizontalColor,
                          margin:
                              configs.layerInteraction.hideToolbarOnInteraction
                                  ? EdgeInsets.only(
                                      top: sizesManager.appBarHeight,
                                      bottom: sizesManager.bottomBarHeight,
                                    )
                                  : null,
                        ),
                      if (helperLines.showRotateLine)
                        _buildRotateLine(scale, screenSize.height * 2),
                      if (helperLines.showLayerAlignLine)
                        ..._buildLayerAlignLines(scale, screenSize),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildLine({
    required double width,
    required double height,
    required double left,
    required double top,
    required Color color,
    Key? key,
    EdgeInsets? margin,
  }) {
    return Positioned(
      key: key,
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: _duration),
        width: width,
        height: height,
        margin: margin,
        color: color,
      ),
    );
  }

  Widget _buildRotateLine(double scale, double height) {
    return Positioned(
      left: layerInteractionManager.rotationHelperLineX * scale,
      top: layerInteractionManager.rotationHelperLineY * scale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: layerInteractionManager.rotationHelperLineDeg,
          child: AnimatedContainer(
            key: const ValueKey('Rotation-Guide-Line'),
            duration: const Duration(milliseconds: _duration),
            width: layerInteractionManager.showRotationHelperLine &&
                    !_isLayerInRemovalZone
                ? _strokeWidth
                : 0,
            height: height,
            color: helperLines.style.rotateColor,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLayerAlignLines(double scale, Size screenSize) {
    final editorCenter = sizesManager.bodySize / 2;
    const halfStroke = _strokeWidth / 2;

    final verticalOffset = (editorCenter.width +
            layerInteractionManager.verticalGuideOffset.dx -
            halfStroke) *
        scale;

    final horizontalOffset = (editorCenter.height +
            layerInteractionManager.horizontalGuideOffset.dy -
            halfStroke) *
        scale;

    final showHorizontal = layerInteractionManager.isHorizontalGuideVisible &&
        !_isLayerInRemovalZone;
    final showVertical = layerInteractionManager.isVerticalGuideVisible &&
        !_isLayerInRemovalZone;

    return [
      if (showHorizontal)
        _buildLine(
          key: const ValueKey('Horizontal-Guide-Line'),
          width: screenSize.width * scale,
          height: _strokeWidth,
          top: horizontalOffset,
          left: 0,
          color: helperLines.style.layerAlignColor,
        ),
      if (showVertical)
        _buildLine(
          key: const ValueKey('Vertical-Guide-Line'),
          width: _strokeWidth,
          height: screenSize.height * scale,
          top: 0,
          left: verticalOffset,
          color: helperLines.style.layerAlignColor,
        ),
    ];
  }
}
