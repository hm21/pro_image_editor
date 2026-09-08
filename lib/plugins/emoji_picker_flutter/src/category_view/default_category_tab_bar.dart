import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Default category tab bar
class DefaultCategoryTabBar extends StatelessWidget {
  /// Constructor
  const DefaultCategoryTabBar(
    this.config,
    this.tabController,
    this.pageController,
    this.categoryEmojis,
    this.closeSkinToneOverlay, {
    super.key,
  });

  /// Config
  final Config config;

  /// Tab controller
  final TabController tabController;

  /// Page controller
  final PageController pageController;

  /// Category emojis
  final List<CategoryEmoji> categoryEmojis;

  /// Close skin tone overlay callback
  final VoidCallback closeSkinToneOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.categoryViewConfig.tabBarHeight,
      child: TabBar(
        labelColor: config.categoryViewConfig.iconColorSelected,
        indicatorColor: config.categoryViewConfig.indicatorColor,
        unselectedLabelColor: config.categoryViewConfig.iconColor,
        dividerColor: config.categoryViewConfig.dividerColor,
        controller: tabController,
        labelPadding: EdgeInsets.zero,
        onTap: (index) {
          closeSkinToneOverlay();
          pageController.jumpToPage(index);
        },
        tabs: categoryEmojis
            .asMap()
            .entries
            .map<Widget>(
              (item) => _buildCategoryTab(item.key, item.value.category),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCategoryTab(int index, Category category) {
    return Tab(
      icon: Icon(
        getIconForCategory(config.categoryViewConfig.categoryIcons, category),
      ),
    );
  }
}
