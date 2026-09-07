import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Default Search implementation
class DefaultSearchView extends SearchView {
  /// Constructor
  const DefaultSearchView(
    super.config,
    super.state,
    super.showEmojiView, {
    super.key,
  });

  @override
  DefaultSearchViewState createState() => DefaultSearchViewState();
}

/// Default Search View State
class DefaultSearchViewState extends SearchViewState {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.emojiViewConfig.getEmojiSize(
          constraints.maxWidth,
        );
        final emojiBoxSize = widget.config.emojiViewConfig.getEmojiBoxSize(
          constraints.maxWidth,
        );

        return Container(
          color: widget.config.searchViewConfig.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: SizedBox(
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
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.showEmojiView,
                    color: widget.config.searchViewConfig.buttonIconColor,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: onTextInputChanged,
                      focusNode: focusNode,
                      style: widget.config.searchViewConfig.inputTextStyle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.config.searchViewConfig.hintText,
                        hintStyle: widget.config.searchViewConfig.hintTextStyle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
