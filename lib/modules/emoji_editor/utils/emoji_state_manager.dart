// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiStateManager extends InheritedWidget {
  final Category activeCategory;
  final Function(Category) setActiveCategory;

  const EmojiStateManager({
    super.key,
    required super.child,
    required this.activeCategory,
    required this.setActiveCategory,
  });

  static EmojiStateManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EmojiStateManager>();
  }

  @override
  bool updateShouldNotify(EmojiStateManager oldWidget) {
    return oldWidget.activeCategory != activeCategory;
  }
}
