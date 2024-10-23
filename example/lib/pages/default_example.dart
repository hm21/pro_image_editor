// Dart imports:
import 'dart:io';

// Package imports:
import 'package:file_picker/file_picker.dart';
// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

/// A widget that provides a default example of a stateful widget.
///
/// The [DefaultExample] widget is a simple stateful widget that serves as
/// a basic example or template for creating a new widget with state management.
/// It can be used as a starting point when building more complex widgets.
///
/// The state for this widget is managed by the [_DefaultExampleState] class.
///
/// Example usage:
/// ```dart
/// DefaultExample();
/// ```
class DefaultExample extends StatefulWidget {
  /// Creates a new [DefaultExample] widget.
  const DefaultExample({super.key});

  @override
  State<DefaultExample> createState() => _DefaultExampleState();
}

/// The state for the [DefaultExample] widget.
///
/// This class manages the behavior and state of the [DefaultExample] widget.
class _DefaultExampleState extends State<DefaultExample>
    with ExampleHelperState<DefaultExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext _) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Mode',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                      'The editor support to directly open your type of data '
                      'without converting it first.'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.memory_outlined),
                  title: const Text('Editor from memory'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    LoadingDialog.instance.show(
                      context,
                      configs: const ProImageEditorConfigs(),
                      theme: ThemeData.dark(),
                    );

                    var url = 'https://picsum.photos/5000';
                    var bytes = await fetchImageAsUint8List(url);

                    if (!context.mounted) return;
                    await precacheImage(MemoryImage(bytes), context);

                    LoadingDialog.instance.hide();

                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildMemoryEditor(bytes)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Editor from asset'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildAssetEditor()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('Editor from network'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);

                    LoadingDialog.instance.show(
                      context,
                      configs: const ProImageEditorConfigs(),
                      theme: ThemeData.dark(),
                    );

                    await precacheImage(
                        NetworkImage(
                            ExampleConstants.of(context)!.demoNetworkUrl),
                        context);

                    LoadingDialog.instance.hide();
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildNetworkEditor()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sd_card_outlined),
                  title: const Text('Editor from file'),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: kIsWeb
                      ? const Text(
                          'The file editor does not work in a web application '
                          'because Flutter does not support files in web '
                          'environments.')
                      : null,
                  enabled: !kIsWeb,
                  onTap: kIsWeb
                      ? null
                      : () async {
                          Navigator.pop(context);

                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);

                          if (result != null && context.mounted) {
                            File file = File(result.files.single.path!);
                            await precacheImage(FileImage(file), context);
                            if (!context.mounted) return;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => _buildFileEditor(file)),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
      leading: const Icon(Icons.dashboard_outlined),
      title: const Text('Default Editor'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildAssetEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
      ),
    );
  }

  Widget _buildMemoryEditor(Uint8List bytes) {
    return ProImageEditor.memory(
      bytes,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
      ),
    );
  }

  Widget _buildNetworkEditor() {
    return ProImageEditor.network(
      ExampleConstants.of(context)!.demoNetworkUrl,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
      ),
    );
  }

  Widget _buildFileEditor(File file) {
    return ProImageEditor.file(
      file,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
      ),
    );
  }
}
