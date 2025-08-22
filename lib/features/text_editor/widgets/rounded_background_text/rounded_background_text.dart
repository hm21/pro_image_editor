import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/rounded_background_painter.dart';

/// Creates a [RoundedBackgroundText] widget with plain text and optional
/// styling.
///
/// The [text] parameter is a simple `String` which will be wrapped in a
/// [TextSpan].
class RoundedBackgroundText extends StatelessWidget {
  /// Creates a [RoundedBackgroundText] widget from a plain [String] with
  /// optional styling.
  ///
  /// This constructor converts the [text] into a [TextSpan] using the
  /// provided [style].
  ///
  /// Use this constructor when you don't need rich text formatting.
  RoundedBackgroundText(
    String text, {
    super.key,
    TextStyle? style,
    this.textAlign,
    this.backgroundColor,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
  }) : text = TextSpan(text: text, style: style);

  /// Creates a [RoundedBackgroundText] widget with rich text using
  /// [InlineSpan].
  ///
  /// Use this constructor when you want to provide styled or nested spans via
  /// the [text] parameter.
  const RoundedBackgroundText.rich({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textAlign,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
  });

  /// A flag to enable or disable hitBox correction for the text.
  final bool enableHitBoxCorrection;

  /// The text content to be displayed, supporting rich formatting through
  /// [InlineSpan].
  final InlineSpan text;

  /// How the text should be aligned horizontally within its container.
  final TextAlign? textAlign;

  /// The optional background color behind the text.
  final Color? backgroundColor;

  /// The maximum width the text is allowed to occupy. If null, the text can
  /// expand freely.
  final double maxTextWidth;

  /// The width of the text cursor when displayed.
  final double cursorWidth;

  /// Callback function triggered with the result of a hit test.
  final Function(bool hasHit)? onHitTestResult;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;
    final align = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;

    final painter = TextPainter(
      text: TextSpan(
        children: [text],
        style: const TextStyle(
          leadingDistribution: TextLeadingDistribution.proportional,
        ).merge(style),
      ),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      maxLines: defaultTextStyle.maxLines,
      textAlign: align,
      textWidthBasis: defaultTextStyle.textWidthBasis,
      textHeightBehavior: defaultTextStyle.textHeightBehavior,
    );
    double height = painter.preferredLineHeight;

    double horizontalSpace = enableHitBoxCorrection ? height * 0.3 : 0;
    double verticalSpace = enableHitBoxCorrection ? height * 0.1 : 0;

    return LayoutBuilder(builder: (context, constraints) {
      painter.layout(maxWidth: maxTextWidth);

      return CustomPaint(
        isComplex: true,
        painter: RoundedBackgroundTextPainter(
          backgroundColor: backgroundColor ?? Colors.transparent,
          painter: painter,
          onHitTestResult: onHitTestResult,
          textAlign: align,
          cursorWidth: cursorWidth,
          textDirection: Directionality.of(context),
          hitBoxCorrectionOffset: Offset(horizontalSpace, verticalSpace),
        ),
        size: Size(
          painter.width.clamp(0, constraints.maxWidth) + horizontalSpace * 2,
          painter.height.clamp(0, constraints.maxHeight) + verticalSpace * 2,
        ),
      );
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<InlineSpan>('text', text))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null))
      ..add(
          ColorProperty('backgroundColor', backgroundColor, defaultValue: null))
      ..add(DoubleProperty('maxTextWidth', maxTextWidth))
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 0))
      ..add(FlagProperty(
        'enableHitBoxCorrection',
        value: enableHitBoxCorrection,
        ifTrue: 'hitBoxCorrection enabled',
      ))
      ..add(FlagProperty(
        'hasOnHitTestResult',
        value: onHitTestResult != null,
        ifTrue: 'callback set',
      ));
  }
}
