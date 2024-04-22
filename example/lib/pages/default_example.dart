// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/loading_dialog.dart';

import '../utils/example_helper.dart';

class DefaultExample extends StatefulWidget {
  const DefaultExample({super.key});

  @override
  State<DefaultExample> createState() => _DefaultExampleState();
}

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
                      'The editor support to directly open your type of data without converting it first.'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.memory_outlined),
                  title: const Text('Editor from memory'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    LoadingDialog loading = LoadingDialog()
                      ..show(
                        context,
                        theme: Theme.of(context),
                        imageEditorTheme: const ImageEditorTheme(
                          loadingDialogTheme: LoadingDialogTheme(
                            textColor: Colors.black,
                          ),
                        ),
                        designMode: ImageEditorDesignModeE.material,
                        i18n: const I18n(),
                      );
                    var url = 'https://picsum.photos/2000';
                    var bytes = await fetchImageAsUint8List(url);

                    if (context.mounted) await loading.hide(context);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildMemoryEditor(bytes)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Editor from asset'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildAssetEditor()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('Editor from network'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
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
                          'The file editor does not work in a web application because Flutter does not support files in web environments.')
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
                            Navigator.of(context).push(
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
      'assets/demo.png',
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      allowCompleteWithEmptyEditing: true,
    );
  }

  Widget _buildMemoryEditor(Uint8List bytes) {
    return ProImageEditor.memory(
      bytes,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      allowCompleteWithEmptyEditing: true,
    );
  }

  Widget _buildNetworkEditor() {
    return ProImageEditor.network(
      'https://picsum.photos/id/237/2000',
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      allowCompleteWithEmptyEditing: true,
    );
  }

  Widget _buildFileEditor(File file) {
    return ProImageEditor.file(
      file,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      allowCompleteWithEmptyEditing: true,
    );
  }
}
