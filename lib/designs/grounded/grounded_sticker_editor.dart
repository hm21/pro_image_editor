// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that provides the sticker editor interface in the ProImageEditor.
///
/// The [GroundedStickerEditor] allows users to browse and apply stickers to an
/// image. It includes a search bar for filtering stickers and integrates with
/// [StickerEditor] for sticker manipulation. The widget uses
/// [ProImageEditorConfigs] for configuration and [ProImageEditorCallbacks] for
/// handling user actions.
class GroundedStickerEditor extends StatefulWidget {
  /// Constructor for the [GroundedStickerEditor].
  ///
  /// Requires [configs] and [callbacks] to manage the state and interaction of
  /// the sticker editor.
  const GroundedStickerEditor({
    super.key,
    required this.configs,
    required this.callbacks,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The callbacks from the image editor.
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedStickerEditor> createState() => _GroundedStickerEditorState();
}

/// State class for [GroundedStickerEditor].
///
/// This state manages the sticker editor, including the sticker search
/// functionality and interactions with the [StickerEditor] widget. It handles
/// toggling of the search mode and provides a user interface for selecting and
/// applying stickers.
class _GroundedStickerEditorState extends State<GroundedStickerEditor> {
  final _stickerScrollController = ScrollController();
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
    _stickerScrollController.dispose();
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
                child: StickerEditor(
                  configs: widget.configs,
                  scrollController: _stickerScrollController,
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
                            widget.callbacks.stickerEditorCallbacks
                                ?.onSearchChanged
                                ?.call('');
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

  /// Builds the search bar for filtering stickers.
  ///
  /// Depending on the design mode specified in [ProImageEditorConfigs], either
  /// a Cupertino-style or Material-style search bar is displayed.
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
                    widget.callbacks.stickerEditorCallbacks?.onSearchChanged
                        ?.call(value);
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
