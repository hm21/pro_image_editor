import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

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
    this.maxWidth = double.infinity,
    this.softMaxWidth = double.infinity,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
    this.outlineWidth = 0,
    this.outlineColor = const Color(0xFF000000),
    this.reserveEffectSpace = false,
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
    this.maxWidth = double.infinity,
    this.softMaxWidth = double.infinity,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
    this.outlineWidth = 0,
    this.outlineColor = const Color(0xFF000000),
    this.reserveEffectSpace = false,
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

  /// The widest this widget may lay out, including the space it reserves
  /// around the text for the hit box correction and the effects.
  ///
  /// Lines wrap so the widget never grows wider, which keeps the background,
  /// outline and shadows inside this width too, and a word wider than this
  /// is broken. [maxTextWidth] still applies when it is narrower. Defaults to
  /// [double.infinity], which sets no limit.
  final double maxWidth;

  /// The widest this widget should lay out, measured like [maxWidth], as
  /// long as that keeps its words whole.
  ///
  /// Lines wrap between words to stay within this width, but the widget
  /// never gets narrower than its longest word for it; only [maxWidth]
  /// breaks a word. Defaults to [double.infinity], which sets no limit.
  final double softMaxWidth;

  /// The width of the text cursor when displayed.
  final double cursorWidth;

  /// Controls how extra leading is distributed above and below the text.
  ///
  /// Defaults to [TextLeadingDistribution.proportional].
  /// Set to [TextLeadingDistribution.even] to visually centre glyphs inside
  /// their rounded background rects when [TextStyle.height] > 1.0.
  final TextLeadingDistribution leadingDistribution;

  /// Callback function triggered with the result of a hit test.
  final Function(bool hasHit)? onHitTestResult;

  /// The thickness of the outline drawn around each glyph, measured outward
  /// from the glyph edge. `0` draws no outline.
  ///
  /// While an outline is drawn, the shadows of the text style are cast by
  /// the outlined glyphs rather than the bare ones.
  final double outlineWidth;

  /// The color of the outline.
  final Color outlineColor;

  /// Whether the widget grows by the space its outline and shadows paint
  /// beyond the glyphs, so a capture of its bounds does not cut them off.
  ///
  /// The space is added on both sides, so the text keeps its center.
  final bool reserveEffectSpace;

  bool get _hasOutline => outlineWidth > 0 && outlineColor.a > 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layout(context, constraints);
        return CustomPaint(
          isComplex: true,
          painter: layout.painter,
          size: layout.size,
        );
      },
    );
  }

  /// Paints this text into an image the way it paints on screen when laid
  /// out at [size], at [pixelRatio] device pixels per logical pixel.
  ///
  /// [context] supplies the inherited text style and direction, exactly as it
  /// does in [build], so it must be a context the widget could be built in.
  /// The result matches what `RenderRepaintBoundary.toImage` reads from a
  /// boundary directly around this widget, without the widget having to be
  /// on screen in that state.
  Future<ui.Image> toImage(
    BuildContext context, {
    required Size size,
    required double pixelRatio,
  }) async {
    final painter = _layout(context, BoxConstraints.loose(size)).painter;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      );
    } finally {
      picture.dispose();
      painter.painter.dispose();
      painter.outlinePainter?.dispose();
      for (final silhouette in painter.silhouettePainters) {
        silhouette.dispose();
      }
    }
  }

  /// Lays the text out within [constraints] and returns the painter that
  /// draws it together with the size it paints at.
  ({RoundedBackgroundTextPainter painter, Size size}) _layout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;
    final align = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final rootStyle = TextStyle(
      leadingDistribution: leadingDistribution,
    ).merge(style);
    final shadows = style.shadows ?? const <Shadow>[];
    final hasOutline = _hasOutline;

    TextPainter createPainter(TextStyle Function(TextStyle style)? restyle) {
      return TextPainter(
        text: TextSpan(
          children: [restyle == null ? text : _restyleSpan(text, restyle)],
          style: restyle == null ? rootStyle : restyle(rootStyle),
        ),
        textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
        maxLines: defaultTextStyle.maxLines,
        textAlign: align,
        textWidthBasis: defaultTextStyle.textWidthBasis,
        textHeightBehavior: defaultTextStyle.textHeightBehavior,
      );
    }

    TextStyle Function(TextStyle style) paintWith(Paint paint) {
      return (style) => style.copyWith(
        foreground: paint,
        shadows: const [],
        decoration: TextDecoration.none,
      );
    }

    Paint strokePaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      // Half of the stroke lies inside the glyph, under the fill.
      ..strokeWidth = outlineWidth * 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    // With an outline, the shadows are cast by the outlined glyphs, which the
    // painter draws from opaque silhouettes; the passes themselves draw none.
    final painter = createPainter(
      hasOutline ? (style) => style.copyWith(shadows: const []) : null,
    );
    final outlinePainter = hasOutline
        ? createPainter(paintWith(strokePaint(outlineColor)))
        : null;
    final hasOutlineShadows = hasOutline && shadows.isNotEmpty;
    final silhouettePainters = hasOutlineShadows
        ? [
            createPainter(paintWith(strokePaint(const Color(0xFF000000)))),
            createPainter(paintWith(Paint()..color = const Color(0xFF000000))),
          ]
        : const <TextPainter>[];

    double height = painter.preferredLineHeight;

    double horizontalSpace = enableHitBoxCorrection ? height * 0.3 : 0;
    double verticalSpace = enableHitBoxCorrection ? height * 0.1 : 0;

    final effectSpace = reserveEffectSpace
        ? _effectSpace(
            outlineWidth: hasOutline ? outlineWidth : 0,
            shadows: shadows,
          )
        : Offset.zero;

    final reservedWidth = (horizontalSpace + effectSpace.dx) * 2;
    var textMaxWidth = min(maxTextWidth, max(0.0, maxWidth - reservedWidth));
    final textSoftMaxWidth = max(0.0, softMaxWidth - reservedWidth);
    if (textSoftMaxWidth < textMaxWidth) {
      // The longest word only reads after a layout; rounding up keeps it on
      // one line when the text is laid out at exactly that width.
      painter.layout();
      final longestWord = painter.minIntrinsicWidth.ceilToDouble();
      textMaxWidth = min(textMaxWidth, max(textSoftMaxWidth, longestWord));
    }
    painter.layout(maxWidth: textMaxWidth);
    outlinePainter?.layout(maxWidth: textMaxWidth);
    for (final silhouette in silhouettePainters) {
      silhouette.layout(maxWidth: textMaxWidth);
    }

    return (
      painter: RoundedBackgroundTextPainter(
        backgroundColor: backgroundColor ?? Colors.transparent,
        painter: painter,
        outlinePainter: outlinePainter,
        outlineWidth: hasOutline ? outlineWidth : 0,
        outlineColor: outlineColor,
        silhouettePainters: silhouettePainters,
        silhouetteShadows: hasOutlineShadows ? shadows : const [],
        onHitTestResult: onHitTestResult,
        textAlign: align,
        cursorWidth: cursorWidth,
        textDirection: Directionality.of(context),
        hitBoxCorrectionOffset:
            Offset(horizontalSpace, verticalSpace) + effectSpace,
      ),
      size: Size(
        painter.width.clamp(0, constraints.maxWidth) +
            (horizontalSpace + effectSpace.dx) * 2,
        painter.height.clamp(0, constraints.maxHeight) +
            (verticalSpace + effectSpace.dy) * 2,
      ),
    );
  }

  /// How far the outline and the shadows paint beyond the glyphs on each
  /// axis.
  static Offset _effectSpace({
    required double outlineWidth,
    required List<Shadow> shadows,
  }) {
    double dx = outlineWidth;
    double dy = outlineWidth;
    for (final shadow in shadows) {
      // A gaussian blur fades out within three sigma.
      final blur = shadow.blurRadius > 0
          ? Shadow.convertRadiusToSigma(shadow.blurRadius) * 3
          : 0.0;
      dx = max(dx, outlineWidth + shadow.offset.dx.abs() + blur);
      dy = max(dy, outlineWidth + shadow.offset.dy.abs() + blur);
    }
    return Offset(dx.ceilToDouble(), dy.ceilToDouble());
  }

  /// A copy of [span] whose own styles, where set, are passed through
  /// [restyle], so a paint applied to the root reaches spans that set their
  /// own color.
  static InlineSpan _restyleSpan(
    InlineSpan span,
    TextStyle Function(TextStyle style) restyle,
  ) {
    if (span is! TextSpan) return span;
    return TextSpan(
      text: span.text,
      style: span.style == null ? null : restyle(span.style!),
      children: span.children
          ?.map((child) => _restyleSpan(child, restyle))
          .toList(),
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      semanticsIdentifier: span.semanticsIdentifier,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<InlineSpan>('text', text))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null))
      ..add(
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(DoubleProperty('maxTextWidth', maxTextWidth))
      ..add(DoubleProperty('maxWidth', maxWidth, defaultValue: double.infinity))
      ..add(
        DoubleProperty(
          'softMaxWidth',
          softMaxWidth,
          defaultValue: double.infinity,
        ),
      )
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 0))
      ..add(
        FlagProperty(
          'enableHitBoxCorrection',
          value: enableHitBoxCorrection,
          ifTrue: 'hitBoxCorrection enabled',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnHitTestResult',
          value: onHitTestResult != null,
          ifTrue: 'callback set',
        ),
      )
      ..add(
        EnumProperty<TextLeadingDistribution>(
          'leadingDistribution',
          leadingDistribution,
          defaultValue: TextLeadingDistribution.proportional,
        ),
      )
      ..add(DoubleProperty('outlineWidth', outlineWidth, defaultValue: 0))
      ..add(ColorProperty('outlineColor', outlineColor))
      ..add(
        FlagProperty(
          'reserveEffectSpace',
          value: reserveEffectSpace,
          ifTrue: 'effect space reserved',
        ),
      );
  }
}
