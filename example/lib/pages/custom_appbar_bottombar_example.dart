// ignore_for_file: depend_on_referenced_packages

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';

class CustomAppbarBottombarExample extends StatefulWidget {
  const CustomAppbarBottombarExample({super.key});

  @override
  State<CustomAppbarBottombarExample> createState() =>
      _CustomAppbarBottombarExampleState();
}

class _CustomAppbarBottombarExampleState
    extends State<CustomAppbarBottombarExample>
    with ExampleHelperState<CustomAppbarBottombarExample> {
  late ScrollController _bottomBarScrollCtrl;
  late ScrollController _paintingBottomBarScrollCtrl;
  late ScrollController _cropBottomBarScrollCtrl;

  final List<TextStyle> _customTextStyles = [
    GoogleFonts.roboto(),
    GoogleFonts.averiaLibre(),
    GoogleFonts.lato(),
    GoogleFonts.comicNeue(),
    GoogleFonts.actor(),
    GoogleFonts.odorMeanChey(),
    GoogleFonts.nabla(),
  ];

  final _bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
  final List<PaintModeBottomBarItem> paintModes = [
    const PaintModeBottomBarItem(
      mode: PaintModeE.freeStyle,
      icon: Icons.edit,
      label: 'Freestyle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.arrow,
      icon: Icons.arrow_right_alt_outlined,
      label: 'Arrow',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.line,
      icon: Icons.horizontal_rule,
      label: 'Line',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.rect,
      icon: Icons.crop_free,
      label: 'Rectangle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.circle,
      icon: Icons.lens_outlined,
      label: 'Circle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.dashLine,
      icon: Icons.power_input,
      label: 'Dash line',
    ),
  ];

  final String _url = 'https://picsum.photos/id/237/2000';

  @override
  void initState() {
    _bottomBarScrollCtrl = ScrollController();
    _paintingBottomBarScrollCtrl = ScrollController();
    _cropBottomBarScrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    _paintingBottomBarScrollCtrl.dispose();
    _cropBottomBarScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog.instance.show(
          context,
          configs: const ProImageEditorConfigs(),
          theme: ThemeData.dark(),
        );

        await precacheImage(NetworkImage(_url), context);

        LoadingDialog.instance.hide();

        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => _buildEditor()),
        );
      },
      leading: const Icon(Icons.dashboard_customize_outlined),
      title: const Text('Custom AppBar and BottomBar'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return LayoutBuilder(builder: (context, constraints) {
      return ProImageEditor.network(
        _url,
        key: editorKey,
        callbacks: ProImageEditorCallbacks(
          onImageEditingStarted: onImageEditingStarted,
          onImageEditingComplete: onImageEditingComplete,
          onCloseEditor: onCloseEditor,
        ),
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          customWidgets: ImageEditorCustomWidgets(
            mainEditor: CustomWidgetsMainEditor(
              appBar: (editor, rebuildStream) => editor.selectedLayerIndex < 0
                  ? ReactiveCustomAppbar(
                      stream: rebuildStream,
                      builder: (_) => _buildAppBar(editor))
                  : null,
              bottomBar: (editor, rebuildStream, key) =>
                  editor.selectedLayerIndex < 0
                      ? ReactiveCustomWidget(
                          stream: rebuildStream,
                          builder: (_) =>
                              _bottomNavigationBar(editor, key, constraints))
                      : null,
            ),
            paintEditor: CustomWidgetsPaintEditor(
              appBar: (paintEditor, rebuildStream) => ReactiveCustomAppbar(
                stream: rebuildStream,
                builder: (_) => _appBarPaintingEditor(paintEditor),
              ),
              bottomBar: (paintEditor, rebuildStream) => ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) =>
                    _bottomBarPaintingEditor(paintEditor, constraints),
              ),
            ),
            textEditor: CustomWidgetsTextEditor(
              appBar: (textEditor, rebuildStream) => ReactiveCustomAppbar(
                stream: rebuildStream,
                builder: (_) => _appBarTextEditor(textEditor),
              ),
              bottomBar: (textEditor, rebuildStream) => null,
              bodyItems: (textEditor, rebuildStream) {
                return [
                  ReactiveCustomWidget(
                    stream: rebuildStream,
                    builder: (_) =>
                        _bottomBarTextEditor(textEditor, constraints),
                  ),
                ];
              },
            ),
            cropRotateEditor: CustomWidgetsCropRotateEditor(
              appBar: (cropRotateEditor, rebuildStream) => ReactiveCustomAppbar(
                stream: rebuildStream,
                builder: (_) => _appBarCropRotateEditor(cropRotateEditor),
              ),
              bottomBar: (cropRotateEditor, rebuildStream) =>
                  ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) =>
                    _bottomBarCropEditor(cropRotateEditor, constraints),
              ),
            ),
            filterEditor: CustomWidgetsFilterEditor(
              appBar: (filterEditor, rebuildStream) => ReactiveCustomAppbar(
                stream: rebuildStream,
                builder: (_) => _appBarFilterEditor(filterEditor),
              ),
            ),
            blurEditor: CustomWidgetsBlurEditor(
              appBar: (blurEditor, rebuildStream) => ReactiveCustomAppbar(
                stream: rebuildStream,
                builder: (_) => _appBarBlurEditor(blurEditor),
              ),
            ),
          ),
          textEditorConfigs: TextEditorConfigs(
            showSelectFontStyleBottomBar: true,
            customTextStyles: _customTextStyles,
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar(ProImageEditorState editor) {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          tooltip: 'Cancel',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.close),
          onPressed: editor.closeEditor,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          tooltip: 'Undo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.undo,
            color: editor.canUndo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: editor.undoAction,
        ),
        IconButton(
          tooltip: 'Redo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.redo,
            color: editor.canRedo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: editor.redoAction,
        ),
        IconButton(
          tooltip: 'Done',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: editor.doneEditing,
        ),
      ],
    );
  }

  AppBar _appBarPaintingEditor(PaintingEditorState paintEditor) {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.arrow_back),
          onPressed: paintEditor.close,
        ),
        const SizedBox(width: 80),
        const Spacer(),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.line_weight_rounded,
            color: Colors.white,
          ),
          onPressed: paintEditor.openLineWeightBottomSheet,
        ),
        IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              paintEditor.fillBackground == true
                  ? Icons.format_color_reset
                  : Icons.format_color_fill,
              color: Colors.white,
            ),
            onPressed: paintEditor.toggleFill),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          tooltip: 'Undo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.undo,
            color: paintEditor.canUndo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: paintEditor.undoAction,
        ),
        IconButton(
          tooltip: 'Redo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.redo,
            color: paintEditor.canRedo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: paintEditor.redoAction,
        ),
        IconButton(
          tooltip: 'Done',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: paintEditor.done,
        ),
      ],
    );
  }

  AppBar _appBarTextEditor(TextEditorState textEditor) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.arrow_back),
          onPressed: textEditor.close,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          onPressed: textEditor.toggleTextAlign,
          icon: Icon(
            textEditor.align == TextAlign.left
                ? Icons.align_horizontal_left_rounded
                : textEditor.align == TextAlign.right
                    ? Icons.align_horizontal_right_rounded
                    : Icons.align_horizontal_center_rounded,
          ),
        ),
        IconButton(
          onPressed: textEditor.toggleBackgroundMode,
          icon: const Icon(Icons.layers_rounded),
        ),
        const Spacer(),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: textEditor.done,
        ),
      ],
    );
  }

  AppBar _appBarCropRotateEditor(CropRotateEditorState cropRotateEditor) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.arrow_back),
          onPressed: cropRotateEditor.close,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          tooltip: 'Undo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.undo,
            color: cropRotateEditor.canUndo
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: cropRotateEditor.undoAction,
        ),
        IconButton(
          tooltip: 'Redo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.redo,
            color: cropRotateEditor.canRedo
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: cropRotateEditor.redoAction,
        ),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: cropRotateEditor.done,
        ),
      ],
    );
  }

  AppBar _appBarFilterEditor(FilterEditorState filterEditor) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.arrow_back),
          onPressed: filterEditor.close,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: filterEditor.done,
        ),
      ],
    );
  }

  AppBar _appBarBlurEditor(BlurEditorState blurEditor) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.arrow_back),
          onPressed: blurEditor.close,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'My Button',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.bug_report,
            color: Colors.amber,
          ),
          onPressed: () {},
        ),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: blurEditor.done,
        ),
      ],
    );
  }

  Widget _bottomNavigationBar(
      ProImageEditorState editor, Key key, BoxConstraints constraints) {
    return Scrollbar(
      /// Key is important for correct layer calculations
      key: key,
      controller: _bottomBarScrollCtrl,
      scrollbarOrientation: ScrollbarOrientation.top,
      thickness: isDesktop ? null : 0,
      child: BottomAppBar(
        height: kBottomNavigationBarHeight,
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: Center(
          child: SingleChildScrollView(
            controller: _bottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: min(constraints.maxWidth, 500),
                maxWidth: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatIconTextButton(
                      label: Text('Paint', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openPaintingEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('Text', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.text_fields,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openTextEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('My Button',
                          style:
                              _bottomTextStyle.copyWith(color: Colors.amber)),
                      icon: const Icon(
                        Icons.new_releases_outlined,
                        size: 22.0,
                        color: Colors.amber,
                      ),
                      onPressed: () {},
                    ),
                    FlatIconTextButton(
                      label: Text('Crop/ Rotate', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.crop_rotate_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openCropRotateEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('Filter', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.filter,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openFilterEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('Emoji', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openEmojiEditor,
                    ),
                    /* Be careful with the sticker editor. It's important you add 
                             your own logic how to load items in `stickerEditorConfigs`.
                              FlatIconTextButton(
                                key: const ValueKey('open-sticker-editor-btn'),
                                label: Text('Sticker', style: bottomTextStyle),
                                icon: const Icon(
                                  Icons.layers_outlined,
                                  size: 22.0,
                                  color: Colors.white,
                                ),
                                onPressed: editor.openStickerEditor,
                              ), */
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBarPaintingEditor(
      PaintingEditorState paintEditor, BoxConstraints constraints) {
    return Scrollbar(
      controller: _paintingBottomBarScrollCtrl,
      scrollbarOrientation: ScrollbarOrientation.top,
      thickness: isDesktop ? null : 0,
      child: BottomAppBar(
        height: kBottomNavigationBarHeight,
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: Center(
          child: SingleChildScrollView(
            controller: _paintingBottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: min(constraints.maxWidth, 500),
                maxWidth: 500,
              ),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceAround,
                children: <Widget>[
                  FlatIconTextButton(
                    label: Text('My Button',
                        style: _bottomTextStyle.copyWith(color: Colors.amber)),
                    icon: const Icon(
                      Icons.new_releases_outlined,
                      size: 22.0,
                      color: Colors.amber,
                    ),
                    onPressed: () {},
                  ),
                  ...List.generate(
                    paintModes.length,
                    (index) => Builder(
                      builder: (_) {
                        var item = paintModes[index];
                        var color = paintEditor.paintMode == item.mode
                            ? imageEditorPrimaryColor
                            : const Color(0xFFEEEEEE);

                        return FlatIconTextButton(
                          label: Text(
                            item.label,
                            style: TextStyle(fontSize: 10.0, color: color),
                          ),
                          icon: Icon(item.icon, color: color),
                          onPressed: () {
                            paintEditor.setMode(item.mode);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBarTextEditor(
      TextEditorState textEditor, BoxConstraints constraints) {
    var items = _customTextStyles;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: kBottomNavigationBarHeight,
      child: Container(
        color: Colors.black,
        height: kBottomNavigationBarHeight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                items.length,
                (index) {
                  bool isSelected = textEditor.selectedTextStyle.hashCode ==
                      items[index].hashCode;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                      onPressed: () {
                        textEditor.setTextStyle(items[index]);
                      },
                      icon: Text(
                        'Aa',
                        style: items[index].copyWith(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.white : Colors.black38,
                        foregroundColor:
                            isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBarCropEditor(
      CropRotateEditorState cropRotateEditor, BoxConstraints constraints) {
    return Scrollbar(
      controller: _cropBottomBarScrollCtrl,
      scrollbarOrientation: ScrollbarOrientation.top,
      thickness: isDesktop ? null : 0,
      child: BottomAppBar(
        height: kBottomNavigationBarHeight,
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: Center(
          child: SingleChildScrollView(
            controller: _cropBottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: min(MediaQuery.of(context).size.width, 500),
                maxWidth: 500,
              ),
              child: Builder(builder: (context) {
                Color foregroundColor = Colors.white;
                return Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.spaceAround,
                  children: <Widget>[
                    FlatIconTextButton(
                      key: const ValueKey('crop-rotate-editor-rotate-btn'),
                      label: Text(
                        'Rotate',
                        style:
                            TextStyle(fontSize: 10.0, color: foregroundColor),
                      ),
                      icon: Icon(Icons.rotate_90_degrees_ccw_outlined,
                          color: foregroundColor),
                      onPressed: cropRotateEditor.rotate,
                    ),
                    FlatIconTextButton(
                      key: const ValueKey('crop-rotate-editor-flip-btn'),
                      label: Text(
                        'Flip',
                        style:
                            TextStyle(fontSize: 10.0, color: foregroundColor),
                      ),
                      icon: Icon(Icons.flip, color: foregroundColor),
                      onPressed: cropRotateEditor.flip,
                    ),
                    FlatIconTextButton(
                      key: const ValueKey('crop-rotate-editor-ratio-btn'),
                      label: Text(
                        'Ratio',
                        style:
                            TextStyle(fontSize: 10.0, color: foregroundColor),
                      ),
                      icon: Icon(Icons.crop, color: foregroundColor),
                      onPressed: cropRotateEditor.openAspectRatioOptions,
                    ),
                    FlatIconTextButton(
                      key: const ValueKey('crop-rotate-editor-reset-btn'),
                      label: Text(
                        'Reset',
                        style:
                            TextStyle(fontSize: 10.0, color: foregroundColor),
                      ),
                      icon: Icon(Icons.restore, color: foregroundColor),
                      onPressed: cropRotateEditor.reset,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
