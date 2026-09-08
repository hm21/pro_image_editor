import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';
import '../services/emoji_state_manager.dart';

/// Represents the bottom bar for the emoji editor.
class EmojiEditorBottomBar extends StatelessWidget {
  /// A bottom bar widget for the emoji editor interface.
  const EmojiEditorBottomBar(
    this.config,
    this.tabController,
    this.closeSkinToneOverlay,
    this.categoryEmojis, {
    super.key,
  });

  /// The configuration for the emoji editor.
  final Config config;

  /// The tab controller for navigating between emoji categories.
  final TabController tabController;

  /// Callback function for closing the skin tone overlay.
  final VoidCallback closeSkinToneOverlay;

  /// List of the category emojis
  final List<CategoryEmoji> categoryEmojis;

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
        labelPadding: const EdgeInsets.only(top: 1.0),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        onTap: (index) {
          closeSkinToneOverlay();
          EmojiStateManager.of(
            context,
          )?.setActiveCategory(categoryEmojis[index].category);
        },
        tabs: categoryEmojis
            .asMap()
            .entries
            .map<Widget>(
              (item) => _buildCategory(item.key, item.value.category),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCategory(int index, Category category) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          getIconForCategory(config.categoryViewConfig.categoryIcons, category),
          size: 20,
        ),
      ),
    );
  }
}
