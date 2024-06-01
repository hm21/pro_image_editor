// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/modules/paint_editor/paint_editor.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';

class SignatureDrawingExample extends StatefulWidget {
  const SignatureDrawingExample({super.key});

  @override
  State<SignatureDrawingExample> createState() =>
      _SignatureDrawingExampleState();
}

class _SignatureDrawingExampleState extends State<SignatureDrawingExample>
    with ExampleHelperState<SignatureDrawingExample> {
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.draw_outlined),
                  title: const Text('Signature'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaintingEditor.drawing(
                          initConfigs: PaintEditorInitConfigs(
                            theme: ThemeData.dark(),
                            convertToUint8List: true,
                            onImageEditingStarted: onImageEditingStarted,
                            onImageEditingComplete: onImageEditingComplete,
                            onCloseEditor: onCloseEditor,
                            configs: ProImageEditorConfigs(
                              imageEditorTheme: const ImageEditorTheme(
                                background: Colors.white,
                              ),
                              paintEditorConfigs: const PaintEditorConfigs(
                                initialColor: Colors.black,
                                showColorPicker: false,
                                hasOptionFreeStyle: false,
                                hasOptionArrow: false,
                                hasOptionLine: false,
                                hasOptionRect: false,
                                hasOptionCircle: false,
                                hasOptionDashLine: false,
                                canToggleFill: false,

                                /// Optional true
                                canChangeLineWidth: true,
                              ),
                              imageGenerationConfigs: ImageGeneratioConfigs(
                                outputFormat: OutputFormat.png,
                                customPixelRatio:
                                    MediaQuery.of(context).devicePixelRatio,
                                maxOutputSize: const Size(2000, 2000),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brush_outlined),
                  title: const Text('Drawing'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaintingEditor.drawing(
                          initConfigs: PaintEditorInitConfigs(
                            theme: Theme.of(context),
                            convertToUint8List: true,
                            onImageEditingStarted: onImageEditingStarted,
                            onImageEditingComplete: onImageEditingComplete,
                            onCloseEditor: onCloseEditor,
                            configs: ProImageEditorConfigs(
                              imageEditorTheme: const ImageEditorTheme(
                                background: Colors.white,
                              ),
                              paintEditorConfigs: const PaintEditorConfigs(
                                initialColor: Colors.black,
                              ),
                              imageGenerationConfigs: ImageGeneratioConfigs(
                                outputFormat: OutputFormat.png,
                                customPixelRatio:
                                    MediaQuery.of(context).devicePixelRatio,
                                maxOutputSize: const Size(2000, 2000),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      leading: const Icon(Icons.gesture_outlined),
      title: const Text('Signature or Drawing'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
