import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Full-screen search view for emoji editor, allowing emoji search and
/// selection.
class EmojiEditorFullScreenSearchView extends StatefulWidget {
  /// Constructor for creating an instance of EmojiEditorFullScreenSearchView.
  const EmojiEditorFullScreenSearchView({
    super.key,
    required this.config,
    required this.state,
  });

  /// Configuration for customizations of the emoji picker.
  final Config config;

  /// State that holds current emoji data.
  final EmojiViewState state;

  /// Creates the state for EmojiEditorFullScreenSearchView.
  @override
  EmojiEditorFullScreenSearchViewState createState() =>
      EmojiEditorFullScreenSearchViewState();
}

/// State class for EmojiEditorFullScreenSearchView, implementing
/// SkinToneOverlayStateMixin.
class EmojiEditorFullScreenSearchViewState
    extends State<EmojiEditorFullScreenSearchView>
    with SkinToneOverlayStateMixin {
  /// Search results stored as a list of Emoji objects.
  final results = List<Emoji>.empty(growable: true);

  /// Utility class for emoji picker operations.
  final utils = EmojiPickerUtils();

  /// Initiates a search for emojis based on input text.
  void search(String text) {
    onTextInputChanged(text);
  }

  /// Callback function triggered when text input changes.
  void onTextInputChanged(String text) {
    links.clear();
    results.clear();
    utils.searchEmoji(text, widget.state.categoryEmoji).then(
          (value) => setState(
            () => _updateResults(value),
          ),
        );
  }

  /// Updates the search results with the found emojis.
  void _updateResults(List<Emoji> emojis) {
    results
      ..clear()
      ..addAll(emojis);
    results.asMap().entries.forEach((e) {
      links[e.value.emoji] = LayerLink();
    });
  }

  /// Builds the widget tree for the full-screen search view.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final emojiSize =
          widget.config.emojiViewConfig.getEmojiSize(constraints.maxWidth);
      final emojiBoxSize =
          widget.config.emojiViewConfig.getEmojiBoxSize(constraints.maxWidth);
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: widget.config.emojiViewConfig.columns,
          mainAxisSpacing: widget.config.emojiViewConfig.verticalSpacing,
          crossAxisSpacing: widget.config.emojiViewConfig.horizontalSpacing,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return buildEmoji(
            results[index],
            emojiSize,
            emojiBoxSize,
          );
        },
      );
    });
  }

  /// Builds an emoji cell widget.
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

  /// Callback function when a skin-toned emoji is selected.
  void _onSkinTonedEmojiSelected(Category? category, Emoji emoji) {
    widget.state.onEmojiSelected(category, emoji);
    closeSkinToneOverlay();
  }
}
