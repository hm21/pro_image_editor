import 'package:material_ui/material_ui.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/main_editor.dart';
import '../models/float_select_configs.dart';
import 'float_select_toolbar_button.dart';

/// A toolbar with layer actions like move, edit, delete, etc.
class FloatSelectToolbar extends StatelessWidget {
  /// Creates a toolbar for the selected layer
  const FloatSelectToolbar({
    super.key,
    required this.configs,
    required this.layer,
    required this.interactions,
    required this.editorKey,
  });

  /// UI and behavior configs for the toolbar
  final FloatSelectConfigs configs;

  /// The layer the toolbar is acting on
  final Layer layer;

  /// Callbacks for layer interactions
  final LayerItemInteractions interactions;

  /// Key to access the editor state
  final GlobalKey<ProImageEditorState> editorKey;

  /// Style config shortcut
  FloatSelectStyle get _style => configs.style;

  /// Localized text shortcut
  FloatSelectI18n get _i18n => configs.i18n;

  /// Custom widget overrides shortcut
  FloatSelectWidgets get _widgets => configs.widgets;

  @override
  Widget build(BuildContext context) {
    final editor = editorKey.currentState!;
    int totalLayers = editor.activeLayers.length;
    int layerIndex = editor.getLayerStackIndex(layer);

    return Container(
      decoration: BoxDecoration(
        color: _style.toolbarColor,
        borderRadius: BorderRadius.circular(_style.toolbarRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        child: Wrap(
          children:
              _widgets.toolbarChildren ??
              [
                if (configs.enableEditButton && layer.isTextLayer)
                  FloatSelectToolbarButton(
                    text: _i18n.edit,
                    onTap: interactions.edit,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableForwardButton)
                  FloatSelectToolbarButton(
                    text: _i18n.forward,
                    onTap: layerIndex < totalLayers - 1
                        ? () => editor.moveLayerForward(layer)
                        : null,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableBackwardButton)
                  FloatSelectToolbarButton(
                    text: _i18n.backward,
                    onTap: layerIndex > 0
                        ? () => editor.moveLayerBackward(layer)
                        : null,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableMoveToFrontButton)
                  FloatSelectToolbarButton(
                    text: _i18n.moveToFront,
                    onTap: layerIndex < totalLayers - 1
                        ? () => editor.moveLayerToFront(layer)
                        : null,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableMoveToBackButton)
                  FloatSelectToolbarButton(
                    text: _i18n.moveToBack,
                    onTap: layerIndex > 0
                        ? () => editor.moveLayerToBack(layer)
                        : null,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableDuplicateButton)
                  FloatSelectToolbarButton(
                    text: _i18n.duplicate,
                    onTap: () {
                      interactions.duplicated();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        editor.selectLayerByIndex(totalLayers);
                      });
                    },
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
                if (configs.enableDeleteButton)
                  FloatSelectToolbarButton(
                    text: _i18n.delete,
                    onTap: interactions.remove,
                    disabledTextStyle: _style.buttonDisabledTextStyle,
                    textStyle: _style.buttonTextStyle,
                  ),
              ],
        ),
      ),
    );
  }
}
