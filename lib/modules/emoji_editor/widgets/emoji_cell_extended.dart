import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A widget that represents an individual clickable emoji cell.
/// Can have a long pressed listener [onSkinToneDialogRequested] that
/// provides necessary data to show a skin tone popup.
class EmojiCellExtended extends StatelessWidget {
  /// Constructor that can retrieve as much information as possible from
  /// [Config]
  const EmojiCellExtended({
    super.key,
    this.categoryEmoji,
    this.onSkinToneDialogRequested,
    required this.emoji,
    required this.emojiSize,
    required this.emojiBoxSize,
    required this.onEmojiSelected,
    required this.emojiStyle,
    required this.buttonMode,
    required this.enableSkinTones,
    required this.skinToneIndicatorColor,
  });

  /// Emoji to display as the cell content
  final Emoji emoji;

  /// Font size for the emoji
  final double emojiSize;

  /// HitBox of emoji cell
  final double emojiBoxSize;

  /// Optional category that will be passed through to callbacks
  final CategoryEmoji? categoryEmoji;

  /// Visual tap feedback, see [ButtonMode] for options
  final ButtonMode buttonMode;

  /// Whether to show skin popup indicator if emoji supports skin colors
  final bool enableSkinTones;

  /// Color for skin color indicator triangle
  final Color skinToneIndicatorColor;

  /// Callback triggered on long press. Will be called regardless
  /// whether [enableSkinTones] is set or not and for any emoji to
  /// give a way for the caller to dismiss any existing overlays.
  final OnSkinToneDialogRequested? onSkinToneDialogRequested;

  /// Callback for a single tap on the cell.
  final OnEmojiSelected onEmojiSelected;

  /// The style from the emoji
  final TextStyle emojiStyle;

  @override
  Widget build(BuildContext context) {
    onPressed() {
      onEmojiSelected(categoryEmoji?.category, emoji);
    }

    onLongPressed() {
      final renderBox = context.findRenderObject() as RenderBox;
      final emojiBoxPosition = renderBox.localToGlobal(Offset.zero);
      onSkinToneDialogRequested?.call(
        emojiBoxPosition,
        emoji,
        emojiSize,
        categoryEmoji,
      );
    }

    return SizedBox(
      width: emojiBoxSize,
      height: emojiBoxSize,
      child: _buildButtonWidget(
        onPressed: onPressed,
        onLongPressed: onLongPressed,
      ),
    );
  }

  /// Build different Button based on ButtonMode
  Widget _buildButtonWidget({
    required VoidCallback onPressed,
    VoidCallback? onLongPressed,
  }) {
    Widget child = _buildEmoji();

    switch (buttonMode) {
      case ButtonMode.MATERIAL:
        return MaterialButton(
          onPressed: onPressed,
          onLongPress: onLongPressed,
          elevation: 0,
          highlightElevation: 0,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: child,
        );
      case ButtonMode.CUPERTINO:
        return GestureDetector(
          onLongPress: onLongPressed,
          child: CupertinoButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: child,
          ),
        );
      default:
        return GestureDetector(
          onLongPress: onLongPressed,
          onTap: onPressed,
          child: Center(child: child),
        );
    }
  }

  /// Build and display Emoji centered of its parent
  Widget _buildEmoji() {
    final Widget emojiText = Text(
      emoji.emoji,
      textScaler: const TextScaler.linear(1.0),
      style: emojiStyle,
    );

    return emoji.hasSkinTone &&
            enableSkinTones &&
            onSkinToneDialogRequested != null
        ? Container(
            decoration: TriangleDecoration(
              color: skinToneIndicatorColor,
              size: 8.0,
            ),
            child: emojiText,
          )
        : emojiText;
  }
}
