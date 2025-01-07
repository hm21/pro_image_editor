import 'package:example/core/constants/example_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/constants/import_history_demo_data.dart';
import '/core/mixin/example_helper.dart';

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
  void initState() {
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return Stack(
      children: [
        ProImageEditor.asset(
          kImageEditorExampleAssetPath,
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onImageEditingComplete: onImageEditingComplete,
            onCloseEditor: () =>
                onCloseEditor(enablePop: !isDesktopMode(context)),
          ),
          configs: ProImageEditorConfigs(
            imageGeneration: const ImageGenerationConfigs(
              generateImageInBackground: false,
            ),
            designMode: platformDesignMode,
            mainEditor: MainEditorConfigs(
              enableCloseButton: !isDesktopMode(context),
              widgets: MainEditorWidgets(
                bodyItems: (editor, rebuildStream) {
                  return [
                    ReactiveWidget(
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
              ),
            ),
            emojiEditor: EmojiEditorConfigs(
                checkPlatformCompatibility: !kIsWeb,
                style: kIsWeb
                    ? EmojiEditorStyle(
                        textStyle: DefaultEmojiTextStyle.copyWith(
                          fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
                        ),
                      )
                    : const EmojiEditorStyle()),
            stateHistory: StateHistoryConfigs(
              initStateHistory: ImportStateHistory.fromMap(
                kImportHistoryDemoData,
                configs: const ImportEditorConfigs(
                  recalculateSizeAndPosition: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
