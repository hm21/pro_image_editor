import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/layer_interaction_configs.dart';
import '/core/models/editor_configs/main_editor_configs.dart';
import '../controllers/main_editor_controllers.dart';
import '../main_editor.dart';
import '../services/layer_interaction_manager.dart';

/// A widget that defines the area for removing layers in the main editor,
/// facilitating interactions for deleting layers by dragging them into this
/// area.
class MainEditorRemoveLayerArea extends StatelessWidget {
  /// Creates a `MainEditorRemoveLayerArea` widget with the necessary managers,
  /// configurations, and state.
  ///
  /// - [state]: Represents the current state of the editor.
  /// - [mainEditorConfigs]: Configuration settings for the main editor.
  /// - [controllers]: Manages the main editor's controllers.
  /// - [layerInteraction]: Configurations for layer interactions.
  /// - [layerInteractionManager]: Handles layer interaction logic.
  /// - [removeAreaKey]: Key for identifying and managing the remove area
  ///   widget.
  const MainEditorRemoveLayerArea({
    super.key,
    required this.layerInteraction,
    required this.layerInteractionManager,
    required this.mainEditorConfigs,
    required this.state,
    required this.controllers,
    required this.removeAreaKey,
    required this.isLayerBeingTransformed,
  });

  /// Represents the current state of the editor.
  final ProImageEditorState state;

  /// Configuration settings for the main editor.
  final MainEditorConfigs mainEditorConfigs;

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// Configurations for layer interactions.
  final LayerInteractionConfigs layerInteraction;

  /// Handles logic for interacting with layers.
  final LayerInteractionManager layerInteractionManager;

  /// Key for identifying and managing the remove area widget.
  final GlobalKey<State<StatefulWidget>> removeAreaKey;

  /// Indicates whether a layer is currently being transformed.
  final bool isLayerBeingTransformed;

  @override
  Widget build(BuildContext context) {
    return mainEditorConfigs.widgets.removeLayerArea?.call(
          removeAreaKey,
          state,
          controllers.removeBtnCtrl.stream,
          isLayerBeingTransformed,
        ) ??
        Positioned(
          key: removeAreaKey,
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: StreamBuilder(
              stream: controllers.removeBtnCtrl.stream,
              builder: (_, _) => _buildRemoveWidget(),
            ),
          ),
        );
  }

  Widget _buildRemoveWidget() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: isLayerBeingTransformed
          ? Container(
              height: kToolbarHeight,
              width: kToolbarHeight,
              decoration: BoxDecoration(
                color: layerInteractionManager.hoverRemoveBtn
                    ? layerInteraction.style.removeAreaBackgroundActive
                    : layerInteraction.style.removeAreaBackgroundInactive,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(100),
                ),
              ),
              padding: const EdgeInsets.only(right: 12, bottom: 7),
              child: Center(
                child: Icon(
                  mainEditorConfigs.icons.removeElementZone,
                  size: 28,
                ),
              ),
            )
          : SizedBox.shrink(key: UniqueKey()),
    );
  }
}
