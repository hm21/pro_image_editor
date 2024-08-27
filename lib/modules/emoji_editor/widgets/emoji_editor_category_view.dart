import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/modules/emoji_editor/widgets/emoji_editor_bottom_bar.dart';

/// Custom category view for the emoji editor with WhatsApp-like styling.
class EmojiEditorCategoryView extends CategoryView {
  /// Constructor for creating an instance of EmojiEditorCategoryView.
  const EmojiEditorCategoryView(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  /// Creates the state for WhatsAppCategoryViewState.
  @override
  WhatsAppCategoryViewState createState() => WhatsAppCategoryViewState();
}

/// State class for the EmojiEditorCategoryView, implementing the
/// SkinToneOverlayStateMixin.
class WhatsAppCategoryViewState extends State<EmojiEditorCategoryView>
    with SkinToneOverlayStateMixin {
  /// Builds the widget tree for the category view.
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

  /// Builds the backspace button based on configuration settings.
  Widget _buildBackspaceButton() {
    if (widget.config.categoryViewConfig.extraTab ==
        CategoryExtraTab.BACKSPACE) {
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
