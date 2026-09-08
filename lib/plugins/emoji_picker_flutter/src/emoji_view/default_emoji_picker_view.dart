import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Default EmojiPicker Implementation
class DefaultEmojiPickerView extends EmojiPickerView {
  /// Constructor
  const DefaultEmojiPickerView(
    super.config,
    super.state,
    super.showSearchBar, {
    super.key,
  });

  @override
  State<DefaultEmojiPickerView> createState() => _DefaultEmojiPickerViewState();
}

class _DefaultEmojiPickerViewState extends State<DefaultEmojiPickerView>
    with SingleTickerProviderStateMixin, SkinToneOverlayStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    var initCategory = widget.state.categoryEmoji.indexWhere(
      (element) =>
          element.category == widget.config.categoryViewConfig.initCategory,
    );
    if (initCategory == -1) {
      initCategory = 0;
    }
    _tabController = TabController(
      initialIndex: initCategory,
      length: widget.state.categoryEmoji.length,
      vsync: this,
    );
    _pageController = PageController(initialPage: initCategory)
      ..addListener(closeSkinToneOverlay);
    _scrollController.addListener(closeSkinToneOverlay);
    super.initState();
  }

  @override
  void dispose() {
    closeSkinToneOverlay();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.emojiViewConfig.getEmojiSize(
          constraints.maxWidth,
        );
        final emojiBoxSize = widget.config.emojiViewConfig.getEmojiBoxSize(
          constraints.maxWidth,
        );
        return EmojiContainer(
          color: widget.config.emojiViewConfig.backgroundColor,
          buttonMode: widget.config.emojiViewConfig.buttonMode,
          child: Column(
            children:
                [
                  widget.config.viewOrderConfig.top,
                  widget.config.viewOrderConfig.middle,
                  widget.config.viewOrderConfig.bottom,
                ].map((item) {
                  switch (item) {
                    case EmojiPickerItem.categoryBar:
                      // Category view
                      return _buildCategoryView();
                    case EmojiPickerItem.emojiView:
                      // Emoji view
                      return _buildEmojiView(emojiSize, emojiBoxSize);
                    case EmojiPickerItem.searchBar:
                      // Search Bar
                      return _buildBottomSearchBar();
                  }
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryView() {
    return widget.config.categoryViewConfig.customCategoryView != null
        ? widget.config.categoryViewConfig.customCategoryView!(
            widget.config,
            widget.state,
            _tabController,
            _pageController,
          )
        : DefaultCategoryView(
            widget.config,
            widget.state,
            _tabController,
            _pageController,
          );
  }

  Widget _buildEmojiView(double emojiSize, double emojiBoxSize) {
    return Flexible(
      child: PageView.builder(
        itemCount: widget.state.categoryEmoji.length,
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(
            index,
            duration: widget.config.categoryViewConfig.tabIndicatorAnimDuration,
          );
        },
        itemBuilder: (context, index) => _buildPage(
          emojiSize,
          emojiBoxSize,
          widget.state.categoryEmoji[index],
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar() {
    if (!widget.config.bottomActionBarConfig.enabled) {
      return const SizedBox.shrink();
    }
    return widget.config.bottomActionBarConfig.customBottomActionBar != null
        ? widget.config.bottomActionBarConfig.customBottomActionBar!(
            widget.config,
            widget.state,
            widget.showSearchBar,
          )
        : DefaultBottomActionBar(
            widget.config,
            widget.state,
            widget.showSearchBar,
          );
  }

  Widget _buildPage(
    double emojiSize,
    double emojiBoxSize,
    CategoryEmoji categoryEmoji,
  ) {
    // Display notice if recent has no entries yet
    if (categoryEmoji.category == Category.RECENT &&
        categoryEmoji.emoji.isEmpty) {
      return _buildNoRecent();
    }
    // Build page normally
    return GridView.builder(
      key: const Key('emojiScrollView'),
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      primary: false,
      padding: widget.config.emojiViewConfig.gridPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1,
        crossAxisCount: widget.config.emojiViewConfig.columns,
        mainAxisSpacing: widget.config.emojiViewConfig.verticalSpacing,
        crossAxisSpacing: widget.config.emojiViewConfig.horizontalSpacing,
      ),
      itemCount: categoryEmoji.emoji.length,
      itemBuilder: (context, index) {
        return addSkinToneTargetIfAvailable(
          hasSkinTone: categoryEmoji.emoji[index].hasSkinTone,
          linkKey:
              categoryEmoji.category.name + categoryEmoji.emoji[index].emoji,
          child: EmojiCell.fromConfig(
            emoji: categoryEmoji.emoji[index],
            emojiSize: emojiSize,
            emojiBoxSize: emojiBoxSize,
            categoryEmoji: categoryEmoji,
            onEmojiSelected: _onSkinTonedEmojiSelected,
            onSkinToneDialogRequested: _openSkinToneDialog,
            config: widget.config,
          ),
        );
      },
    );
  }

  /// Build Widget for when no recent emoji are available
  Widget _buildNoRecent() {
    return Center(child: widget.config.emojiViewConfig.noRecents);
  }

  void _openSkinToneDialog(
    Offset emojiBoxPosition,
    Emoji emoji,
    double emojiSize,
    CategoryEmoji? categoryEmoji,
  ) {
    closeSkinToneOverlay();
    if (!emoji.hasSkinTone || !widget.config.skinToneConfig.enabled) {
      return;
    }
    showSkinToneOverlay(
      emojiBoxPosition,
      emoji,
      emojiSize,
      categoryEmoji,
      widget.config,
      _onSkinTonedEmojiSelected,
      links[categoryEmoji!.category.name + emoji.emoji]!,
    );
  }

  void _onSkinTonedEmojiSelected(Category? category, Emoji emoji) {
    widget.state.onEmojiSelected(category, emoji);
    closeSkinToneOverlay();
  }
}
