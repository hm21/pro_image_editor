import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Default category view
class DefaultCategoryView extends CategoryView {
  /// Constructor
  const DefaultCategoryView(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  DefaultCategoryViewState createState() => DefaultCategoryViewState();
}

/// Default Category View State
class DefaultCategoryViewState extends CategoryViewState {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: DefaultCategoryTabBar(
              widget.config,
              widget.tabController,
              widget.pageController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
            ),
          ),
          _buildExtraTab(widget.config.categoryViewConfig.extraTab),
        ],
      ),
    );
  }

  Widget _buildExtraTab(CategoryExtraTab? extraTab) {
    if (extraTab == CategoryExtraTab.BACKSPACE) {
      return BackspaceButton(
        widget.config,
        widget.state.onBackspacePressed,
        widget.state.onBackspaceLongPressed,
        widget.config.categoryViewConfig.backspaceColor,
      );
    } else if (extraTab == CategoryExtraTab.SEARCH) {
      return SearchButton(
        widget.config,
        widget.state.onShowSearchView,
        widget.config.categoryViewConfig.iconColor,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
