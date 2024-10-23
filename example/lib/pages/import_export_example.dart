// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';
import '../utils/import_history_demo_data.dart';

/// The import export example
class ImportExportExample extends StatefulWidget {
  /// Creates a new [ImportExportExample] widget.
  const ImportExportExample({super.key});

  @override
  State<ImportExportExample> createState() => _ImportExportExampleState();
}

class _ImportExportExampleState extends State<ImportExportExample>
    with ExampleHelperState<ImportExportExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.import_export_outlined),
      title: const Text('Import and Export state history'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return Stack(
      children: [
        ProImageEditor.asset(
          ExampleConstants.of(context)!.demoAssetPath,
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onImageEditingComplete: onImageEditingComplete,
            onCloseEditor: onCloseEditor,
          ),
          configs: ProImageEditorConfigs(
              imageGenerationConfigs: const ImageGenerationConfigs(
                generateImageInBackground: false,
              ),
              designMode: platformDesignMode,
              imageEditorTheme: ImageEditorTheme(
                emojiEditor: kIsWeb
                    ? EmojiEditorTheme(
                        textStyle: DefaultEmojiTextStyle.copyWith(
                          fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
                        ),
                      )
                    : const EmojiEditorTheme(),
              ),
              emojiEditorConfigs: const EmojiEditorConfigs(
                checkPlatformCompatibility: !kIsWeb,
              ),
              stateHistoryConfigs: StateHistoryConfigs(
                initStateHistory: ImportStateHistory.fromMap(
                  importHistoryDemoData,
                  configs: const ImportEditorConfigs(
                    recalculateSizeAndPosition: true,
                  ),
                ),
              ),
              customWidgets:
                  ImageEditorCustomWidgets(mainEditor: CustomWidgetsMainEditor(
                bodyItems: (editor, rebuildStream) {
                  return [
                    ReactiveCustomWidget(
                        builder: (_) {
                          return Positioned(
                            bottom: 20,
                            left: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlue.shade200,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(100),
                                  bottomRight: Radius.circular(100),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  var history = await editor.exportStateHistory(
                                    configs: const ExportEditorConfigs(
                                        // configs...
                                        ),
                                  );
                                  debugPrint(await history.toJson());
                                },
                                icon: const Icon(
                                  Icons.send_to_mobile_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        stream: rebuildStream),
                  ];
                },
              ))),
        ),
      ],
    );
  }
}
