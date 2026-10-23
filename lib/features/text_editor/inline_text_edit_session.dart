import 'dart:async';

import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/text_editor_configs.dart';
import '/core/models/layers/enums/layer_background_mode.dart';
import '/core/models/layers/text_layer.dart';
import '/core/models/layers/text_layer_box.dart';

/// One in-progress edit of a text layer on the canvas.
///
/// Created by [ProImageEditorState.beginInlineTextEdit] when
/// [TextEditorConfigs.enableInlineEditing] is on. The layer keeps its place;
/// this session holds the text and the style until [done] or [cancel].
class InlineTextEditSession {
  InlineTextEditSession._({
    required this.layerId,
    required this.configs,
    required String text,
    required this.originalText,
    required this.align,
    required this.selectedTextStyle,
    required this.backgroundColorMode,
    required this.fontScale,
    required this.outlineWidth,
    required this.outlineColor,
    required this.boxEnabled,
    required this._primaryColor,
    required this._secondaryColor,
    required this.onChanged,
    required this.onTextChanged,
    required this.onDone,
    required this.onCancel,
  }) {
    textCtrl.text = text;
    _lastText = text;
    textCtrl.addListener(_handleText);
  }

  /// Starts a session from [layer] as it is now.
  factory InlineTextEditSession.start({
    required TextLayer layer,
    required TextEditorConfigs configs,
    required VoidCallback onChanged,
    required VoidCallback onTextChanged,
    required VoidCallback onDone,
    required VoidCallback onCancel,
  }) {
    final mode = layer.colorMode;
    // Same color rules as the full-screen editor: a layer without its own
    // secondary color keeps the config's, which is null unless one was set.
    var primary = configs.initialPrimaryColor;
    Color? secondary = configs.initialSecondaryColor;
    if (layer.customSecondaryColor) {
      primary = layer.color;
      secondary = layer.background;
    } else {
      primary = mode == LayerBackgroundMode.background
          ? layer.background
          : layer.color;
    }
    return InlineTextEditSession._(
      layerId: layer.id,
      configs: configs,
      text: layer.text,
      originalText: layer.text,
      align: layer.align,
      selectedTextStyle:
          layer.textStyle ??
          configs.customTextStyles?.first ??
          configs.defaultTextStyle,
      backgroundColorMode: mode,
      fontScale: layer.fontScale,
      outlineWidth: layer.outlineWidth,
      outlineColor: layer.outlineColor,
      boxEnabled: layer.box != null,
      primaryColor: primary,
      secondaryColor: secondary,
      onChanged: onChanged,
      onTextChanged: onTextChanged,
      onDone: onDone,
      onCancel: onCancel,
    );
  }

  /// The layer this session edits.
  final String layerId;

  /// The text editor settings the field follows.
  final TextEditorConfigs configs;

  /// The text the layer had when the session started.
  final String originalText;

  /// The text being typed.
  final TextEditingController textCtrl = TextEditingController();

  /// Focus for the layer's field.
  final FocusNode focusNode = FocusNode();

  /// Rebuilds the editor after a style change.
  final VoidCallback onChanged;

  /// Rebuilds the editor when the typed text changes the fitted box.
  final VoidCallback onTextChanged;

  /// Writes the edit.
  final VoidCallback onDone;

  /// Drops the edit.
  final VoidCallback onCancel;

  final Completer<bool> _completed = Completer<bool>();

  /// Completes with `true` when the edit was written onto the layer, and
  /// `false` when it was dropped.
  Future<bool> get completed => _completed.future;

  /// Whether [done] or [cancel] has already run.
  bool get closed => _closed;
  bool _closed = false;

  /// Set for the pointer-down that hit the field, so a drag selects text
  /// instead of moving the layer.
  bool pointerOnText = false;

  /// Set for the pointer-down that hit the layer, including its padding, so
  /// the click does not count as tapping off the edit.
  bool pointerOnLayer = false;

  /// Set while a pointer that went down on a format bar wrapped in
  /// [InlineTextEditChrome] is pressed.
  bool pointerOnChrome = false;

