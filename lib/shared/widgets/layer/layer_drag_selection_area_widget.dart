import 'package:material_ui/material_ui.dart';

import '/features/main_editor/services/layer_drag_selection_service.dart';

/// A widget that visually displays the drag-selection rectangle
/// used for selecting multiple layers on the canvas.
///
/// This widget listens to [LayerDragSelectionService.dragRectNotifier]
/// and renders a styled box when drag selection is active.
///
/// The appearance is controlled by [LayerInteractionConfigs.style].
class LayerDragSelectionAreaWidget extends StatelessWidget {
  /// Creates a [LayerDragSelectionAreaWidget].
  ///
  /// The [layerDragSelectionService] provides the current selection rect and
  /// style.
  const LayerDragSelectionAreaWidget({
    super.key,
    required this.layerDragSelectionService,
  });

  /// The service that manages drag selection state and configuration.
  final LayerDragSelectionService layerDragSelectionService;

  @override
  Widget build(BuildContext context) {
    final service = layerDragSelectionService;
    final configs = service.layerInteractionConfigs;
    final style = configs.style;

    return ValueListenableBuilder(
      valueListenable: service.dragRectNotifier,
      builder: (_, dragRect, _) {
        return Positioned(
          left: dragRect.offset.dx,
          top: dragRect.offset.dy,
          width: dragRect.size.width,
          height: dragRect.size.height,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: dragRect.isVisible && configs.enableLayerDragSelection
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: style.dragSelectionBorderColor,
                        width: style.dragSelectionBorderWidth,
                      ),
                      color: style.dragSelectionBackground,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
