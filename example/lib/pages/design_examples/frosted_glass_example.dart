// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';

// Project imports:
import '../../utils/example_helper.dart';

class FrostedGlassExample extends StatefulWidget {
  final String url;

  const FrostedGlassExample({
    super.key,
    required this.url,
  });

  @override
  State<FrostedGlassExample> createState() => _FrostedGlassExampleState();
}

class _FrostedGlassExampleState extends State<FrostedGlassExample>
    with ExampleHelperState<FrostedGlassExample> {
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignModeE.material;

  ProImageEditorState? get _editor => editorKey.currentState;

  /// Opens the sticker/emoji editor.
  void openStickerEditor() async {
    Layer? layer = await _editor!.openPage(FrostedGlassStickerPage(
      configs: _editor!.configs,
      callbacks: _editor!.callbacks,
    ));

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
            stickerEditorCallbacks: StickerEditorCallbacks(
              onSearchChanged: (value) {
                /// Filter your stickers
                debugPrint(value);
              },
            )),
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          theme: Theme.of(context).copyWith(
              iconTheme:
                  Theme.of(context).iconTheme.copyWith(color: Colors.white)),
          icons: const ImageEditorIcons(
            paintingEditor: IconsPaintingEditor(
              bottomNavBar: Icons.edit,
            ),
          ),
          imageEditorTheme: ImageEditorTheme(
            textEditor: TextEditorTheme(
                bottomBarBackgroundColor: Colors.transparent,
                bottomBarMainAxisAlignment: !_useMaterialDesign
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.start),
            paintingEditor: const PaintingEditorTheme(
              initialStrokeWidth: 5,
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
            loadingDialog: Center(
              child: DefaultTextStyle(
                style: const TextStyle(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FrostedGlassEffect(
                    radius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.black26,
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: FittedBox(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade200,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Please wait...',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            mainEditor: CustomWidgetsMainEditor(
              closeWarningDialog: (editor) async {
                if (!context.mounted) return false;
                return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => Center(
                        child: DefaultTextStyle(
                          style: const TextStyle(),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FrostedGlassEffect(
                              radius: BorderRadius.circular(16),
                              child: Container(
                                color: Colors.black26,
                                constraints:
                                    const BoxConstraints(maxWidth: 350),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        editor.i18n.various
                                            .closeEditorWarningTitle,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Flexible(
                                      child: Text(
                                        editor.i18n.various
                                            .closeEditorWarningMessage,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 26.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(
                                            editor.i18n.various
                                                .closeEditorWarningCancelBtn,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            editor.i18n.various
                                                .closeEditorWarningConfirmBtn,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) ??
                    false;
              },
              appBar: (editor, rebuildStream) => null,
              bottomBar: (editor, rebuildStream, key) => null,
              bodyItems: _buildMainBodyWidgets,
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
              colorPicker:
                  (textEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (textEditor, rebuildStream) => null,
              bodyItems: _buildTextEditorBody,
            ),
            cropRotateEditor: CustomWidgetsCropRotateEditor(
              appBar: (cropRotateEditor, rebuildStream) => null,
              bottomBar: (cropRotateEditor, rebuildStream) =>
                  ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) => FrostedGlassCropRotateToolbar(
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
              appBar: (filterEditor, rebuildStream) => null,
              bodyItems: (filterEditor, rebuildStream) => [
                ReactiveCustomWidget(
                  stream: rebuildStream,
                  builder: (_) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FrostedGlassEffect(
                                child: IconButton(
                                  tooltip: filterEditor.configs.i18n.cancel,
                                  onPressed: filterEditor.close,
                                  icon: Icon(
                                      filterEditor.configs.icons.closeEditor),
                                ),
                              ),
                              FrostedGlassEffect(
                                child: IconButton(
                                  tooltip: filterEditor.configs.i18n.done,
                                  onPressed: filterEditor.done,
                                  icon: Icon(
                                    filterEditor.configs.icons.doneIcon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            blurEditor: CustomWidgetsBlurEditor(
              slider:
                  (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
                      ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) => Slider(
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  value: value,
                  max: editorState.configs.blurEditorConfigs.maxBlur,
                  activeColor: Colors.blue.shade200,
                ),
              ),
              appBar: (blurEditor, rebuildStream) => null,
              bodyItems: (blurEditor, rebuildStream) => [
                ReactiveCustomWidget(
                  stream: rebuildStream,
                  builder: (_) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FrostedGlassEffect(
                                child: IconButton(
                                  tooltip: blurEditor.configs.i18n.cancel,
                                  onPressed: blurEditor.close,
                                  icon: Icon(
                                      blurEditor.configs.icons.closeEditor),
                                ),
                              ),
                              FrostedGlassEffect(
                                child: IconButton(
                                  tooltip: blurEditor.configs.i18n.done,
                                  onPressed: blurEditor.done,
                                  icon: Icon(
                                    blurEditor.configs.icons.doneIcon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<ReactiveCustomWidget> _buildMainBodyWidgets(
    ProImageEditorState editor,
    Stream rebuildStream,
  ) {
    return [
      if (editor.selectedLayerIndex < 0)
        ReactiveCustomWidget(
          stream: rebuildStream,
          builder: (_) => FrostedGlassActionBar(
            configs: editor.configs,
            onTapDone: editor.doneEditing,
            onClose: editor.closeEditor,
            onTapPaintEditor: editor.openPaintingEditor,
            onTapTextEditor: () => editor.openTextEditor(
              duration: const Duration(milliseconds: 150),
            ),
            onTapCropRotateEditor: editor.openCropRotateEditor,
            onTapFilterEditor: editor.openFilterEditor,
            onTapBlurEditor: editor.openBlurEditor,
            onTapStickerEditor: openStickerEditor,
            onTapUndo: editor.undoAction,
            onTapRedo: editor.redoAction,
            canUndo: editor.canUndo,
            canRedo: editor.canRedo,
            openEditor: editor.isSubEditorOpen,
          ),
        ),
    ];
  }

  List<ReactiveCustomWidget> _buildPaintEditorBody(
    PaintingEditorState paintEditor,
    Stream rebuildStream,
  ) {
    return [
      /// Appbar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) {
          return paintEditor.activePainting
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FrostedGlassEffect(
                          child: IconButton(
                            tooltip: paintEditor.configs.i18n.cancel,
                            onPressed: paintEditor.close,
                            icon: Icon(paintEditor.configs.icons.closeEditor),
                          ),
                        ),
                        FrostedGlassEffect(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: paintEditor.configs.i18n.undo,
                                onPressed: paintEditor.undoAction,
                                icon: Icon(
                                  paintEditor.configs.icons.undoAction,
                                  color: paintEditor.canUndo
                                      ? Colors.white
                                      : Colors.white.withAlpha(80),
                                ),
                              ),
                              const SizedBox(width: 3),
                              IconButton(
                                tooltip: paintEditor.configs.i18n.redo,
                                onPressed: paintEditor.redoAction,
                                icon: Icon(
                                  paintEditor.configs.icons.redoAction,
                                  color: paintEditor.canRedo
                                      ? Colors.white
                                      : Colors.white.withAlpha(80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FrostedGlassEffect(
                          child: IconButton(
                            tooltip: paintEditor.configs.i18n.done,
                            onPressed: paintEditor.done,
                            icon: Icon(
                              paintEditor.configs.icons.doneIcon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),

      /// Bottombar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => paintEditor.activePainting
            ? const SizedBox.shrink()
            : FrostedGlassPaintBottomBar(
                configs: paintEditor.configs,
                strokeWidth: paintEditor.paintCtrl.strokeWidth,
                initColor: paintEditor.paintCtrl.color,
                paintModes: paintEditor.paintModes,
                selectedPaintMode: paintEditor.paintMode,
                onColorChanged: (color) {
                  paintEditor.paintCtrl.setColor(color);
                  paintEditor.uiPickerStream.add(null);
                },
                onChangeLineWidth: paintEditor.setStrokeWidth,
                onChangePaintMode: paintEditor.setMode,
              ),
      ),
    ];
  }

  List<ReactiveCustomWidget> _buildTextEditorBody(
      TextEditorState textEditor, Stream rebuildStream) {
    return [
      /// Background
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => const FrostedGlassEffect(
          radius: BorderRadius.zero,
          child: SizedBox.expand(),
        ),
      ),

      /// Slider Text size
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
      ),

      /// Appbar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) {
          return Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FrostedGlassEffect(
                      color: Colors.white12,
                      child: IconButton(
                        tooltip: textEditor.configs.i18n.cancel,
                        onPressed: textEditor.close,
                        icon: Icon(textEditor.configs.icons.closeEditor),
                      ),
                    ),
                    FrostedGlassEffect(
                      color: Colors.white12,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: textEditor.i18n.textEditor.textAlign,
                            onPressed: textEditor.toggleTextAlign,
                            icon: Icon(textEditor.align == TextAlign.left
                                ? textEditor.icons.textEditor.alignLeft
                                : textEditor.align == TextAlign.right
                                    ? textEditor.icons.textEditor.alignRight
                                    : textEditor.icons.textEditor.alignCenter),
                          ),
                          const SizedBox(width: 3),
                          IconButton(
                            tooltip: textEditor.i18n.textEditor.backgroundMode,
                            onPressed: textEditor.toggleBackgroundMode,
                            icon: Icon(
                                textEditor.icons.textEditor.backgroundMode),
                          ),
                        ],
                      ),
                    ),
                    FrostedGlassEffect(
                      color: Colors.white12,
                      child: IconButton(
                        tooltip: textEditor.configs.i18n.done,
                        onPressed: textEditor.done,
                        icon: Icon(
                          textEditor.configs.icons.doneIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      /// Bottombar
      ReactiveCustomWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassTextBottomBar(
          configs: textEditor.configs,
          initColor: textEditor.primaryColor,
          onColorChanged: textEditor.colorChanged,
          selectedStyle: textEditor.selectedTextStyle,
          onFontChange: textEditor.setTextStyle,
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