  /// Alignment of the text.
  TextAlign align;

  /// Style applied to the text, apart from its color and size.
  TextStyle selectedTextStyle;

  /// How the text and its background share their colors.
  LayerBackgroundMode backgroundColorMode;

  /// Size of the text relative to [TextEditorConfigs.initFontSize].
  double fontScale;

  /// Outline thickness at a font scale of 1.
  double outlineWidth;

  /// Color of the outline.
  Color outlineColor;

  /// Whether the text keeps a [TextLayerBox].
  bool boxEnabled;

  Color _primaryColor;
  Color? _secondaryColor;

  /// The color the fill and the background are chosen from, as in the
  /// full-screen editor.
  Color get primaryColor => _primaryColor;

  /// Replaces [primaryColor]. A background without its own color follows.
  void setPrimaryColor(Color color) {
    if (_closed || color == _primaryColor) return;
    _primaryColor = color;
    onChanged();
  }

  /// The color the glyphs are drawn in.
  Color get textColor {
    switch (backgroundColorMode) {
      case LayerBackgroundMode.onlyColor:
      case LayerBackgroundMode.backgroundAndColor:
        return _primaryColor;
      case LayerBackgroundMode.background:
        return _secondary;
      case LayerBackgroundMode.backgroundAndColorWithOpacity:
        return _primaryColor;
    }
  }

  /// The color behind the text.
  Color get backgroundColor {
    switch (backgroundColorMode) {
      case LayerBackgroundMode.onlyColor:
        return const Color(0x00000000);
      case LayerBackgroundMode.backgroundAndColor:
        return _secondary;
      case LayerBackgroundMode.background:
        return _primaryColor;
      case LayerBackgroundMode.backgroundAndColorWithOpacity:
        return _secondary.withValues(alpha: 0.5);
    }
  }

  Color get _secondary {
    final color = _secondaryColor;
    if (color != null) return color;
    final light = _primaryColor.computeLuminance() > 0.5;
    final channel = light ? 0 : 255;
    return Color.fromRGBO(channel, channel, channel, _primaryColor.a);
  }

  String _lastText = '';

  void _handleText() {
    // The controller also notifies when only the selection moves.
    if (_closed || textCtrl.text == _lastText) return;
    _lastText = textCtrl.text;
    onTextChanged();
  }

  /// Cycles left, center, and right.
  void toggleTextAlign() {
    align = switch (align) {
      TextAlign.left => TextAlign.center,
      TextAlign.center => TextAlign.right,
      _ => TextAlign.left,
    };
    onChanged();
  }

  /// Cycles the background mode.
  void toggleBackgroundMode() {
    backgroundColorMode = switch (backgroundColorMode) {
      LayerBackgroundMode.onlyColor => LayerBackgroundMode.backgroundAndColor,
      LayerBackgroundMode.backgroundAndColor => LayerBackgroundMode.background,
      LayerBackgroundMode.background =>
        LayerBackgroundMode.backgroundAndColorWithOpacity,
      LayerBackgroundMode.backgroundAndColorWithOpacity =>
        LayerBackgroundMode.onlyColor,
    };
    onChanged();
  }

  /// Replaces the text style, keeping the session's color and size.
  void setTextStyle(TextStyle style) {
    selectedTextStyle = style;
    onChanged();
  }

  /// Puts the text in a box, or takes it out of one.
  ///
  /// A layer that already has a box keeps that box, including a resize made
  /// during the edit. Otherwise the box is fitted to the text and stored when
  /// the edit is saved.
  void setBoxEnabled(bool enabled) {
    boxEnabled = enabled;
    onChanged();
  }

