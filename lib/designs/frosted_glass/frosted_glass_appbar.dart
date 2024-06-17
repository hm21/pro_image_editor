import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass_effect.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

class FrostedGlassActionBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// Indicates whether the undo action is available.
  final bool canUndo;

  /// Indicates whether the redo action is available.
  final bool canRedo;

  /// Indicates whether the editor is open.
  final bool openEditor;

  /// Callback function for closing the editor.
  final Function() onClose;

  /// Callback function for undoing an action.
  final Function() onTapUndo;

  /// Callback function for redoing an action.
  final Function() onTapRedo;

  /// Callback function for done-editing.
  final Function() onTapDone;

  /// Callback function for tapping the paint editor button.
  final Function() onTapPaintEditor;

  /// Callback function for tapping the text editor button.
  final Function() onTapTextEditor;

  /// Callback function for tapping the crop/rotate editor button.
  final Function() onTapCropRotateEditor;

  /// Callback function for tapping the filter editor button.
  final Function() onTapFilterEditor;

  /// Callback function for tapping the blur editor button.
  final Function() onTapBlurEditor;

  /// Callback function for tapping the sticker editor button.
  final Function() onTapStickerEditor;

  const FrostedGlassActionBar({
    super.key,
    required this.canRedo,
    required this.canUndo,
    required this.openEditor,
    required this.configs,
    required this.onClose,
    required this.onTapDone,
    required this.onTapUndo,
    required this.onTapRedo,
    required this.onTapCropRotateEditor,
    required this.onTapFilterEditor,
    required this.onTapBlurEditor,
    required this.onTapStickerEditor,
    required this.onTapTextEditor,
    required this.onTapPaintEditor,
  });

  @override
  State<FrostedGlassActionBar> createState() => _FrostedGlassActionBarState();
}

class _FrostedGlassActionBarState extends State<FrostedGlassActionBar> {
  final Color _foregroundColor = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return widget.openEditor
        ? const SizedBox.shrink()
        : SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FrostedGlassEffect(
                          child: IconButton(
                            tooltip: widget.configs.i18n.cancel,
                            onPressed: widget.onClose,
                            icon: Icon(widget.configs.icons.closeEditor),
                          ),
                        ),
                        FrostedGlassEffect(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: widget.configs.i18n.undo,
                                onPressed: widget.onTapUndo,
                                icon: Icon(
                                  widget.configs.icons.undoAction,
                                  color: widget.canUndo
                                      ? _foregroundColor
                                      : _foregroundColor.withAlpha(80),
                                ),
                              ),
                              const SizedBox(width: 3),
                              IconButton(
                                tooltip: widget.configs.i18n.redo,
                                onPressed: widget.onTapRedo,
                                icon: Icon(
                                  widget.configs.icons.redoAction,
                                  color: widget.canRedo
                                      ? _foregroundColor
                                      : _foregroundColor.withAlpha(80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FrostedGlassEffect(
                          child: IconButton(
                            tooltip: widget.configs.i18n.done,
                            onPressed: widget.onTapDone,
                            icon: Icon(
                              widget.configs.icons.doneIcon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      child: Wrap(
                        spacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          if (widget.configs.paintEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.configs.i18n.paintEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapPaintEditor,
                              icon: Icon(widget
                                  .configs.icons.paintingEditor.bottomNavBar),
                            ),
                          if (widget.configs.textEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.configs.i18n.textEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapTextEditor,
                              icon: Icon(
                                  widget.configs.icons.textEditor.bottomNavBar),
                            ),
                          if (widget.configs.cropRotateEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.configs.i18n.cropRotateEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapCropRotateEditor,
                              icon: Icon(widget
                                  .configs.icons.cropRotateEditor.bottomNavBar),
                            ),
                          if (widget.configs.filterEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.configs.i18n.filterEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapFilterEditor,
                              icon: Icon(widget
                                  .configs.icons.filterEditor.bottomNavBar),
                            ),
                          if (widget.configs.blurEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.configs.i18n.blurEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapBlurEditor,
                              icon: Icon(
                                  widget.configs.icons.blurEditor.bottomNavBar),
                            ),
                          if (widget.configs.stickerEditorConfigs?.enabled ==
                                  true ||
                              widget.configs.emojiEditorConfigs.enabled)
                            IconButton(
                              key: const ValueKey(
                                  'whatsapp-open-sticker-editor-btn'),
                              tooltip: widget.configs.i18n.stickerEditor
                                  .bottomNavigationBarText,
                              onPressed: widget.onTapStickerEditor,
                              icon: Icon(widget
                                  .configs.icons.stickerEditor.bottomNavBar),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
                /*  AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: widget.canUndo
                      ?IconButton(
                          tooltip: widget.configs.i18n.undo,
                          onPressed: widget.onTapUndo,
                          icon: Icon(widget.configs.icons.undoAction),
                         
                        )
                      : const SizedBox.shrink(),
                ),
             */
              ],
            ),
          );
  }
}
