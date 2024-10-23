import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'utils/grounded_configs.dart';

/// A widget that provides the main bottom navigation bar for the
/// ProImageEditor.
///
/// The [GroundedMainBar] allows users to access various editing features such
/// as painting, text editing, cropping, rotating, applying filters, blurring,
/// and adding emojis or stickers to an image. It provides an interactive UI
/// for switching between these editors and includes undo/redo and close actions.
class GroundedMainBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedMainBar].
  ///
  /// Requires [configs], [callbacks], and [editor] to manage the state of the
  /// image editor.
  const GroundedMainBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds information about the current editing session.
  final ProImageEditorState editor;

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedMainBar> createState() => GroundedMainBarState();
}

/// State class for [GroundedMainBar].
///
/// This state manages the bottom navigation bar, providing buttons for
/// switching between different editing modes, as well as undo/redo actions.
/// It also manages transitions between different sub-editors.
class GroundedMainBarState extends State<GroundedMainBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _bottomBarScrollCtrl;

  Color get _foreGroundColor => imageEditorTheme.appBarForegroundColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withOpacity(0.6);

  late final _bottomTextStyle = TextStyle(
    fontSize: 10.0,
    color: _foreGroundColorAccent,
  );
  final _bottomIconSize = 22.0;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  void _openEmojiEditor() async {
    Layer? layer = await widget.editor.openPage(GroundedEmojiEditor(
      configs: configs,
      callbacks: callbacks,
    ));
    if (layer == null || !mounted) return;
    layer.scale = configs.emojiEditorConfigs.initScale;
    widget.editor.addLayer(layer);
  }

  void _openStickerEditor() async {
    Layer? layer = await widget.editor.openPage(GroundedStickerEditor(
      configs: configs,
      callbacks: callbacks,
    ));
    if (layer == null || !mounted) return;
    widget.editor.addLayer(layer);
  }

  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        Scrollbar(
          controller: _bottomBarScrollCtrl,
          scrollbarOrientation: ScrollbarOrientation.top,
          thickness: isDesktop ? null : 0,
          child: _buildFunctions(constraints),
        ),
        GroundedBottomBar(
          configs: configs,
          undo: widget.editor.undoAction,
          redo: widget.editor.redoAction,
          done: widget.editor.doneEditing,
          close: widget.editor.closeEditor,
          enableRedo: widget.editor.canRedo,
          enableUndo: widget.editor.canUndo,
        ),
      ],
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
    return BottomAppBar(
      height: GROUNDED_SUB_BAR_HEIGHT,
      color: imageEditorTheme.bottomBarBackgroundColor,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        layoutBuilder: (currentChild, previousChildren) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 0),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.vertical,
              axisAlignment: -1,
              child: child,
            ),
          );
        },
        switchInCurve: Curves.ease,
        child: widget.editor.isSubEditorOpen &&
                !widget.editor.isSubEditorClosing
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  controller: _bottomBarScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: min(constraints.maxWidth, 600),
                      maxWidth: 600,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (paintEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(
                                i18n.paintEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.paintingEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openPaintingEditor,
                          ),
                        if (textEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(i18n.textEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.textEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openTextEditor,
                          ),
                        if (cropRotateEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(
                                i18n.cropRotateEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.cropRotateEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openCropRotateEditor,
                          ),
                        if (tuneEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(i18n.tuneEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.tuneEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openTuneEditor,
                          ),
                        if (filterEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(
                                i18n.filterEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.filterEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openFilterEditor,
                          ),
                        if (blurEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(i18n.blurEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.blurEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: widget.editor.openBlurEditor,
                          ),
                        if (emojiEditorConfigs.enabled)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(
                                i18n.emojiEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.emojiEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: _openEmojiEditor,
                          ),
                        if (stickerEditorConfigs?.enabled == true)
                          FlatIconTextButton(
                            spacing: 7,
                            label: Text(
                                i18n.stickerEditor.bottomNavigationBarText,
                                style: _bottomTextStyle),
                            icon: Icon(
                              icons.stickerEditor.bottomNavBar,
                              size: _bottomIconSize,
                              color: _foreGroundColor,
                            ),
                            onPressed: _openStickerEditor,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
