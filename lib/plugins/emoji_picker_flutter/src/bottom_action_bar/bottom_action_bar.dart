import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Template class for custom implementation
abstract class BottomActionBar extends StatefulWidget {
  /// Constructor
  const BottomActionBar(
    this.config,
    this.state,
    this.showSearchView, {
    super.key,
  });

  /// Config for customizations
  final Config config;

  /// State that holds current emoji data
  final EmojiViewState state;

  /// Show Search Bar
  final VoidCallback showSearchView;
}
