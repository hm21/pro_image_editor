import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/i18n/i18n_emoji_editor.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/emoji_editor/utils/emoji_state_manager.dart';

import '../../../utils/pro_image_editor_mode.dart';
import 'emoji_cell_extended.dart';

/// A widget that provides an enhanced emoji picker view.
///
/// This class extends [EmojiPickerView] to offer additional configuration and
/// customization options for displaying an emoji picker, including support for
/// internationalization and theming.
class ProEmojiPickerView extends EmojiPickerView {
  /// Creates an instance of [ProEmojiPickerView].
  ///
  /// The constructor initializes the emoji picker with the provided
  /// configuration, state, search bar visibility control, and additional
  /// settings for internationalization and theming.
  ///
  /// Example:
  /// ```
  /// ProEmojiPickerView(
  ///   config: myConfig,
  ///   state: myState,
  ///   showSearchBar: () => setState(() => showSearch = true),
  ///   scrollController: myScrollController,
  ///   i18nEmojiEditor: myI18nEmojiEditor,
  ///   themeEmojiEditor: myThemeEmojiEditor,
  /// )
  /// ```
  const ProEmojiPickerView({
    required Config config,
    required EmojiViewState state,
    required VoidCallback showSearchBar,
    required this.scrollController,
    required this.i18nEmojiEditor,
    required this.themeEmojiEditor,
    super.key,
  }) : super(config, state, showSearchBar);

  /// The scroll controller for the emoji picker view.
  ///
  /// This [ScrollController] allows for controlling and monitoring the
  /// scrolling behavior of the emoji picker list, enhancing navigation.
  final ScrollController? scrollController;

  /// Internationalization settings for the emoji editor.
  ///
  /// This [I18nEmojiEditor] object provides localized text and messages for
  /// the emoji picker, allowing for multilingual support.
  final I18nEmojiEditor i18nEmojiEditor;

  /// Theme settings for the emoji editor.
  ///
  /// This [EmojiEditorTheme] object contains styling options for the emoji
  /// picker, enabling customization of colors, fonts, and other visual
  /// aspects.
  final EmojiEditorTheme themeEmojiEditor;

  @override
  State<ProEmojiPickerView> createState() => _DefaultEmojiPickerViewState();
}

