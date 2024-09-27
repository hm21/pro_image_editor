// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/modules/emoji_editor/emoji_editor.dart';
import '../../models/editor_configs/pro_image_editor_configs.dart';

/// A widget that provides an interface for selecting and editing emojis in the
/// ProImageEditor.
///
/// The [GroundedEmojiEditor] allows users to search for and add emojis to an
/// image using the ProImageEditor package. It includes a search bar that can
/// be activated or dismissed and integrates with the [EmojiEditor] to display
/// available emojis.
class GroundedEmojiEditor extends StatefulWidget {
  /// Constructor for the [GroundedEmojiEditor].
  ///
  /// Requires [configs] and [callbacks] parameters to provide necessary editor
  /// configurations and callbacks.
  const GroundedEmojiEditor({
    super.key,
    required this.configs,
    required this.callbacks,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The callbacks from the image editor.
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedEmojiEditor> createState() => _GroundedEmojiEditorState();
}

/// State class for [GroundedEmojiEditor].
///
/// This state manages the emoji editor interface, including the search bar
/// and interaction with the [EmojiEditor]. It handles the activation of the
/// search mode and the display of emojis.
class _GroundedEmojiEditorState extends State<GroundedEmojiEditor> {
  final _emojiEditorKey = GlobalKey<EmojiEditorState>();
  bool _activeSearch = false;
  late TextEditingController _searchCtrl;
  late FocusNode _searchFocus;

  @override
  void initState() {
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color foreGroundColor =
        widget.configs.imageEditorTheme.appBarForegroundColor;
    return FrostedGlassEffect(
      radius: BorderRadius.zero,
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 7),
              Expanded(
                child: EmojiEditor(
                  key: _emojiEditorKey,
                  configs: widget.configs,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                color: const Color(0xFF222222),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: widget.configs.i18n.cancel,
                      onPressed: () {
                        if (_activeSearch) {
                          setState(() {
                            _searchCtrl.clear();
                            _activeSearch = false;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        widget.configs.icons.closeEditor,
                        color: foreGroundColor,
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _activeSearch
                            ? _buildSearchBar()
                            : Align(
                                alignment: Alignment.centerRight,
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
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the search bar based on the design mode.
  ///
  /// It switches between a Cupertino-style search bar or a Material-style one
  /// depending on the design mode in [ProImageEditorConfigs].
  Widget _buildSearchBar() {
    if (widget.configs.designMode == ImageEditorDesignModeE.cupertino) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
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
                    _searchFocus.requestFocus();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        ),
      );
    } else {
      return Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
