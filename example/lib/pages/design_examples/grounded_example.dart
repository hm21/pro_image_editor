// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:example/widgets/demo_build_stickers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/designs/grounded/utils/grounded_configs.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../../utils/example_helper.dart';

/// The grounded design example
class GroundedDesignExample extends StatefulWidget {
  /// Creates a new [GroundedDesignExample] widget.
  const GroundedDesignExample({
    super.key,
    required this.url,
  });

  /// The URL of the image to display.
  final String url;

  @override
  State<GroundedDesignExample> createState() => _GroundedDesignExampleState();
}

class _GroundedDesignExampleState extends State<GroundedDesignExample>
    with ExampleHelperState<GroundedDesignExample> {
  final _mainEditorBarKey = GlobalKey<GroundedMainBarState>();
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignModeE.material;

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1)
          .floor();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ProImageEditor.network(
        widget.url,
        key: editorKey,
        callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onImageEditingComplete: onImageEditingComplete,
            onCloseEditor: onCloseEditor,
            mainEditorCallbacks: MainEditorCallbacks(
              onStartCloseSubEditor: (value) {
                /// Start the reversed animation for the bottombar
                _mainEditorBarKey.currentState?.setState(() {});
              },
            ),
            stickerEditorCallbacks: StickerEditorCallbacks(
              onSearchChanged: (value) {
                /// Filter your stickers
                debugPrint(value);
              },
            )),
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue.shade800,
              brightness: Brightness.dark,
            ),
          ),
          layerInteraction: const LayerInteraction(
            hideToolbarOnInteraction: false,
          ),
          imageEditorTheme: ImageEditorTheme(
            background: const Color(0xFF000000),
            bottomBarBackgroundColor: const Color(0xFF161616),
            textEditor: TextEditorTheme(
                textFieldMargin: const EdgeInsets.only(top: kToolbarHeight),
                bottomBarBackgroundColor: Colors.transparent,
                bottomBarMainAxisAlignment: !_useMaterialDesign
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.start),
            paintingEditor: const PaintingEditorTheme(
              background: Color(0xFF000000),
              initialStrokeWidth: 5,
            ),
            cropRotateEditor: const CropRotateEditorTheme(
                cropCornerColor: Color(0xFFFFFFFF),
                cropCornerLength: 36,
                cropCornerThickness: 4,
                background: Color(0xFF000000),
                helperLineColor: Color(0x25FFFFFF)),
            filterEditor: const FilterEditorTheme(
              filterListSpacing: 7,
              filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
              background: Color(0xFF000000),
            ),
            blurEditor: const BlurEditorTheme(
              background: Color(0xFF000000),
            ),
            emojiEditor: EmojiEditorTheme(
              backgroundColor: Colors.transparent,
              textStyle: DefaultEmojiTextStyle.copyWith(
                fontFamily:
                    !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                fontSize: _useMaterialDesign ? 48 : 30,
              ),
              emojiViewConfig: EmojiViewConfig(
                gridPadding: EdgeInsets.zero,
                horizontalSpacing: 0,
                verticalSpacing: 0,
                recentsLimit: 40,
                backgroundColor: Colors.transparent,
                buttonMode: !_useMaterialDesign
                    ? ButtonMode.CUPERTINO
                    : ButtonMode.MATERIAL,
                loadingIndicator:
                    const Center(child: CircularProgressIndicator()),
                columns: _calculateEmojiColumns(constraints),
                emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                replaceEmojiOnLimitExceed: false,
              ),
              bottomActionBarConfig:
                  const BottomActionBarConfig(enabled: false),
            ),
          ),
          textEditorConfigs: TextEditorConfigs(
            customTextStyles: [
              GoogleFonts.roboto(),
              GoogleFonts.averiaLibre(),
              GoogleFonts.lato(),
              GoogleFonts.comicNeue(),
              GoogleFonts.actor(),
              GoogleFonts.odorMeanChey(),
              GoogleFonts.nabla(),
            ],
          ),
          filterEditorConfigs: const FilterEditorConfigs(
            fadeInUpDuration: GROUNDED_FADE_IN_DURATION,
            fadeInUpStaggerDelayDuration: GROUNDED_FADE_IN_STAGGER_DELAY,
          ),
          emojiEditorConfigs: const EmojiEditorConfigs(
            checkPlatformCompatibility: !kIsWeb,
          ),
          i18n: const I18n(
            paintEditor: I18nPaintingEditor(
              changeOpacity: 'Opacity',
              lineWidth: 'Thickness',
            ),
            textEditor: I18nTextEditor(
              backgroundMode: 'Mode',
              textAlign: 'Align',
            ),
          ),
          stickerEditorConfigs: StickerEditorConfigs(
            enabled: true,
            buildStickers: (setLayer, scrollController) => DemoBuildStickers(
                categoryColor: const Color(0xFF161616),
                setLayer: setLayer,
                scrollController: scrollController),
          ),
          customWidgets: ImageEditorCustomWidgets(
            loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
              message: message,
              configs: configs,
            ),
            mainEditor: CustomWidgetsMainEditor(
              appBar: (editor, rebuildStream) => null,
              bottomBar: (editor, rebuildStream, key) => ReactiveCustomWidget(
                key: key,
                builder: (context) {
                  return GroundedMainBar(
                    key: _mainEditorBarKey,
                    editor: editor,
                    configs: editor.configs,
                    callbacks: editor.callbacks,
                  );
                },
                stream: rebuildStream,
              ),
            ),
            paintEditor: CustomWidgetsPaintEditor(
              appBar: (paintEditor, rebuildStream) => null,
              colorPicker:
                  (paintEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveCustomWidget(
                  builder: (context) {
                    return GroundedPaintingBar(
                        configs: editorState.configs,
                        callbacks: editorState.callbacks,
                        editor: editorState,
                        i18nColor: 'Color',
                        showColorPicker: (currentColor) {
                          Color? newColor;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: currentColor,
                                  onColorChanged: (color) {
                                    newColor = color;
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    if (newColor != null) {
                                      setState(() =>
                                          editorState.colorChanged(newColor!));
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  stream: rebuildStream,
                );
              },
            ),
            textEditor: CustomWidgetsTextEditor(
              appBar: (textEditor, rebuildStream) => null,
              colorPicker:
                  (textEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveCustomWidget(
                  builder: (context) {
                    return GroundedTextBar(
                        configs: editorState.configs,
                        callbacks: editorState.callbacks,
                        editor: editorState,
                        i18nColor: 'Color',
                        showColorPicker: (currentColor) {
                          Color? newColor;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: currentColor,
                                  onColorChanged: (color) {
                                    newColor = color;
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    if (newColor != null) {
                                      setState(() =>
                                          editorState.primaryColor = newColor!);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  stream: rebuildStream,
                );
              },
              bodyItems: (editorState, rebuildStream) => [
                ReactiveCustomWidget(
                  stream: rebuildStream,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.only(top: kToolbarHeight),
                    child: GroundedTextSizeSlider(textEditor: editorState),
                  ),
                ),
              ],
            ),
            cropRotateEditor: CustomWidgetsCropRotateEditor(
              appBar: (cropRotateEditor, rebuildStream) => null,
              bottomBar: (cropRotateEditor, rebuildStream) =>
                  ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) => GroundedCropRotateBar(
                  configs: cropRotateEditor.configs,
                  callbacks: cropRotateEditor.callbacks,
                  editor: cropRotateEditor,
                  selectedRatioColor: imageEditorPrimaryColor,
                ),
              ),
            ),
            tuneEditor: CustomWidgetsTuneEditor(
              appBar: (editor, rebuildStream) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveCustomWidget(
                  builder: (context) {
                    return GroundedTuneBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                    );
                  },
                  stream: rebuildStream,
                );
              },
            ),
            filterEditor: CustomWidgetsFilterEditor(
              slider:
                  (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
                      ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) => Slider(
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  value: value,
                  activeColor: Colors.blue.shade200,
                ),
              ),
              appBar: (editorState, rebuildStream) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveCustomWidget(
                  builder: (context) {
                    return GroundedFilterBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                    );
                  },
                  stream: rebuildStream,
                );
              },
            ),
            blurEditor: CustomWidgetsBlurEditor(
              appBar: (blurEditor, rebuildStream) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveCustomWidget(
                  builder: (context) {
                    return GroundedBlurBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                    );
                  },
                  stream: rebuildStream,
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