class _DefaultEmojiPickerViewState extends State<ProEmojiPickerView>
    with SingleTickerProviderStateMixin, SkinToneOverlayStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late final ScrollController _scrollController;
  Category _activeCategory = Category.RECENT;

  final GlobalKey _searchBarKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};

  bool _activeTabChange = false;

  late double _emojiSize;
  late double _emojiBoxSize;
  late TextStyle _emojiStyle;

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    var initCategory = _categories.indexWhere((element) =>
        element.category == widget.config.categoryViewConfig.initCategory);
    if (initCategory == -1) {
      initCategory = 0;
    }
    _tabController = TabController(
      initialIndex: initCategory,
      length: _categories.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _pageController = PageController(initialPage: initCategory)
      ..addListener(closeSkinToneOverlay);

    _scrollController.addListener(closeSkinToneOverlay);

    for (int i = 0; i < _categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    super.initState();
  }

  void _setActiveCategory(Category category) {
    setState(() {
      _activeCategory = category;
      closeSkinToneOverlay();
      int i = _categories.indexWhere((el) => el.category.name == category.name);
      if (i >= 0) _scrollToItem(i);
    });
  }

  double get _searchBarHeight {
    final RenderBox? searchRenderBox =
        _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (searchRenderBox == null) return 0;
    return searchRenderBox.size.height;
  }

  void _scrollToItem(int index) {
    final GlobalKey key = _itemKeys[index]!;
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero,
        ancestor: context.findRenderObject());

    final offset = position.dy + _scrollController.offset - _searchBarHeight;

    _activeTabChange = true;

    if (widget.themeEmojiEditor.scrollToDuration.inMilliseconds == 0) {
      _scrollController.jumpTo(offset);
      _tabController.animateTo(index);
    } else {
      _scrollController.animateTo(
        offset,
        duration: widget.themeEmojiEditor.scrollToDuration,
        curve: Curves.easeInOut,
      );

      _tabController.animateTo(
        index,
        duration: widget.themeEmojiEditor.scrollToDuration,
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(
        Duration(
          milliseconds:
              max(widget.themeEmojiEditor.scrollToDuration.inMilliseconds, 200),
        ), () {
      _activeTabChange = false;
    });
  }

  void _onScroll() {
    double searchHeight = _searchBarHeight;
    if (_activeTabChange) return;
    for (int i = _itemKeys.length - 1; i >= 0; i--) {
      final key = _itemKeys[i];

      final context = key!.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox;

        final position = renderBox.localToGlobal(
          Offset.zero,
          ancestor: this.context.findRenderObject(),
        );

        var category = _categories[i].category;
        final double dy = position.dy - searchHeight;

        if (dy < 0) {
          if (_activeCategory.name != category.name) {
            _activeCategory = category;
            _tabController.animateTo(i);
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    closeSkinToneOverlay();
    _pageController.dispose();
    if (widget.scrollController == null) _scrollController.dispose();
    super.dispose();
  }

  String _i18nCategoryName(Category category) {
    switch (category) {
      case Category.RECENT:
        return widget.i18nEmojiEditor.categoryRecent;
      case Category.SMILEYS:
        return widget.i18nEmojiEditor.categorySmileys;
      case Category.ANIMALS:
        return widget.i18nEmojiEditor.categoryAnimals;
      case Category.FOODS:
        return widget.i18nEmojiEditor.categoryFood;
      case Category.ACTIVITIES:
        return widget.i18nEmojiEditor.categoryActivities;
      case Category.TRAVEL:
        return widget.i18nEmojiEditor.categoryTravel;
      case Category.OBJECTS:
        return widget.i18nEmojiEditor.categoryObjects;
      case Category.SYMBOLS:
        return widget.i18nEmojiEditor.categorySymbols;
      case Category.FLAGS:
        return widget.i18nEmojiEditor.categoryFlags;
    }
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

  void _setEmojiTextStyle() {
    final defaultStyle = DefaultEmojiTextStyle.copyWith(
      fontSize: _emojiSize,
      inherit: true,
    );
    // textStyle properties have priority over defaultStyle
    _emojiStyle = widget.config.emojiTextStyle == null
        ? defaultStyle
        : defaultStyle.merge(widget.config.emojiTextStyle);
  }

  List<CategoryEmoji> get _categories {
    return widget.state.categoryEmoji
        .where((el) => el.emoji.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return EmojiStateManager(
      activeCategory: _activeCategory,
      setActiveCategory: _setActiveCategory,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _emojiSize =
              widget.config.emojiViewConfig.getEmojiSize(constraints.maxWidth);

          _emojiBoxSize = widget.config.emojiViewConfig
              .getEmojiBoxSize(constraints.maxWidth);
          _setEmojiTextStyle();

          return EmojiContainer(
            color: widget.themeEmojiEditor.backgroundColor,
            buttonMode: widget.config.emojiViewConfig.buttonMode,
            child: Column(
              children: [
                widget.config.viewOrderConfig.top,
                widget.config.viewOrderConfig.middle,
                widget.config.viewOrderConfig.bottom,
              ].map(
                (item) {
                  switch (item) {
                    case EmojiPickerItem.categoryBar:
                      // Category view
                      return _buildCategoryView();
                    case EmojiPickerItem.emojiView:
                      // Emoji view
                      return _buildEmojiView();
                    case EmojiPickerItem.searchBar:
                      // Search Bar
                      return _buildSearchBar();
                  }
                },
              ).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmojiView() {
    List<Widget> pages = [];
    for (int i = 0; i < _categories.length; i++) {
      var page = _categories[i];
      if (page.emoji.isNotEmpty) {
        pages.addAll([
          SliverPadding(
            padding: widget.themeEmojiEditor.categoryTitlePadding,
            sliver: SliverToBoxAdapter(
              child: Text(
                _i18nCategoryName(page.category),
                key: _itemKeys[i],
                style: widget.themeEmojiEditor.categoryTitleStyle,
              ),
            ),
          ),
          _buildPage(page),
        ]);
      }
    }

    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        scrollbarOrientation: ScrollbarOrientation.right,
        thumbVisibility: isDesktop,
        trackVisibility: isDesktop,
        notificationPredicate: (notification) {
          if (notification is ScrollUpdateNotification) {
            _onScroll();
          }
          return true;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: pages,
        ),
      ),
    );
  }

  Widget _buildPage(CategoryEmoji categoryEmoji) {
    // Build page normally
    return SliverPadding(
      padding: widget.config.emojiViewConfig.gridPadding.copyWith(
        bottom: widget.config.emojiViewConfig.gridPadding.bottom + 20,
      ),
      sliver: SliverGrid.builder(
        key: ValueKey('emojiScrollView-${categoryEmoji.category.name}'),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: widget.config.emojiViewConfig.columns,
          mainAxisSpacing: widget.config.emojiViewConfig.verticalSpacing,
          crossAxisSpacing: widget.config.emojiViewConfig.horizontalSpacing,
        ),
        itemCount: categoryEmoji.emoji.length,
        itemBuilder: (context, index) {
          Widget cell = EmojiCellExtended(
            emoji: categoryEmoji.emoji[index],
            emojiSize: _emojiSize,
            emojiBoxSize: _emojiBoxSize,
            categoryEmoji: categoryEmoji,
            emojiStyle: _emojiStyle,
            onEmojiSelected: _onSkinTonedEmojiSelected,
            onSkinToneDialogRequested: _openSkinToneDialog,
            buttonMode: widget.config.emojiViewConfig.buttonMode,
            enableSkinTones: widget.config.skinToneConfig.enabled,
            skinToneIndicatorColor: widget.config.skinToneConfig.indicatorColor,
          );

          if (!categoryEmoji.emoji[index].hasSkinTone) {
            return cell;
          } else {
            return addSkinToneTargetIfAvailableExtended(
              linkKey: categoryEmoji.category.name +
                  categoryEmoji.emoji[index].emoji,
              child: cell,
            );
          }
        },
      ),
    );
  }

  Widget addSkinToneTargetIfAvailableExtended({
    required String linkKey,
    required Widget child,
  }) {
    final link = links.putIfAbsent(linkKey, LayerLink.new);
    return CompositedTransformTarget(
      link: link,
      child: child,
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

  Widget _buildSearchBar() {
    if (!widget.config.bottomActionBarConfig.enabled) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      key: _searchBarKey,
      child: widget.config.bottomActionBarConfig.customBottomActionBar != null
          ? widget.config.bottomActionBarConfig.customBottomActionBar!(
              widget.config,
              widget.state,
              widget.showSearchBar,
            )
          : DefaultBottomActionBar(
              widget.config,
              widget.state,
              widget.showSearchBar,
            ),
    );
  }
}
