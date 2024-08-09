import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Manages the state of the emoji picker, including the active category.
class EmojiStateManager extends InheritedWidget {
  /// Constructor for EmojiStateManager, accepting a key, child widget,
  /// active category, and a function to update the active category.
  const EmojiStateManager({
    super.key,
    required super.child,
    required this.activeCategory,
    required this.setActiveCategory,
  });

  /// The currently active emoji category.
  final Category activeCategory;

  /// Function to update the active emoji category.
  final Function(Category) setActiveCategory;

  /// Retrieves the closest [EmojiStateManager] instance in the widget tree.
  static EmojiStateManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EmojiStateManager>();
  }

  /// Determines if the widget should notify listeners about changes.
  @override
  bool updateShouldNotify(EmojiStateManager oldWidget) {
    return oldWidget.activeCategory != activeCategory;
  }
}
