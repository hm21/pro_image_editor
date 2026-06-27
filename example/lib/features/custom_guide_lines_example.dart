// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates app-defined custom snapping guide lines.
///
/// In addition to the built-in center, rotation and layer-alignment guides,
/// [HelperLineConfigs.customGuides] lets you define your own vertical and
/// horizontal guides that participate in layer snapping - useful for safe
/// areas, thirds, columns or any layout-specific alignment points.
class CustomGuideLinesExample extends StatefulWidget {
  /// Creates a new [CustomGuideLinesExample] widget.
  const CustomGuideLinesExample({super.key});

  @override
  State<CustomGuideLinesExample> createState() =>
      _CustomGuideLinesExampleState();
}

class _CustomGuideLinesExampleState extends State<CustomGuideLinesExample>
    with ExampleHelperState<CustomGuideLinesExample> {
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
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        helperLines: const HelperLineConfigs(
          // Define layout-specific guides. Normalized positions are fractions
          // of the editor body; absolute positions are editor-body pixels.
          customGuides: [
            // Rule-of-thirds columns.
            HelperGuideLine(
              axis: Axis.vertical,
              position: 1 / 3,
              positionMode: HelperGuidePositionMode.normalized,
            ),
            HelperGuideLine(
              axis: Axis.vertical,
              position: 2 / 3,
              positionMode: HelperGuidePositionMode.normalized,
            ),
            // Top / bottom safe-area lines.
            HelperGuideLine(
              axis: Axis.horizontal,
              position: 0.15,
              positionMode: HelperGuidePositionMode.normalized,
            ),
            HelperGuideLine(
              axis: Axis.horizontal,
              position: 0.85,
              positionMode: HelperGuidePositionMode.normalized,
            ),
          ],
          style: HelperLineStyle(
            customGuideColor: Color(0xFF00BFA5),
          ),
        ),
        i18n: const I18n(
          textEditor: I18nTextEditor(
            inputHintText: 'Add text and drag it to the guides',
          ),
        ),
      ),
    );
  }
}
