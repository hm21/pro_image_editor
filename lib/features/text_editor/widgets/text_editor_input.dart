import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/text_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import 'rounded_background_text/rounded_background_text_field.dart';

/// A widget for managing the text input in the text editor, providing a
/// customizable input area with styling and configuration options.
class TextEditorInput extends StatefulWidget {
  /// Creates a `TextEditorInput` widget with the required configurations,
  /// callbacks, and styling for text input management.
  ///
  /// - [callbacks]: Optional callbacks for text editor interactions.
  /// - [configs]: Configuration settings for the text editor.
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [heroTag]: Optional tag for hero animations during transitions.
  /// - [selectedTextStyle]: The text style applied to the input text.
  /// - [align]: The alignment of the text in the input field.
  /// - [textFontSize]: The font size of the input text.
  /// - [textColor]: The color of the input text.
  /// - [backgroundColor]: The background color of the text input field.
  /// - [layer]: The text layer being edited, if applicable.
  /// - [focusNode]: The focus node for managing input focus.
  /// - [textCtrl]: The text editing controller for managing input content.
  const TextEditorInput({
    super.key,
    required this.callbacks,
    required this.configs,
    required this.heroTag,
    required this.focusNode,
    required this.i18n,
    required this.selectedTextStyle,
    required this.align,
    required this.textFontSize,
    required this.scaleFactor,
    required this.textColor,
    required this.backgroundColor,
    required this.layer,
    required this.textCtrl,
    required this.maxWidth,
    required this.cursorWidth,
  });

  /// Optional callbacks for text editor interactions.
  final TextEditorCallbacks? callbacks;

  /// Configuration settings for the text editor.
  final TextEditorConfigs configs;

  /// Localization strings for tooltips and labels.
  final I18nTextEditor i18n;

  /// Optional tag for hero animations during transitions.
  final String? heroTag;

  /// The text style applied to the input text.
  final TextStyle selectedTextStyle;

  /// The alignment of the text in the input field.
  final TextAlign align;

  /// The font size of the input text.
  final double textFontSize;

  /// The width of the text cursor in the text editor input, measured in
  /// logical pixels.
  final double cursorWidth;

  /// The maximum width available for the text before the text will overflow.
  final double maxWidth;

  /// The scale factor to transform the textfield
  final double scaleFactor;

  /// The color of the input text.
  final Color textColor;

  /// The background color of the text input field.
  final Color backgroundColor;

  /// The text layer being edited, if applicable.
  final TextLayer? layer;

  /// The focus node for managing input focus.
  final FocusNode focusNode;

  /// The text editing controller for managing input content.
  final TextEditingController textCtrl;

  @override
  State<TextEditorInput> createState() => _TextEditorInputState();
}

class _TextEditorInputState extends State<TextEditorInput> {
  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;

    final isOpening = flightDirection == HeroFlightDirection.push;

    if (isOpening) {
      void animationStatusListener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.focusNode.requestFocus();
          });
          animation.removeStatusListener(animationStatusListener);
        }
      }

      animation.addStatusListener(animationStatusListener);
    }

    final shuttleChild =
        InheritedTheme.captureAll(fromHeroContext, toHero.child);

    return isOpening
        ? SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.maxWidth),
                child: shuttleChild,
              ),
            ),
          )
        : shuttleChild;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.configs.inputTextFieldAlign,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: widget.configs.style.textFieldMargin,
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: widget.configs.enableAutoOverflow
                ? null
                : const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: _buildInputField(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Transform.scale(
      scale: widget.scaleFactor,
      child: Hero(
        flightShuttleBuilder: _flightShuttleBuilder,
        tag: widget.heroTag ?? 'Text-Image-Editor-Empty-Hero',
        child: Container(
          padding: widget.configs.style.inputTextFieldPadding,
          decoration: BoxDecoration(
            color: widget.configs.style.inputTextFieldBackground,
            border: Border.all(
              color: widget.configs.style.inputTextFieldBorderColor,
              width: 1,
            ),
            borderRadius: widget.configs.style.inputTextFieldBorderRadius,
          ),
          child: RoundedBackgroundTextField(
            key: const ValueKey('rounded-background-text-editor-field'),
            maxTextWidth: widget.maxWidth,
            controller: widget.textCtrl,
            focusNode: widget.focusNode,
            onChanged: (value) {
              widget.callbacks?.handleChanged(value);
              setState(() {});
            },
            onEditingComplete: widget.callbacks?.handleEditingComplete,
            onSubmitted: widget.callbacks?.handleSubmitted,
            textAlign:
                widget.textCtrl.text.isEmpty ? TextAlign.center : widget.align,
            configs: widget.configs,
            cursorHeight: widget.textFontSize,
            cursorWidth: widget.cursorWidth,
            hint: widget.i18n.inputHintText,
            hintStyle: widget.selectedTextStyle.copyWith(
              color: widget.configs.style.inputHintColor,
              fontSize: widget.textFontSize,
              shadows: [],
            ),
            backgroundColor: widget.backgroundColor,
            style: widget.selectedTextStyle.copyWith(
              color: widget.textColor,
              fontSize: widget.textFontSize,
              letterSpacing: 0,
              decoration: TextDecoration.none,
              shadows: [],
            ),

            /// If we edit an layer we focus to the textfield after the
            /// hero animation is done
            autofocus: widget.layer == null,
          ),
        ),
      ),
    );
  }
}
