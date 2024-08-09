// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class SelectableLayerExample extends StatefulWidget {
  const SelectableLayerExample({super.key});

  @override
  State<SelectableLayerExample> createState() => _SelectableLayerExampleState();
}

class _SelectableLayerExampleState extends State<SelectableLayerExample>
    with ExampleHelperState<SelectableLayerExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.select_all_outlined),
      title: const Text('Selectable layer'),
      subtitle: const Text(
          'When you click on a layer, it will show interaction buttons.'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        imageGenerationConfigs: const ImageGenerationConfigs(
          processorConfigs: ProcessorConfigs(
            processorMode: ProcessorMode.auto,
          ),
        ),
        layerInteraction: const LayerInteraction(
          /// Choose between `auto`, `enabled` and `disabled`.
          ///
          /// Mode `auto`:
          /// Automatically determines if the layer is selectable based on the device type.
          /// If the device is a desktop-device, the layer is selectable; otherwise, the layer is not selectable.
          selectable: LayerInteractionSelectable.enabled,
          initialSelected: true,
        ),
        imageEditorTheme: const ImageEditorTheme(
          layerInteraction: ThemeLayerInteraction(
            buttonRadius: 10,
            strokeWidth: 1.2,
            borderElementWidth: 7,
            borderElementSpace: 5,
            borderColor: Colors.blue,
            removeCursor: SystemMouseCursors.click,
            rotateScaleCursor: SystemMouseCursors.click,
            editCursor: SystemMouseCursors.click,
            hoverCursor: SystemMouseCursors.move,
            borderStyle: LayerInteractionBorderStyle.solid,
            showTooltips: false,
          ),
        ),
        icons: const ImageEditorIcons(
          layerInteraction: IconsLayerInteraction(
            remove: Icons.clear,
            edit: Icons.edit_outlined,
            rotateScale: Icons.sync,
          ),
        ),
        i18n: const I18n(
          layerInteraction: I18nLayerInteraction(
            remove: 'Remove',
            edit: 'Edit',
            rotateScale: 'Rotate and Scale',
          ),
        ),
      ),
    );
  }
}