  /// The box the field lays out in, in the layer's units, or `null` when the
  /// text sizes itself.
  ///
  /// A layer that already has a box keeps it, including a resize made during
  /// the session. Otherwise the box is fitted to the text typed so far.
  TextLayerBox? editingBox(TextLayer live) {
    if (!boxEnabled) return null;
    final existing = live.box;
    if (existing != null) return existing;
    final fontSize = configs.initFontSize * fontScale;
    return TextLayerBox.fit(
      text: textCtrl.text.isEmpty ? ' ' : textCtrl.text,
      style: selectedTextStyle.copyWith(
        fontSize: fontSize,
        shadows: _scaledShadows(selectedTextStyle.shadows, fontScale),
      ),
      maxTextWidth: live.maxTextWidth,
      align: align,
      outlineWidth: outlineWidth * fontScale,
      slack: 2 / (live.scale <= 0 ? 1 : live.scale),
    );
  }

  /// The layer [done] writes, before the editor restores its placement.
  TextLayer buildResult(TextLayer live) {
    final text = textCtrl.text.trim();
    return TextLayer(
      text: text,
      background: backgroundColor,
      color: textColor,
      align: align,
      fontScale: fontScale,
      colorMode: backgroundColorMode,
      textStyle: selectedTextStyle,
      outlineWidth: outlineWidth,
      outlineColor: outlineColor,
      customSecondaryColor: _secondaryColor != null,
      maxTextWidth: live.maxTextWidth,
      startTime: live.startTime,
      endTime: live.endTime,
      enterDuration: live.enterDuration,
      exitDuration: live.exitDuration,
      enterCurve: live.enterCurve,
      exitCurve: live.exitCurve,
      transitionBuilder: live.transitionBuilder,
      animations: live.animations,
      keyframes: live.keyframes,
      opacity: live.opacity,
      mask: live.mask,
      blendMode: live.blendMode,
      box: editingBox(live),
      highlights: originalText == text ? live.highlights : null,
      highlightColor: live.highlightColor,
    );
  }

  /// Whether [buildResult] for [live] differs from [live] in anything this
  /// session sets, so saving it is worth a history step.
  bool hasChanges(TextLayer live) {
    final result = buildResult(live);
    final liveStyle =
        live.textStyle ??
        configs.customTextStyles?.first ??
        configs.defaultTextStyle;
    return result.text != live.text ||
        result.color != live.color ||
        result.background != live.background ||
        result.align != live.align ||
        result.fontScale != live.fontScale ||
        result.colorMode != live.colorMode ||
        result.textStyle != liveStyle ||
        result.outlineWidth != live.outlineWidth ||
        result.outlineColor != live.outlineColor ||
        result.customSecondaryColor != live.customSecondaryColor ||
        result.box != live.box;
  }

  /// Writes the edit onto the layer.
  void done() {
    if (_closed) return;
    onDone();
  }

  /// Drops the edit and leaves the layer as it was.
  void cancel() {
    if (_closed) return;
    onCancel();
  }

  /// Marks the session finished. The editor calls this; a host uses [done]
  /// or [cancel].
  void finish(bool saved) {
    _closed = true;
    if (!_completed.isCompleted) _completed.complete(saved);
  }

  /// Releases the field.
  void dispose() {
    textCtrl
      ..removeListener(_handleText)
      ..dispose();
    focusNode.dispose();
  }
}

List<Shadow>? _scaledShadows(List<Shadow>? shadows, double factor) {
  if (shadows == null) return null;
  return [
    for (final shadow in shadows)
      Shadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * factor,
        offset: shadow.offset * factor,
      ),
  ];
}

/// Marks a format bar so a click on it does not save and close the inline
/// text edit underneath it.
class InlineTextEditChrome extends StatelessWidget {
  /// Creates a region whose clicks belong to [session].
  const InlineTextEditChrome({
    super.key,
    required this.session,
    required this.child,
  });

  /// The edit the clicks belong to.
  final InlineTextEditSession session;

  /// The format controls.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A bar outside the editor never reaches the editor's own pointer
    // handling, so the flag is cleared here once the pointer is released.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => session.pointerOnChrome = true,
      onPointerUp: (_) => session.pointerOnChrome = false,
      onPointerCancel: (_) => session.pointerOnChrome = false,
      child: child,
    );
  }
}
