// Dart imports:
import 'dart:math';

// Flutter imports:
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
  void openWhatsAppStickerEditor() async {
    _editor!.removeKeyEventListener();

    Layer? layer;
    if (_useMaterialDesign) {
      layer = await _editor!.openPage(WhatsAppStickerPage(
        configs: _editor!.configs,
        callbacks: _editor!.callbacks,
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
                configs: _editor!.configs,
                callbacks: _editor!.callbacks,
              ),
            ),
          );
        },
      );
    }

    _editor!.initKeyEventListener();
    if (layer == null || !mounted) return;

    if (layer.runtimeType != StickerLayerData) {
      layer.scale = _editor!.configs.emojiEditorConfigs.initScale;
    }

    _editor!.addLayer(layer);
  }

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
            buildStickers: (setLayer, scrollController) {
              List<String> demoTitels = [
                'Recent',
                'Favorites',
                'Shapes',
                'Funny',
                'Boring',
                'Frog',
                'Snow',
                'More'
              ];
              List<Widget> slivers = [];
              int offset = 0;
              for (var element in demoTitels) {
                slivers.addAll([
                  _buildDemoStickersTitle(element),
                  _buildDemoStickers(offset, setLayer),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ]);
                offset += 20;
              }

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: slivers,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    color: Colors.grey.shade800,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.watch_later_outlined),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mood),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.pets),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.coronavirus),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  (paintEditor, rebuildStream, currentColor, setColor) => null,
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
    });
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
          builder: (_) => Positioned(
            top: 60,
            right: 16,
            child: StreamBuilder(
                stream: paintEditor.uiPickerStream.stream,
                builder: (context, snapshot) {
                  return BarColorPicker(
                    configs: paintEditor.configs,
                    borderWidth: _useMaterialDesign ? 0 : 2,
                    showThumb: _useMaterialDesign,
                    length: min(
                      200,
                      MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom -
                          kToolbarHeight -
                          kBottomNavigationBarHeight -
                          MediaQuery.of(context).padding.top -
                          30,
                    ),
                    horizontal: false,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    initialColor: paintEditor
                        .configs.imageEditorTheme.paintingEditor.initialColor,
                    colorListener: (int value) {
                      paintEditor.colorChanged(Color(value));
                    },
                  );
                }),
          ),
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
    const double barPickerPadding = 60;
    return [
      /// Color-Picker
      if (_useMaterialDesign)
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 16,
              height: min(
                  280,
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      kToolbarHeight -
                      kBottomNavigationBarHeight -
                      MediaQuery.of(context).padding.top),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Flexible(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: SliderComponentShape.noThumb,
                        ),
                        child: StatefulBuilder(builder: (context, setState) {
                          return Slider(
                            onChanged: (value) {
                              textEditor.fontScale = 4.5 - value;
                              setState(() {});
                            },
                            min: 0.5,
                            max: 4,
                            value: max(0.5, min(4.5 - textEditor.fontScale, 4)),
                            thumbColor: Colors.white,
                            inactiveColor: Colors.white60,
                            activeColor: Colors.white60,
                          );
                        }),
                      ),
                    ),
                  ),
                  const Text(
                    'A',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(
                right: 16,
                top: 0,
              ),
              padding: const EdgeInsets.only(
                top: barPickerPadding,
              ),
              child: BarColorPicker(
                configs: textEditor.configs,
                borderWidth: _useMaterialDesign ? 0 : 2,
                showThumb: _useMaterialDesign,
                length: min(
                  200,
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      kToolbarHeight -
                      20 -
                      barPickerPadding -
                      MediaQuery.of(context).padding.top,
                ),
                onPositionChange: (value) {
                  textEditor.colorPosition = value;
                },
                initPosition: textEditor.colorPosition,
                initialColor: textEditor.primaryColor,
                horizontal: false,
                thumbColor: Colors.white,
                cornerRadius: 10,
                pickMode: PickMode.color,
                colorListener: (int value) {
                  textEditor.colorChanged(Color(value));
                },
              ),
            ),
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
          onColorChanged: textEditor.colorChanged,
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
        onTapStickerEditor: openWhatsAppStickerEditor,
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
      Positioned(
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
                              _editor!.doneEditing();
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
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: -120 + _whatsAppHelper.filterShowHelper,
        child: Opacity(
          opacity: max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
          child: Container(
            margin: const EdgeInsets.only(top: 7),
            color: const Color(0xFF121B22),
            child: FilterEditorItemList(
              mainBodySize: editor.sizesManager.bodySize,
              mainImageSize: editor.sizesManager.decodedImageSize,
              transformConfigs: editor.stateManager.transformConfigs,
              itemScaleFactor:
                  max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
              editorImage: EditorImage(networkUrl: widget.url),
              blurFactor: editor.stateManager.activeBlur,
              configs: editor.configs,
              selectedFilter: editor.stateManager.activeFilters.isNotEmpty
                  ? editor.stateManager.activeFilters
                  : PresetFilters.none.filters,
              onSelectFilter: (filter) {
                editor.addHistory(filters: filter.filters);

                setState(() {});
              },
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildDemoStickersTitle(String text) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  SliverGrid _buildDemoStickers(int offset, Function(Widget) setLayer) {
    return SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: max(3, 3 + offset % 6),
        itemBuilder: (context, index) {
          String url =
              'https://picsum.photos/id/${offset + (index + 3) * 3}/2000';
          var widget = ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                return AnimatedSwitcher(
                  layoutBuilder: (currentChild, previousChildren) {
                    return SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 200),
                  child: loadingProgress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                );
              },
            ),
          );
          return GestureDetector(
            onTap: () async {
              // Important make sure the image is completly loaded
              // cuz the editor will directly take a screenshot
              // inside of a background isolated thread.
              LoadingDialog loading = LoadingDialog();
              await loading.show(
                context,
                configs: const ProImageEditorConfigs(),
                theme: ThemeData.dark(),
              );

              if (!context.mounted) return;
              await precacheImage(NetworkImage(url), context);
              if (context.mounted) await loading.hide(context);
              setLayer(widget);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: widget,
            ),
          );
        });
  }
}
