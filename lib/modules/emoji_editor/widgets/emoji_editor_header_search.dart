import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/i18n/i18n.dart';
import 'package:pro_image_editor/models/theme/theme_shared_values.dart';

/// Search view header for the emoji editor, allowing search input and emoji
/// display.
class EmojiEditorHeaderSearchView extends SearchView {
  /// Constructor for creating an instance of EmojiEditorHeaderSearchView.
  const EmojiEditorHeaderSearchView(
    super.config,
    super.state,
    super.showEmojiView, {
    super.key,
    required this.i18n,
  });

  /// Localization and internationalization settings.
  final I18n i18n;

  /// Creates the state for HeaderSearchViewState.
  @override
  // ignore: no_logic_in_create_state
  HeaderSearchViewState createState() => HeaderSearchViewState(i18n);
}

/// State class for EmojiEditorHeaderSearchView, extending SearchViewState.
class HeaderSearchViewState extends SearchViewState {
  /// Constructor for creating the state with internationalization settings.
  HeaderSearchViewState(this.i18n);

  /// Localization and internationalization settings.
  final I18n i18n;

  /// Builds the widget tree for the header search view.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final emojiSize =
          widget.config.emojiViewConfig.getEmojiSize(constraints.maxWidth);
      final emojiBoxSize =
          widget.config.emojiViewConfig.getEmojiBoxSize(constraints.maxWidth);
      return Container(
        color: widget.config.searchViewConfig.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: emojiBoxSize + 8.0,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return buildEmoji(
                    results[index],
                    emojiSize,
                    emojiBoxSize,
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.showEmojiView,
                  color: widget.config.searchViewConfig.buttonIconColor,
                  icon: Icon(
                    Icons.arrow_back,
                    color: widget.config.searchViewConfig.buttonIconColor,
                    size: 20.0,
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: onTextInputChanged,
                    focusNode: focusNode,
                    style: const TextStyle(
                      color: imageEditorTextColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: i18n.emojiEditor.search,
                      hintStyle: const TextStyle(
                        color: imageEditorTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
