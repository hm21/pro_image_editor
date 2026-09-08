import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Template class for custom implementation
/// Inhert this class to create your own Category view
abstract class CategoryView extends StatefulWidget {
  /// Constructor
  const CategoryView(
    this.config,
    this.state,
    this.tabController,
    this.pageController, {
    super.key,
  });

  /// Config for customizations
  final Config config;

  /// State that holds current emoji data
  final EmojiViewState state;

  /// TabController for Category view
  final TabController tabController;

  /// Page Controller of Emoji view
  final PageController pageController;
}

/// Returns the icon for the category
IconData getIconForCategory(CategoryIcons categoryIcons, Category category) {
  switch (category) {
    case Category.RECENT:
      return categoryIcons.recentIcon;
    case Category.SMILEYS:
      return categoryIcons.smileyIcon;
    case Category.ANIMALS:
      return categoryIcons.animalIcon;
    case Category.FOODS:
      return categoryIcons.foodIcon;
    case Category.TRAVEL:
      return categoryIcons.travelIcon;
    case Category.ACTIVITIES:
      return categoryIcons.activityIcon;
    case Category.OBJECTS:
      return categoryIcons.objectIcon;
    case Category.SYMBOLS:
      return categoryIcons.symbolIcon;
    case Category.FLAGS:
      return categoryIcons.flagIcon;
  }
}

/// Template class for custom implementation
/// Inhert this class to create your own category view state
class CategoryViewState<T extends CategoryView> extends State<T>
    with SkinToneOverlayStateMixin {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('Category View implementation missing');
  }
}
