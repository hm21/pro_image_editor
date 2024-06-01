// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

// Project imports:
import 'package:pro_image_editor/modules/emoji_editor/widgets/emoji_editor_bottom_bar.dart';

class EmojiEditorCategoryView extends CategoryView {
  const EmojiEditorCategoryView(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  WhatsAppCategoryViewState createState() => WhatsAppCategoryViewState();
}

class WhatsAppCategoryViewState extends State<EmojiEditorCategoryView>
    with SkinToneOverlayStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: EmojiEditorBottomBar(
              widget.config,
              widget.tabController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
            ),
          ),
          _buildBackspaceButton(),
        ],
      ),
    );
  }

  Widget _buildBackspaceButton() {
    if (widget.config.categoryViewConfig.showBackspaceButton) {
      return BackspaceButton(
        widget.config,
        widget.state.onBackspacePressed,
        widget.state.onBackspaceLongPressed,
        widget.config.categoryViewConfig.backspaceColor,
      );
    }
    return const SizedBox.shrink();
  }
}
