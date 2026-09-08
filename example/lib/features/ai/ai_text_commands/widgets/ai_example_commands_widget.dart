import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/shared/services/shader_manager.dart';

/// A widget that displays a list of example AI text commands for image editing.
class AiExampleCommandsWidget extends StatelessWidget {
  /// Creates an [AiExampleCommandsWidget] widget.
  const AiExampleCommandsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final commands = [
      'Add a happy emoji in the top-right corner.',
      'Add the text "Hello World" in the top-center.',
      'Make the background brighter.',
      'Apply a warm color filter.',
      'Crop the image to a square around the center.',
      'Draw a dashed line across the bottom.',
      'Add a red circle in the center.',
      'Add the emoji 😎 on the left side.',
      'Increase contrast and sharpen the image.',
      'Add a yellow rectangle to highlight the top section.',
      'Insert text "Sale -50%" in bold red and a white background at the top.',
      if (ShaderManager.instance.isShaderFilterSupported)
        'Pixelate the bottom half of the image.'
      else
        'Blur the bottom half of the image.',
      'Flip the image horizontally.',
      'Rotate the image 90 degrees clockwise.',
      'Apply the round cropper.',
      'Add a green arrow pointing to the middle.',
      'Put the emoji 😂 at the bottom-right corner.',
      'Draw a freestyle wave over the image.',
      'Apply a very strong blur to the background only.',
      'Undo all changes',
    ];

    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Example Commands',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              shrinkWrap: true,
              itemCount: commands.length,
              itemBuilder: (_, index) {
                final command = commands[index];
                return ListTile(
                  title: Text(command),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, command),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
