// Flutter imports:
import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '../../frosted_glass.dart';
import '../frosted_glass_effect.dart';

/// A custom action bar widget with a frosted glass effect, designed for use
/// within an image editing application. This widget provides an interface for
/// users to interact with the image editor and access the sticker editor
/// feature.
class FrostedGlassActionBar extends StatefulWidget {
  /// Creates a [FrostedGlassActionBar].
  ///
  /// The [editor] and [openStickerEditor] parameters are required to configure
  /// the action bar's behavior. The [editor] parameter provides access to the
  /// image editor's state, allowing the action bar to interact with and modify
  /// the image being edited. The [openStickerEditor] parameter is a callback
  /// function that opens the sticker editor when invoked.
  ///
  /// Example:
  /// ```
  /// FrostedGlassActionBar(
  ///   editor: myEditorState,
  ///   openStickerEditor: () => myStickerEditorFunction(),
  /// )
  /// ```
  const FrostedGlassActionBar({
    super.key,
    required this.editor,
    required this.openStickerEditor,
  });

  /// The configuration for the image editor.
  final ProImageEditorState editor;

  /// A callback function to open the sticker editor.
  ///
  /// This function is invoked when the user wishes to add or edit stickers
  /// on the image. The function should be defined in the parent widget and
  /// passed to this action bar to handle the opening of the sticker editor
  /// interface.
  final Function() openStickerEditor;

  @override
  State<FrostedGlassActionBar> createState() => _FrostedGlassActionBarState();
}

class _FrostedGlassActionBarState extends State<FrostedGlassActionBar> {
  final Color _foregroundColor = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'frosted-glass-close-btn',
                    child: FrostedGlassEffect(
                      child: GestureInterceptor(
                        child: IconButton(
                          tooltip: widget.editor.configs.i18n.cancel,
                          onPressed: widget.editor.closeEditor,
                          icon: Icon(widget
                              .editor.mainEditorConfigs.icons.closeEditor),
                          color: _foregroundColor,
                        ),
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'frosted-glass-top-center-bar',
                    child: FrostedGlassEffect(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        children: [
                          GestureInterceptor(
                            child: IconButton(
                              tooltip: widget.editor.configs.i18n.undo,
                              onPressed: widget.editor.undoAction,
                              icon: Icon(
                                widget
                                    .editor.mainEditorConfigs.icons.undoAction,
                                color: widget.editor.canUndo
                                    ? _foregroundColor
                                    : _foregroundColor.withAlpha(80),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          GestureInterceptor(
                            child: IconButton(
                              tooltip: widget.editor.configs.i18n.redo,
                              onPressed: widget.editor.redoAction,
                              icon: Icon(
                                widget
                                    .editor.mainEditorConfigs.icons.redoAction,
                                color: widget.editor.canRedo
                                    ? _foregroundColor
                                    : _foregroundColor.withAlpha(80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'frosted-glass-done-btn',
                    child: FrostedGlassEffect(
                      child: GestureInterceptor(
                        child: IconButton(
                          tooltip: widget.editor.configs.i18n.done,
                          onPressed: widget.editor.doneEditing,
                          icon: Icon(
                            widget.editor.mainEditorConfigs.icons.doneIcon,
                            color: _foregroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.editor.isSubEditorOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                key: const PageStorageKey('frosted_glass_main_bottombar'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24,
                ),
                scrollDirection: Axis.horizontal,
                child: FrostedGlassEffect(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: GestureInterceptor(
                    child: Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildItemList(),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  List<Widget> _buildItemList() {
    final tools = widget.editor.configs.mainEditor.tools;

    return tools
        .map((tool) {
          switch (tool) {
            case SubEditorMode.paint:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.paintEditor.bottomNavigationBarText,
                onPressed: widget.editor.openPaintEditor,
                icon: Icon(widget.editor.paintEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.text:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.textEditor.bottomNavigationBarText,
                onPressed: () => widget.editor.openTextEditor(
                  duration: const Duration(milliseconds: 150),
                ),
                icon: Icon(widget.editor.textEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.cropRotate:
              return IconButton(
                tooltip: widget.editor.configs.i18n.cropRotateEditor
                    .bottomNavigationBarText,
                onPressed: widget.editor.openCropRotateEditor,
                icon: Icon(
                    widget.editor.cropRotateEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.tune:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.tuneEditor.bottomNavigationBarText,
                onPressed: () =>
                    widget.editor.openTuneEditor(enableHero: false),
                icon: Icon(widget.editor.tuneEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.filter:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.filterEditor.bottomNavigationBarText,
                onPressed: widget.editor.openFilterEditor,
                icon:
                    Icon(widget.editor.filterEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.blur:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.blurEditor.bottomNavigationBarText,
                onPressed: widget.editor.openBlurEditor,
                icon: Icon(widget.editor.blurEditorConfigs.icons.bottomNavBar),
              );

            case SubEditorMode.emoji:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.stickerEditor.bottomNavigationBarText,
                onPressed: widget.openStickerEditor,
                icon:
                    Icon(widget.editor.stickerEditorConfigs.icons.bottomNavBar),
              );
            case SubEditorMode.sticker:
              return null;
            case SubEditorMode.audio:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.audioEditor.bottomNavigationBarText,
                onPressed: widget.editor.openAudioEditor,
                icon: Icon(widget.editor.audioEditorConfigs.icons.bottomNavBar),
              );
            case SubEditorMode.videoClips:
              return IconButton(
                tooltip: widget
                    .editor.configs.i18n.clipsEditor.bottomNavigationBarText,
                onPressed: widget.editor.openClipsEditor,
                icon: Icon(widget.editor.clipsEditorConfigs.icons.bottomNavBar),
              );
          }
        })
        .whereType<Widget>()
        .toList();
  }
}
