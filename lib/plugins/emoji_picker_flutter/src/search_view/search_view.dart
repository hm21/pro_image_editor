import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Template class for custom implementation
/// Inhert this class to create your own search view
abstract class SearchView extends StatefulWidget {
  /// Constructor
  const SearchView(this.config, this.state, this.showEmojiView, {super.key});

  /// Config for customizations
  final Config config;

  /// State that holds current emoji data
  final EmojiViewState state;

  /// Return to emoji view
  final VoidCallback showEmojiView;
}

/// Template class for custom implementation
/// Inhert this class to create your own search view state
class SearchViewState<T extends SearchView> extends State<T>
    with SkinToneOverlayStateMixin {
  /// Emoji picker utils
  final utils = EmojiPickerUtils();

  /// Focus node for textfield
  final focusNode = FocusNode();

  /// Search results
  final results = List<Emoji>.empty(growable: true);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto focus textfield
      FocusScope.of(context).requestFocus(focusNode);
      // Load recent emojis initially
      utils.getRecentEmojis().then(
        (value) =>
            setState(() => _updateResults(value.map((e) => e.emoji).toList())),
      );
    });
    super.initState();
  }

  /// On text input changed callback
  void onTextInputChanged(String text) {
    links.clear();
    results.clear();
    utils
        .searchEmoji(text, widget.state.categoryEmoji)
        .then((value) => setState(() => _updateResults(value)));
  }

  void _updateResults(List<Emoji> emojis) {
    results
      ..clear()
      ..addAll(emojis);
    results.asMap().entries.forEach((e) {
      links[e.value.emoji] = LayerLink();
    });
  }

  /// Build emoji cell
  Widget buildEmoji(Emoji emoji, double emojiSize, double emojiBoxSize) {
    return addSkinToneTargetIfAvailable(
      hasSkinTone: emoji.hasSkinTone,
      linkKey: emoji.emoji,
      child: EmojiCell.fromConfig(
        emoji: emoji,
        emojiSize: emojiSize,
        emojiBoxSize: emojiBoxSize,
        onEmojiSelected: widget.state.onEmojiSelected,
        config: widget.config,
        onSkinToneDialogRequested:
            (emojiBoxPosition, emoji, emojiSize, category) {
              closeSkinToneOverlay();
              if (!emoji.hasSkinTone || !widget.config.skinToneConfig.enabled) {
                return;
              }
              showSkinToneOverlay(
                emojiBoxPosition,
                emoji,
                emojiSize,
                null, // Todo: check if we can provide the category
                widget.config,
                _onSkinTonedEmojiSelected,
                links[emoji.emoji]!,
              );
            },
      ),
    );
  }

  void _onSkinTonedEmojiSelected(Category? category, Emoji emoji) {
    widget.state.onEmojiSelected(category, emoji);
    closeSkinToneOverlay();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('Search View implementation missing');
  }
}
