import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// A widget that represents an individual clickable emoji cell.
/// Can have a long pressed listener [onSkinToneDialogRequested] that
/// provides necessary data to show a skin tone popup.
class EmojiCell extends StatelessWidget {
  /// Constructor for manually setting all properties
  const EmojiCell({
    super.key,
    required this.emoji,
    required this.emojiSize,
    required this.emojiBoxSize,
    this.categoryEmoji,
    required this.buttonMode,
    required this.enableSkinTones,
    required this.textStyle,
    required this.skinToneIndicatorColor,
    this.onSkinToneDialogRequested,
    required this.onEmojiSelected,
  });

  /// Constructor that can retrieve as much information as possible from
  /// [Config]
  EmojiCell.fromConfig(
      {super.key,
      required this.emoji,
      required this.emojiSize,
      required this.emojiBoxSize,
      this.categoryEmoji,
      required this.onEmojiSelected,
      this.onSkinToneDialogRequested,
      required Config config})
      : buttonMode = config.emojiViewConfig.buttonMode,
        enableSkinTones = config.skinToneConfig.enabled,
        textStyle = config.emojiTextStyle,
        skinToneIndicatorColor = config.skinToneConfig.indicatorColor;

  /// Emoji to display as the cell content
  final Emoji emoji;

  /// Font size for the emoji
  final double emojiSize;

  /// Hitbox of emoji cell
  final double emojiBoxSize;

  /// Optinonal category that will be passed through to callbacks
  final CategoryEmoji? categoryEmoji;

  /// Visual tap feedback, see [ButtonMode] for options
  final ButtonMode buttonMode;

  /// Whether to show skin popup indicator if emoji supports skin colors
  final bool enableSkinTones;

  /// Custom text style to use on emoji
  final TextStyle? textStyle;

  /// Color for skin color indicator triangle
  final Color skinToneIndicatorColor;

  /// Callback triggered on long press. Will be called regardless
  /// whether [enableSkinTones] is set or not and for any emoji to
  /// give a way for the caller to dismiss any existing overlays.
  final OnSkinToneDialogRequested? onSkinToneDialogRequested;

  /// Callback for a single tap on the cell.
  final OnEmojiSelected onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    onPressed() {
      onEmojiSelected(categoryEmoji?.category, emoji);
    }

    onLongPressed() {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
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
        child: _buildEmoji(),
      ),
    );
  }

  /// Build different Button based on ButtonMode
  Widget _buildButtonWidget({
    required VoidCallback onPressed,
    VoidCallback? onLongPressed,
    required Widget child,
  }) {
    if (buttonMode == ButtonMode.MATERIAL) {
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
    }
    if (buttonMode == ButtonMode.CUPERTINO) {
      return GestureDetector(
        onLongPress: onLongPressed,
        child: CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          child: child,
        ),
      );
    }
    return GestureDetector(
      onLongPress: onLongPressed,
      onTap: onPressed,
      child: Center(child: child),
    );
  }

  /// Build and display Emoji centered of its parent
  Widget _buildEmoji() {
    final emojiText = Text(
      emoji.emoji,
      textScaler: const TextScaler.linear(1.0),
      style: _getEmojiTextStyle(),
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

  TextStyle _getEmojiTextStyle() {
    final defaultStyle = DefaultEmojiTextStyle.copyWith(
      fontSize: emojiSize,
      inherit: true,
    );
    // textStyle properties have priority over defaultStyle
    return textStyle == null ? defaultStyle : defaultStyle.merge(textStyle);
  }
}
