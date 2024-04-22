// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/paint_editor/paint_bottom_bar_item.dart';
import 'package:pro_image_editor/models/theme/theme_shared_values.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/flat_icon_text_button.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';

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
  late StreamController _updateUIStream;
  late ScrollController _bottomBarScrollCtrl;
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

  @override
  void initState() {
    _updateUIStream = StreamController.broadcast();
    _bottomBarScrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _updateUIStream.close();
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
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
        'https://picsum.photos/id/237/2000',
        key: editorKey,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
        onUpdateUI: () => _updateUIStream.add(null),
        configs: ProImageEditorConfigs(
          customWidgets: ImageEditorCustomWidgets(
            appBar: _buildAppBar(),
            appBarPaintingEditor: _appBarPaintingEditor(),
            appBarTextEditor: _appBarTextEditor(),
            appBarCropRotateEditor: _appBarCropRotateEditor(),
            appBarFilterEditor: _appBarFilterEditor(),
            appBarBlurEditor: _appBarBlurEditor(),
            bottomNavigationBar: _bottomNavigationBar(constraints),
            bottomBarPaintingEditor: _bottomBarPaintingEditor(constraints),
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                tooltip: 'Cancel',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.close),
                onPressed: editorKey.currentState?.closeEditor,
              );
            }),
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
        StreamBuilder(
          stream: _updateUIStream.stream,
          builder: (_, __) {
            return IconButton(
              tooltip: 'Undo',
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.undo,
                color: editorKey.currentState?.canUndo == true
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: editorKey.currentState?.undoAction,
            );
          },
        ),
        StreamBuilder(
          stream: _updateUIStream.stream,
          builder: (_, __) {
            return IconButton(
              tooltip: 'Redo',
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.redo,
                color: editorKey.currentState?.canRedo == true
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: editorKey.currentState?.redoAction,
            );
          },
        ),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                tooltip: 'Done',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed: editorKey.currentState?.doneEditing,
              );
            }),
      ],
    );
  }

  AppBar _appBarPaintingEditor() {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    editorKey.currentState?.paintingEditor.currentState?.close,
              );
            }),
        const SizedBox(width: 80),
        const Spacer(),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(
                  Icons.line_weight_rounded,
                  color: Colors.white,
                ),
                onPressed: editorKey.currentState?.paintingEditor.currentState
                    ?.openLineWeightBottomSheet,
              );
            }),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    editorKey.currentState?.paintingEditor.currentState
                                ?.fillBackground ==
                            true
                        ? Icons.format_color_reset
                        : Icons.format_color_fill,
                    color: Colors.white,
                  ),
                  onPressed: editorKey
                      .currentState?.paintingEditor.currentState?.toggleFill);
            }),
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
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                tooltip: 'Undo',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  Icons.undo,
                  color: editorKey.currentState?.paintingEditor.currentState
                              ?.canUndo ==
                          true
                      ? Colors.white
                      : Colors.white.withAlpha(80),
                ),
                onPressed: editorKey
                    .currentState?.paintingEditor.currentState?.undoAction,
              );
            }),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                tooltip: 'Redo',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  Icons.redo,
                  color: editorKey.currentState?.paintingEditor.currentState
                              ?.canRedo ==
                          true
                      ? Colors.white
                      : Colors.white.withAlpha(80),
                ),
                onPressed: editorKey
                    .currentState?.paintingEditor.currentState?.redoAction,
              );
            }),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                tooltip: 'Done',
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed:
                    editorKey.currentState?.paintingEditor.currentState?.done,
              );
            }),
      ],
    );
  }

  AppBar _appBarTextEditor() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    editorKey.currentState?.textEditor.currentState?.close,
              );
            }),
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
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                onPressed: editorKey
                    .currentState?.textEditor.currentState?.toggleTextAlign,
                icon: Icon(
                  editorKey.currentState?.textEditor.currentState?.align ==
                          TextAlign.left
                      ? Icons.align_horizontal_left_rounded
                      : editorKey.currentState?.textEditor.currentState
                                  ?.align ==
                              TextAlign.right
                          ? Icons.align_horizontal_right_rounded
                          : Icons.align_horizontal_center_rounded,
                ),
              );
            }),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                onPressed: editorKey.currentState?.textEditor.currentState
                    ?.toggleBackgroundMode,
                icon: const Icon(Icons.layers_rounded),
              );
            }),
        const Spacer(),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed:
                    editorKey.currentState?.textEditor.currentState?.done,
              );
            }),
      ],
    );
  }

  AppBar _appBarCropRotateEditor() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.arrow_back),
                onPressed: editorKey
                    .currentState?.cropRotateEditor.currentState?.close,
              );
            }),
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
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
                onPressed: editorKey
                    .currentState?.cropRotateEditor.currentState?.rotate,
              );
            }),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                key: const ValueKey('pro-image-editor-aspect-ratio-btn'),
                icon: const Icon(Icons.crop),
                onPressed: editorKey.currentState?.cropRotateEditor.currentState
                    ?.openAspectRatioOptions,
              );
            }),
        const Spacer(),
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed:
                    editorKey.currentState?.cropRotateEditor.currentState?.done,
              );
            }),
      ],
    );
  }

  AppBar _appBarFilterEditor() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    editorKey.currentState?.filterEditor.currentState?.close,
              );
            }),
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
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed:
                    editorKey.currentState?.filterEditor.currentState?.done,
              );
            }),
      ],
    );
  }

  AppBar _appBarBlurEditor() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    editorKey.currentState?.filterEditor.currentState?.close,
              );
            }),
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
        StreamBuilder(
            stream: _updateUIStream.stream,
            builder: (_, __) {
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.done),
                iconSize: 28,
                onPressed:
                    editorKey.currentState?.filterEditor.currentState?.done,
              );
            }),
      ],
    );
  }

  Widget _bottomNavigationBar(BoxConstraints constraints) {
    return StreamBuilder(
      stream: _updateUIStream.stream,
      builder: (_, __) {
        return Scrollbar(
          controller: _bottomBarScrollCtrl,
          scrollbarOrientation: ScrollbarOrientation.top,
          thickness: isDesktop ? null : 0,
          child: BottomAppBar(
            /// kBottomNavigationBarHeight is important that helperlines will work
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
                          onPressed: editorKey.currentState?.openPaintingEditor,
                        ),
                        FlatIconTextButton(
                          label: Text('Text', style: _bottomTextStyle),
                          icon: const Icon(
                            Icons.text_fields,
                            size: 22.0,
                            color: Colors.white,
                          ),
                          onPressed: editorKey.currentState?.openTextEditor,
                        ),
                        FlatIconTextButton(
                          label: Text('My Button',
                              style: _bottomTextStyle.copyWith(
                                  color: Colors.amber)),
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
                          onPressed: editorKey.currentState?.openCropEditor,
                        ),
                        FlatIconTextButton(
                          label: Text('Filter', style: _bottomTextStyle),
                          icon: const Icon(
                            Icons.filter,
                            size: 22.0,
                            color: Colors.white,
                          ),
                          onPressed: editorKey.currentState?.openFilterEditor,
                        ),
                        FlatIconTextButton(
                          label: Text('Emoji', style: _bottomTextStyle),
                          icon: const Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                            size: 22.0,
                            color: Colors.white,
                          ),
                          onPressed: editorKey.currentState?.openEmojiEditor,
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
                                    onPressed: editorKey.currentState?.openStickerEditor,
                                  ), */
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomBarPaintingEditor(BoxConstraints constraints) {
    return StreamBuilder(
      stream: _updateUIStream.stream,
      builder: (_, __) {
        return Scrollbar(
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
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceAround,
                    children: <Widget>[
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
                      ...List.generate(
                        paintModes.length,
                        (index) => Builder(
                          builder: (_) {
                            var item = paintModes[index];
                            var color = editorKey.currentState?.paintingEditor
                                        .currentState?.paintMode ==
                                    item.mode
                                ? imageEditorPrimaryColor
                                : const Color(0xFFEEEEEE);

                            return FlatIconTextButton(
                              label: Text(
                                item.label,
                                style: TextStyle(fontSize: 10.0, color: color),
                              ),
                              icon: Icon(item.icon, color: color),
                              onPressed: () {
                                editorKey
                                    .currentState?.paintingEditor.currentState
                                    ?.setMode(item.mode);
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
      },
    );
  }
}
