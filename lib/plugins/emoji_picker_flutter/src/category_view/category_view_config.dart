import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Callback function for custom category view
typedef CategoryViewBuilder =
    Widget Function(
      Config config,
      EmojiViewState state,
      TabController tabController,
      PageController pageController,
    );

/// Category view Config
class CategoryViewConfig {
  /// Constructor
  const CategoryViewConfig({
    this.tabBarHeight = 46.0,
    this.tabIndicatorAnimDuration = kTabScrollDuration,
    this.initCategory = Category.RECENT,
    this.recentTabBehavior = RecentTabBehavior.RECENT,
    this.extraTab = CategoryExtraTab.NONE,
    this.backgroundColor = const Color(0xFFEBEFF2),
    this.indicatorColor = Colors.blue,
    this.iconColor = Colors.grey,
    this.iconColorSelected = Colors.blue,
    this.backspaceColor = Colors.blue,
    this.dividerColor,
    this.categoryIcons = const CategoryIcons(),
    this.customCategoryView,
  });

  /// Tab bar height
  final double tabBarHeight;

  /// Duration of tab indicator to animate to next category
  final Duration tabIndicatorAnimDuration;

  /// The initial [Category] that will be selected
  /// This [Category] will have its button in the bottombar darkened
  final Category initCategory;

  /// Behavior of Recent Tab (Recent, Popular)
  final RecentTabBehavior recentTabBehavior;

  /// Extra tab button in category tab bar
  final CategoryExtraTab? extraTab;

  /// Background color of TabBar
  final Color backgroundColor;

  /// The color of the category indicator
  final Color indicatorColor;

  /// The color of the category icons
  final Color iconColor;

  /// The color of the category icon when selected
  final Color iconColorSelected;

  /// The color of the backspace icon button
  final Color backspaceColor;

  /// Divider color between TabBar and emoji's, use Colors.transparent to remove
  final Color? dividerColor;

  /// Determines the icon to display for each [Category]
  final CategoryIcons categoryIcons;

  /// Custom search bar
  /// Hot reload is not supported
  final CategoryViewBuilder? customCategoryView;

  @override
  bool operator ==(other) {
    return (other is CategoryViewConfig) &&
        other.tabBarHeight == tabBarHeight &&
        other.tabIndicatorAnimDuration == tabIndicatorAnimDuration &&
        other.initCategory == initCategory &&
        other.recentTabBehavior == recentTabBehavior &&
        other.extraTab == extraTab &&
        other.backgroundColor == backgroundColor &&
        other.indicatorColor == indicatorColor &&
        other.iconColor == iconColor &&
        other.iconColorSelected == iconColorSelected &&
        other.backspaceColor == backspaceColor &&
        other.dividerColor == dividerColor &&
        other.categoryIcons == categoryIcons;
  }

  @override
  int get hashCode =>
      tabBarHeight.hashCode ^
      tabIndicatorAnimDuration.hashCode ^
      initCategory.hashCode ^
      recentTabBehavior.hashCode ^
      extraTab.hashCode ^
      backgroundColor.hashCode ^
      indicatorColor.hashCode ^
      iconColor.hashCode ^
      iconColorSelected.hashCode ^
      backspaceColor.hashCode ^
      dividerColor.hashCode ^
      categoryIcons.hashCode;
}
