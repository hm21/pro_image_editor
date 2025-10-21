import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../controllers/main_editor_controllers.dart';
import '../services/sizes_manager.dart';

/// A widget representing the bottom bar for the main editor, providing access
/// to various editing tools like paint, text, crop, filters, and more.
class MainEditorBottombar extends StatelessWidget {
  /// Creates a `MainEditorBottombar` with the provided configurations,
  /// controllers,
  /// and callbacks for opening different editor tools.
  ///
  /// - [controllers]: Manages the main editor's controllers.
  /// - [configs]: Configuration settings for the editor.
  /// - [sizesManager]: Handles size-related settings for the bottom bar.
  /// - [bottomBarKey]: A unique key for managing the bottom bar widget's state.
  /// - [theme]: The theme data for styling the bottom bar.
  /// - [openPaintEditor]: Callback for opening the paint editor.
  /// - [openTextEditor]: Callback for opening the text editor.
  /// - [openCropRotateEditor]: Callback for opening the crop and rotate editor.
  /// - [openTuneEditor]: Callback for opening the tuning editor.
  /// - [openFilterEditor]: Callback for opening the filter editor.
  /// - [openBlurEditor]: Callback for opening the blur editor.
  /// - [openEmojiEditor]: Callback for opening the emoji editor.
  /// - [openStickerEditor]: Callback for opening the sticker editor.
  const MainEditorBottombar({
    super.key,
    required this.controllers,
    required this.configs,
    required this.sizesManager,
    required this.bottomBarKey,
    required this.theme,
    required this.openPaintEditor,
    required this.openTextEditor,
    required this.openCropRotateEditor,
    required this.openTuneEditor,
    required this.openFilterEditor,
    required this.openBlurEditor,
    required this.openEmojiEditor,
    required this.openStickerEditor,
    required this.openAudioEditor,
    required this.openClipsEditor,
  });

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Handles size-related settings for the bottom bar.
  final SizesManager sizesManager;

  /// A unique key for managing the bottom bar widget's state.
  final GlobalKey<State<StatefulWidget>> bottomBarKey;

  /// The theme data for styling the bottom bar.
  final ThemeData theme;

  /// Callback for opening the paint editor.
  final Function() openPaintEditor;

  /// Callback for opening the text editor.
  final Function() openTextEditor;

  /// Callback for opening the crop and rotate editor.
  final Function() openCropRotateEditor;

  /// Callback for opening the tuning editor.
  final Function() openTuneEditor;

  /// Callback for opening the filter editor.
  final Function() openFilterEditor;

  /// Callback for opening the blur editor.
  final Function() openBlurEditor;

  /// Callback for opening the emoji editor.
  final Function() openEmojiEditor;

  /// Callback for opening the sticker editor.
  final Function() openStickerEditor;

  /// Callback for opening the audio editor.
  final Function() openAudioEditor;

  /// Callback for opening the clips editor.
  final Function() openClipsEditor;

  final double _bottomIconSize = 22.0;
  Color get _foregroundColor => configs.mainEditor.style.bottomBarColor;
  TextStyle get _bottomTextStyle => TextStyle(
        fontSize: 10.0,
        color: _foregroundColor,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: bottomBarKey,
      child: LayoutBuilder(builder: (context, constraints) {
        return Theme(
          data: theme,
          child: EditorScrollbar(
            controller: controllers.bottomBarScrollCtrl,
            child: BottomAppBar(
              height: kBottomNavigationBarHeight,
              color: configs.mainEditor.style.bottomBarBackground,
              padding: EdgeInsets.zero,
              child: Center(
                child: SingleChildScrollView(
                  controller: controllers.bottomBarScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: min(
                          sizesManager.lastScreenSize.width != 0
                              ? sizesManager.lastScreenSize.width
                              : constraints.maxWidth,
                          700),
                      maxWidth: 700,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: _buildEditorButtons(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Builds a list of editor action buttons dynamically
  List<Widget> _buildEditorButtons() {
    return configs.mainEditor.tools
        .map((tool) {
          switch (tool) {
            case SubEditorMode.paint:
              return _buildActionButton(
                key: const ValueKey('open-paint-editor-btn'),
                label: configs.i18n.paintEditor.bottomNavigationBarText,
                icon: configs.paintEditor.icons.bottomNavBar,
                onPressed: openPaintEditor,
              );

            case SubEditorMode.text:
              return _buildActionButton(
                key: const ValueKey('open-text-editor-btn'),
                label: configs.i18n.textEditor.bottomNavigationBarText,
                icon: configs.textEditor.icons.bottomNavBar,
                onPressed: openTextEditor,
              );

            case SubEditorMode.cropRotate:
              return _buildActionButton(
                key: const ValueKey('open-crop-rotate-editor-btn'),
                label: configs.i18n.cropRotateEditor.bottomNavigationBarText,
                icon: configs.cropRotateEditor.icons.bottomNavBar,
                onPressed: openCropRotateEditor,
              );

            case SubEditorMode.tune:
              return _buildActionButton(
                key: const ValueKey('open-tune-editor-btn'),
                label: configs.i18n.tuneEditor.bottomNavigationBarText,
                icon: configs.tuneEditor.icons.bottomNavBar,
                onPressed: openTuneEditor,
              );

            case SubEditorMode.filter:
              return _buildActionButton(
                key: const ValueKey('open-filter-editor-btn'),
                label: configs.i18n.filterEditor.bottomNavigationBarText,
                icon: configs.filterEditor.icons.bottomNavBar,
                onPressed: openFilterEditor,
              );

            case SubEditorMode.blur:
              return _buildActionButton(
                key: const ValueKey('open-blur-editor-btn'),
                label: configs.i18n.blurEditor.bottomNavigationBarText,
                icon: configs.blurEditor.icons.bottomNavBar,
                onPressed: openBlurEditor,
              );

            case SubEditorMode.emoji:
              return _buildActionButton(
                key: const ValueKey('open-emoji-editor-btn'),
                label: configs.i18n.emojiEditor.bottomNavigationBarText,
                icon: configs.emojiEditor.icons.bottomNavBar,
                onPressed: openEmojiEditor,
              );

            case SubEditorMode.sticker:
              return _buildActionButton(
                key: const ValueKey('open-sticker-editor-btn'),
                label: configs.i18n.stickerEditor.bottomNavigationBarText,
                icon: configs.stickerEditor.icons.bottomNavBar,
                onPressed: openStickerEditor,
              );
            case SubEditorMode.audio:
              return _buildActionButton(
                key: const ValueKey('open-audio-editor-btn'),
                label: configs.i18n.audioEditor.bottomNavigationBarText,
                icon: configs.audioEditor.icons.bottomNavBar,
                onPressed: openAudioEditor,
              );
            case SubEditorMode.videoClips:
              return _buildActionButton(
                key: const ValueKey('open-clips-editor-btn'),
                label: configs.i18n.clipsEditor.bottomNavigationBarText,
                icon: configs.clipsEditor.icons.bottomNavBar,
                onPressed: openClipsEditor,
              );
          }
        })
        .whereType<Widget>()
        .toList();
  }

  /// Helper to build a single action button
  Widget _buildActionButton({
    required ValueKey<String> key,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FlatIconTextButton(
      key: key,
      label: Text(label, style: _bottomTextStyle),
      icon: Icon(icon, size: _bottomIconSize, color: _foregroundColor),
      onPressed: onPressed,
    );
  }
}
