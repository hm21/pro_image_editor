import 'dart:math';

import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/designs/grounded/grounded_design.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';

/// A widget that provides the main bottom navigation bar for the
/// ProImageEditor.
///
/// The [GroundedMainBar] allows users to access various editing features such
/// as paint, text editing, cropping, rotating, applying filters, blurring,
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
  final _contentKey = GlobalKey();

  late final ScrollController _bottomBarScrollCtrl;

  Color get _foreGroundColor => mainEditorConfigs.style.appBarColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withValues(alpha: 0.6);

  late final _bottomTextStyle = TextStyle(
    fontSize: 10.0,
    color: _foreGroundColorAccent,
  );
  final _bottomIconSize = 22.0;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
  }

  void _setContentWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderBox? renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _contentWidth = renderBox.size.width;
      }
    });
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  void _openEmojiEditor() async {
    Layer? layer = await widget.editor.openPage(
      GroundedEmojiEditor(configs: configs, callbacks: callbacks),
    );
    if (layer == null || !mounted) return;
    layer.scale = configs.emojiEditor.initScale;
    widget.editor.addLayer(layer);
  }

  void _openStickerEditor() async {
    Layer? layer = await widget.editor.openPage(
      GroundedStickerEditor(configs: configs, callbacks: callbacks),
    );
    if (layer == null || !mounted) return;
    widget.editor.addLayer(layer);
  }

  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        EditorScrollbar(
          controller: _bottomBarScrollCtrl,
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
    _setContentWidth();
    return BottomAppBar(
      height: kGroundedSubBarHeight,
      color: mainEditorConfigs.style.bottomBarBackground,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          controller: _bottomBarScrollCtrl,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) => Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: <Widget>[...previousChildren, ?currentChild],
            ),
            duration: kGroundedFadeInDuration * 2,
            reverseDuration: const Duration(milliseconds: 0),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            switchInCurve: Curves.ease,
            child:
                widget.editor.isSubEditorOpen &&
                    !widget.editor.isSubEditorClosing
                ? SizedBox(width: _contentWidth)
                : ConstrainedBox(
                    key: _contentKey,
                    constraints: BoxConstraints(
                      minHeight: kGroundedSubBarHeight,
                      minWidth: min(constraints.maxWidth, 700),
                      maxWidth: 700,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: _buildToolList(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Creates a tool button with consistent styling.
  Widget _createToolButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FlatIconTextButton(
      spacing: 7,
      label: Text(label, style: _bottomTextStyle),
      icon: Icon(icon, size: _bottomIconSize, color: _foreGroundColor),
      onPressed: onPressed,
    );
  }

  /// Maps a SubEditorMode to its corresponding tool button configuration.
  Widget? _mapToolToButton(SubEditorMode tool) {
    switch (tool) {
      case SubEditorMode.paint:
        return _createToolButton(
          label: i18n.paintEditor.bottomNavigationBarText,
          icon: paintEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openPaintEditor,
        );

      case SubEditorMode.text:
        return _createToolButton(
          label: i18n.textEditor.bottomNavigationBarText,
          icon: textEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openTextEditor,
        );

      case SubEditorMode.cropRotate:
        return _createToolButton(
          label: i18n.cropRotateEditor.bottomNavigationBarText,
          icon: cropRotateEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openCropRotateEditor,
        );

      case SubEditorMode.tune:
        return _createToolButton(
          label: i18n.tuneEditor.bottomNavigationBarText,
          icon: tuneEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openTuneEditor,
        );

      case SubEditorMode.filter:
        return _createToolButton(
          label: i18n.filterEditor.bottomNavigationBarText,
          icon: filterEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openFilterEditor,
        );

      case SubEditorMode.blur:
        return _createToolButton(
          label: i18n.blurEditor.bottomNavigationBarText,
          icon: blurEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openBlurEditor,
        );

      case SubEditorMode.emoji:
        return _createToolButton(
          label: i18n.emojiEditor.bottomNavigationBarText,
          icon: emojiEditorConfigs.icons.bottomNavBar,
          onPressed: _openEmojiEditor,
        );

      case SubEditorMode.sticker:
        return _createToolButton(
          label: i18n.stickerEditor.bottomNavigationBarText,
          icon: stickerEditorConfigs.icons.bottomNavBar,
          onPressed: _openStickerEditor,
        );

      case SubEditorMode.audio:
        return _createToolButton(
          label: i18n.audioEditor.bottomNavigationBarText,
          icon: audioEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openAudioEditor,
        );

      case SubEditorMode.videoClips:
        return _createToolButton(
          label: i18n.clipsEditor.bottomNavigationBarText,
          icon: clipsEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openClipsEditor,
        );
    }
  }

  List<Widget> _buildToolList() {
    final tools = widget.editor.configs.mainEditor.tools;

    return tools.map(_mapToolToButton).whereType<Widget>().toList();
  }
}
