import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiEditorFullScreenSearchView extends StatefulWidget {
  /// Config for customizations
  final Config config;

  /// State that holds current emoji data
  final EmojiViewState state;

  const EmojiEditorFullScreenSearchView({
    super.key,
    required this.config,
    required this.state,
  });

  @override
  EmojiEditorFullScreenSearchViewState createState() =>
      EmojiEditorFullScreenSearchViewState();
}

class EmojiEditorFullScreenSearchViewState
    extends State<EmojiEditorFullScreenSearchView>
    with SkinToneOverlayStateMixin {
  /// Search results
  final results = List<Emoji>.empty(growable: true);

  /// Emoji picker utils
  final utils = EmojiPickerUtils();

  /// Search emojis
  void search(String text) {
    onTextInputChanged(text);
  }

  /// On text input changed callback
  void onTextInputChanged(String text) {
    links.clear();
    results.clear();
    utils.searchEmoji(text, widget.state.categoryEmoji).then(
          (value) => setState(
            () => _updateResults(value),
          ),
        );
  }

  void _updateResults(List<Emoji> emojis) {
    results
      ..clear()
      ..addAll(emojis);
    results.asMap().entries.forEach((e) {
      links[e.value.emoji] = LayerLink();
    });
  }

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
}
