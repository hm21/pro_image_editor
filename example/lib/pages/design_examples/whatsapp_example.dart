// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:example/widgets/demo_build_stickers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';

// Project imports:
import '../../utils/example_helper.dart';

class WhatsAppExample extends StatefulWidget {
  final String url;

  const WhatsAppExample({
    super.key,
    required this.url,
  });

  @override
  State<WhatsAppExample> createState() => _WhatsAppExampleState();
}

class _WhatsAppExampleState extends State<WhatsAppExample>
    with ExampleHelperState<WhatsAppExample> {
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignModeE.material;

  /// Helper class for managing WhatsApp filters.
  final WhatsAppHelper _whatsAppHelper = WhatsAppHelper();

  ProImageEditorState? get _editor => editorKey.currentState;

  /// Opens the WhatsApp sticker editor.
  ///
  /// This method removes the keyboard handler, then depending on the design mode specified in the [configs] parameter of the widget, it either opens the WhatsAppStickerPage directly or shows it as a modal bottom sheet.
  ///
  /// If the design mode is set to [ImageEditorDesignModeE.material], the WhatsAppStickerPage is opened directly using [_openPage()]. Otherwise, it is displayed as a modal bottom sheet with specific configurations such as transparent background, black barrier color, and controlled scrolling.
  ///
  /// After the page is opened and a layer is returned, the keyboard handler is added back. If no layer is returned or the widget is not mounted, the method returns early.
  ///
  /// If the returned layer's runtime type is not StickerLayerData, the layer's scale is set to the initial scale specified in [emojiEditorConfigs] of the [configs] parameter. Regardless, the layer's offset is set to the center of the image.
  ///
  /// Finally, the layer is added, the UI is updated, and the widget's [onUpdateUI] callback is called if provided.
  void openWhatsAppStickerEditor(ProImageEditorState editor) async {
    editor.removeKeyEventListener();

    Layer? layer;
    if (_useMaterialDesign) {
      layer = await editor.openPage(WhatsAppStickerPage(
        configs: editor.configs,
        callbacks: editor.callbacks,
      ));
    } else {
      layer = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black12,
        showDragHandle: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: WhatsAppStickerPage(
                configs: editor.configs,
                callbacks: editor.callbacks,
              ),
            ),
          );
        },
      );
    }

    editor.initKeyEventListener();
    if (layer == null || !mounted) return;

    if (layer.runtimeType != StickerLayerData) {
      layer.scale = editor.configs.emojiEditorConfigs.initScale;
    }

    editor.addLayer(layer);
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1)
          .floor();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ProImageEditor.network(
          widget.url,
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
              onImageEditingStarted: onImageEditingStarted,
              onImageEditingComplete: onImageEditingComplete,
              onCloseEditor: onCloseEditor,
              mainEditorCallbacks: MainEditorCallbacks(
                onScaleStart: _whatsAppHelper.onScaleStart,
                onScaleUpdate: (details) {
                  _whatsAppHelper.onScaleUpdate(details, _editor!);
                },
                onScaleEnd: (details) =>
                    _whatsAppHelper.onScaleEnd(details, _editor!),
                onTap: () => FocusScope.of(context).unfocus(),
              ),
              stickerEditorCallbacks: StickerEditorCallbacks(
                onSearchChanged: (value) {
                  /// Filter your stickers
                  debugPrint(value);
                },
              )),
          configs: ProImageEditorConfigs(
            designMode: platformDesignMode,
            imageEditorTheme: ImageEditorTheme(
              textEditor: TextEditorTheme(
                  textFieldMargin: EdgeInsets.zero,
                  bottomBarBackgroundColor: Colors.transparent,
                  bottomBarMainAxisAlignment: !_useMaterialDesign
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.start),
              paintingEditor: const PaintingEditorTheme(
                initialColor: Color.fromARGB(255, 129, 218, 88),
                initialStrokeWidth: 5,
              ),
              cropRotateEditor: const CropRotateEditorTheme(
                cropCornerColor: Colors.white,
                helperLineColor: Colors.white,
                cropCornerLength: 28,
                cropCornerThickness: 3,
              ),
              filterEditor: const FilterEditorTheme(
                filterListSpacing: 7,
                filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10),
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
              layerInteraction: const ThemeLayerInteraction(
                removeAreaBackgroundInactive: Colors.black12,
              ),
              helperLine: const HelperLineTheme(
                horizontalColor: Color.fromARGB(255, 129, 218, 88),
                verticalColor: Color.fromARGB(255, 129, 218, 88),
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
            cropRotateEditorConfigs: const CropRotateEditorConfigs(
              enableDoubleTap: false,
            ),
            filterEditorConfigs: FilterEditorConfigs(
              filterList: [
                const FilterModel(
                  name: "None",
                  filters: [],
                ),
                FilterModel(
                  name: "Pop",
                  filters: [
                    ColorFilterAddons.colorOverlay(255, 225, 80, 0.08),
                    ColorFilterAddons.saturation(0.1),
                    ColorFilterAddons.contrast(0.05),
                  ],
                ),
                FilterModel(
                  name: "B&W",
                  filters: [
                    ColorFilterAddons.grayscale(),
                    ColorFilterAddons.colorOverlay(100, 28, 210, 0.03),
                    ColorFilterAddons.brightness(0.1),
                  ],
                ),
                FilterModel(
                  name: "Cool",
                  filters: [
                    ColorFilterAddons.addictiveColor(0, 0, 20),
                  ],
                ),
                FilterModel(
                  name: "Chrome",
                  filters: [
                    ColorFilterAddons.contrast(0.15),
                    ColorFilterAddons.saturation(0.2),
                  ],
                ),
                FilterModel(
                  name: "Film",
                  filters: [
                    ColorFilterAddons.brightness(.05),
                    ColorFilterAddons.saturation(-0.03),
                  ],
                ),
              ],
            ),
            emojiEditorConfigs: const EmojiEditorConfigs(
              checkPlatformCompatibility: !kIsWeb,
            ),
            stickerEditorConfigs: StickerEditorConfigs(
              enabled: true,
              buildStickers: (setLayer, scrollController) => DemoBuildStickers(
                  setLayer: setLayer, scrollController: scrollController),
            ),
            customWidgets: ImageEditorCustomWidgets(
              mainEditor: CustomWidgetsMainEditor(
                appBar: (editor, rebuildStream) => null,
                bottomBar: (editor, rebuildStream, key) => null,
                wrapBody: (editor, rebuildStream, content) {
                  return Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.scale(
                        transformHitTests: false,
                        scale: 1 /
                            constraints.maxHeight *
                            (constraints.maxHeight -
                                _whatsAppHelper.filterShowHelper * 2),
                        child: content,
                      ),
                      if (editor.selectedLayerIndex < 0)
                        ..._buildWhatsAppWidgets(editor),
                    ],
                  );
                },
              ),
              paintEditor: CustomWidgetsPaintEditor(
                appBar: (paintEditor, rebuildStream) => null,
                bottomBar: (paintEditor, rebuildStream) => null,
                colorPicker:
                    (paintEditor, rebuildStream, currentColor, setColor) =>
                        null,
                bodyItems: _buildPaintEditorBody,
              ),
              textEditor: CustomWidgetsTextEditor(
                appBar: (textEditor, rebuildStream) => null,
                colorPicker: (editor, rebuildStream, currentColor, setColor) =>
                    null,
                bottomBar: (textEditor, rebuildStream) => null,
                bodyItems: _buildTextEditorBody,
              ),
              cropRotateEditor: CustomWidgetsCropRotateEditor(
                appBar: (cropRotateEditor, rebuildStream) => null,
                bottomBar: (cropRotateEditor, rebuildStream) =>
                    ReactiveCustomWidget(
                  stream: rebuildStream,
                  builder: (_) => WhatsAppCropRotateToolbar(
                    bottomBarColor: const Color(0xFF303030),
                    configs: cropRotateEditor.configs,
                    onCancel: cropRotateEditor.close,
                    onRotate: cropRotateEditor.rotate,
                    onDone: cropRotateEditor.done,
                    onReset: cropRotateEditor.reset,
                    openAspectRatios: cropRotateEditor.openAspectRatioOptions,
                  ),
                ),
              ),
              filterEditor: CustomWidgetsFilterEditor(
                filterButton: (
                  filter,
                  isSelected,
                  scaleFactor,
                  onSelectFilter,
                  editorImage,
                  filterKey,
                ) {
                  return WhatsAppFilterBtn(
                    filter: filter,
                    isSelected: isSelected,
                    onSelectFilter: () {
                      onSelectFilter.call();
                      _editor!.setState(() {});
                    },
                    editorImage: editorImage,
                    filterKey: filterKey,
                    scaleFactor: scaleFactor,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<ReactiveCustomWidget> _buildPaintEditorBody(
    PaintingEditorState paintEditor,
    Stream rebuildStream,
  ) {
    return [
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => WhatsAppPaintBottomBar(
          configs: paintEditor.configs,
          strokeWidth: paintEditor.paintCtrl.strokeWidth,
          initColor: paintEditor.paintCtrl.color,
          onColorChanged: (color) {
            paintEditor.paintCtrl.setColor(color);
            paintEditor.uiPickerStream.add(null);
          },
          onSetLineWidth: paintEditor.setStrokeWidth,
        ),
      ),
      if (!_useMaterialDesign)
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => WhatsappPaintColorpicker(paintEditor: paintEditor),
        ),
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => WhatsAppPaintAppBar(
          configs: paintEditor.configs,
          canUndo: paintEditor.canUndo,
          onDone: paintEditor.done,
          onTapUndo: paintEditor.undoAction,
          onClose: paintEditor.close,
          activeColor: paintEditor.activeColor,
        ),
      ),
    ];
  }

  List<ReactiveCustomWidget> _buildTextEditorBody(
      TextEditorState textEditor, Stream rebuildStream) {
    return [
      /// Color-Picker
      if (_useMaterialDesign)
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: WhatsappTextSizeSlider(textEditor: textEditor),
          ),
        )
      else
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: WhatsappTextColorpicker(textEditor: textEditor),
          ),
        ),

      /// Appbar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => WhatsAppTextAppBar(
          configs: textEditor.configs,
          align: textEditor.align,
          onDone: textEditor.done,
          onAlignChange: textEditor.toggleTextAlign,
          onBackgroundModeChange: textEditor.toggleBackgroundMode,
        ),
      ),

      /// Bottombar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => WhatsAppTextBottomBar(
          configs: textEditor.configs,
          initColor: textEditor.primaryColor,
          onColorChanged: (color) {
            textEditor.primaryColor = color;
          },
          selectedStyle: textEditor.selectedTextStyle,
          onFontChange: textEditor.setTextStyle,
        ),
      ),
    ];
  }

  List<Widget> _buildWhatsAppWidgets(ProImageEditorState editor) {
    double opacity =
        max(0, min(1, 1 - 1 / 120 * _whatsAppHelper.filterShowHelper));
    return [
      WhatsAppAppBar(
        configs: editor.configs,
        onClose: editor.closeEditor,
        onTapCropRotateEditor: editor.openCropRotateEditor,
        onTapStickerEditor: () => openWhatsAppStickerEditor(editor),
        onTapPaintEditor: editor.openPaintingEditor,
        onTapTextEditor: editor.openTextEditor,
        onTapUndo: editor.undoAction,
        canUndo: editor.canUndo,
        openEditor: editor.isSubEditorOpen,
      ),
      if (_useMaterialDesign)
        WhatsAppOpenFilterBtn(
          filterTextOffsetY: 90,
          configs: editor.configs,
          opacity: opacity,
        ),
      _buildDemoSendArea(editor, opacity),
      WhatsappFilters(editor: editor, whatsAppHelper: _whatsAppHelper)
    ];
  }

  Widget _buildDemoSendArea(
    ProImageEditorState editor,
    double opacity,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        hintText: 'Add a caption...',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 238, 238, 238),
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: const Color(0xFF202D35),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        16,
                        7,
                        16,
                        12 +
                            (editor.isSubEditorOpen
                                ? 0
                                : MediaQuery.of(context).viewInsets.bottom)),
                    color: Colors.black38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF202D35),
                          ),
                          child: const Text(
                            'Alex Frei',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            editor.doneEditing();
                          },
                          icon: const Icon(Icons.send),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0DA886),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
