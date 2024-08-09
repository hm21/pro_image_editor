// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/modules/emoji_editor/emoji_editor.dart';
import 'package:pro_image_editor/modules/sticker_editor/sticker_editor.dart';
import '../../models/editor_configs/pro_image_editor_configs.dart';

/// Represents the temporary sticker mode for Frosted-Glass.
///
/// This variable defines the temporary sticker mode for Frosted-Glass,
/// indicating whether stickers or emojis are being used.
FrostedGlassStickerMode temporaryStickerMode = FrostedGlassStickerMode.emoji;

/// Represents the sticker-editor page for the Frosted-Glass theme.
///
/// This page provides an interface for adding and managing stickers and emojis
/// on images, following the frosted-glass design theme.
class FrostedGlassStickerPage extends StatefulWidget {
  /// Creates a [FrostedGlassStickerPage].
  ///
  /// This page integrates with the frosted-glass theme to offer a user-friendly
  /// interface for selecting and applying stickers or emojis to images.
  ///
  /// Example:
  /// ```
  /// FrostedGlassStickerPage(
  ///   configs: myEditorConfigs,
  ///   callbacks: myEditorCallbacks,
  /// )
  /// ```
  const FrostedGlassStickerPage({
    super.key,
    required this.configs,
    required this.callbacks,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The callbacks from the image editor.
  final ProImageEditorCallbacks callbacks;

  @override
  State<FrostedGlassStickerPage> createState() =>
      _FrostedGlassStickerPageState();
}

class _FrostedGlassStickerPageState extends State<FrostedGlassStickerPage> {
  final _emojiEditorKey = GlobalKey<EmojiEditorState>();
  final _stickerScrollController = ScrollController();
  bool _activeSearch = false;
  late TextEditingController _searchCtrl;
  late FocusNode _searchFocus;

  @override
  void initState() {
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
    if (!widget.configs.emojiEditorConfigs.enabled) {
      temporaryStickerMode = FrostedGlassStickerMode.sticker;
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _stickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrostedGlassEffect(
      radius: BorderRadius.zero,
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: Column(
            children: [
              ..._buildHeader(),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Offstage(
                      offstage:
                          temporaryStickerMode != FrostedGlassStickerMode.emoji,
                      child: EmojiEditor(
                        key: _emojiEditorKey,
                        configs: widget.configs,
                      ),
                    ),
                    if (widget.configs.stickerEditorConfigs != null)
                      Offstage(
                        offstage: temporaryStickerMode !=
                            FrostedGlassStickerMode.sticker,
                        child: StickerEditor(
                          configs: widget.configs,
                          scrollController: _stickerScrollController,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader() {
    return [
      Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        color: Colors.black12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
              tooltip: widget.configs.i18n.cancel,
              onPressed: () {
                if (_activeSearch) {
                  setState(() {
                    _searchCtrl.clear();
                    _activeSearch = false;
                    widget.callbacks.stickerEditorCallbacks?.onSearchChanged
                        ?.call('');
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                widget.configs.icons.backButton,
                color: Colors.white,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
              onPressed: null,
              icon: Icon(
                widget.configs.icons.stickerEditor.bottomNavBar,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _activeSearch
              ? _buildSearchBar()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _activeSearch = !_activeSearch;
                          });
                        },
                        icon: const Icon(Icons.search),
                        color: Colors.white,
                      ),
                    ),
                    if (widget.configs.stickerEditorConfigs != null)
                      Align(
                        alignment: Alignment.center,
                        child: SegmentedButton(
                          showSelectedIcon: false,
                          emptySelectionAllowed: false,
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white38,
                            foregroundColor: Colors.white,
                            selectedForegroundColor: Colors.black,
                            selectedBackgroundColor: Colors.white,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          segments: [
                            ButtonSegment(
                              value: FrostedGlassStickerMode.sticker,
                              label: Text(
                                widget.configs.i18n.stickerEditor
                                    .bottomNavigationBarText,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: FrostedGlassStickerMode.emoji,
                              label: Text(
                                widget.configs.i18n.emojiEditor
                                    .bottomNavigationBarText,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          selected: {temporaryStickerMode},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              temporaryStickerMode = newSelection.first;
                            });
                          },
                        ),
                      )
                  ],
                ),
        ),
      ),
    ];
  }

  Widget _buildSearchBar() {
    if (widget.configs.designMode == ImageEditorDesignModeE.cupertino) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                autofocus: true,
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (value) {
                  _emojiEditorKey.currentState?.externSearch(value);
                  widget.callbacks.stickerEditorCallbacks?.onSearchChanged
                      ?.call(value);
                  _searchFocus.requestFocus();
                  Future.delayed(const Duration(milliseconds: 1))
                      .whenComplete(() {
                    _searchFocus.requestFocus();
                  });
                },
                itemColor: const Color.fromARGB(255, 243, 243, 243),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            CupertinoButton(
              child: Text(widget.configs.i18n.cancel),
              onPressed: () {
                setState(() {
                  _activeSearch = false;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TextField(
                  autofocus: true,
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  onChanged: (value) {
                    _emojiEditorKey.currentState?.externSearch(value);
                    widget.callbacks.stickerEditorCallbacks?.onSearchChanged
                        ?.call(value);
                    _searchFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.configs.i18n.emojiEditor.search,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  if (_searchCtrl.text.isNotEmpty) {
                    _searchCtrl.clear();
                    widget.callbacks.stickerEditorCallbacks?.onSearchChanged
                        ?.call('');
                  } else {
                    _activeSearch = false;
                  }
                });
              },
            ),
          ],
        ),
      );
    }
  }
}

/// An enumeration representing the modes for frosted glass sticker
/// functionality.
///
/// This enum is used to define the different modes available in the frosted
/// glass sticker feature, such as adding stickers or emojis to an image.

enum FrostedGlassStickerMode {
  /// Mode for adding stickers.
  ///
  /// This mode allows the user to select and place various stickers on an
  /// image, enhancing the visual content with decorative elements.
  sticker,

  /// Mode for adding emojis.
  ///
  /// This mode allows the user to select and place emojis on an image,
  /// providing a fun and expressive way to enhance visual content.
  emoji,
}
