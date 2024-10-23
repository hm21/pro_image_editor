// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';

/// A widget that provides an example of a signature drawing feature.
///
/// The [SignatureDrawingExample] widget is a stateful widget that allows users
/// to draw a signature or freeform drawing. It can be used in applications
/// that require capturing user input as drawings or signatures.
///
/// The state for this widget is managed by the [_SignatureDrawingExampleState]
/// class.
///
/// Example usage:
/// ```dart
/// SignatureDrawingExample();
/// ```
class SignatureDrawingExample extends StatefulWidget {
  /// Creates a new [SignatureDrawingExample] widget.
  const SignatureDrawingExample({super.key});

  @override
  State<SignatureDrawingExample> createState() =>
      _SignatureDrawingExampleState();
}

/// The state for the [SignatureDrawingExample] widget.
///
/// This class manages the drawing logic and state related to the signature
/// or freeform drawing within the [SignatureDrawingExample] widget.
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

                    await Navigator.push(
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
                              designMode: platformDesignMode,
                              imageEditorTheme: const ImageEditorTheme(
                                background: Colors.white,
                                paintingEditor: PaintingEditorTheme(
                                  initialColor: Colors.black,
                                ),
                              ),
                              paintEditorConfigs: const PaintEditorConfigs(
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
                              imageGenerationConfigs: ImageGenerationConfigs(
                                outputFormat: OutputFormat.png,
                                customPixelRatio:
                                    MediaQuery.of(context).devicePixelRatio,
                                maxOutputSize: const Size(2000, 2000),
                              ),
                              customWidgets: ImageEditorCustomWidgets(
                                paintEditor: CustomWidgetsPaintEditor(
                                  colorPicker: (paintEditor, rebuildStream,
                                          currentColor, setColor) =>
                                      null,
                                ),
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

                    await Navigator.push(
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
                              designMode: platformDesignMode,
                              imageEditorTheme: const ImageEditorTheme(
                                background: Colors.white,
                                paintingEditor: PaintingEditorTheme(
                                  initialColor: Colors.black,
                                ),
                              ),
                              imageGenerationConfigs: ImageGenerationConfigs(
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
