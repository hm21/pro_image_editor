// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'rounded_background_text.dart';

/// A wrapper around [RoundedBackgroundText] and [TextField]
class RoundedBackgroundTextField extends StatefulWidget {
  const RoundedBackgroundTextField({
    super.key,
    this.controller,
    this.style,
    this.backgroundColor,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textScaler,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines,
    this.cursorWidth = 2.0,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.keyboardType,
    this.hint,
    this.hintStyle,
    this.innerRadius = kDefaultInnerRadius,
    this.outerRadius = kDefaultOuterRadius,
    this.autofocus = false,
    this.focusNode,
    this.keyboardAppearance = Brightness.light,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.autocorrect = true,
    this.autofillClient,
    this.autofillHints,
    this.clipBehavior = Clip.hardEdge,
    this.enableIMEPersonalizedLearning = true,
    this.enableSuggestions = true,
    this.forceLine = true,
    this.textHeightBehavior,
    this.textWidthBasis = TextWidthBasis.parent,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.strutStyle,
    this.inputFormatters,
    this.mouseCursor,
    this.obscureText = false,
    this.obscuringCharacter = '*',
    this.readOnly = false,
    this.rendererIgnoresPointer = false,
    this.restorationId,
    this.showCursor = true,
    this.showSelectionHandles = true,
    this.smartDashesType = SmartDashesType.enabled,
    this.smartQuotesType = SmartQuotesType.enabled,
    this.textInputAction,
    this.onSelectionChanged,
    this.scrollController,
    this.scrollPhysics,
    this.scrollBehavior,
    this.scrollPadding = EdgeInsets.zero,
    this.dragStartBehavior = DragStartBehavior.start,
    this.contentInsertionConfiguration,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration = const TextMagnifierConfiguration(),
    this.undoController,
    this.scribbleEnabled = true,
    this.locale,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.onSelectionHandleTapped,
    this.onTapOutside,
    this.heroTag,
  });

  final String? heroTag;

  final TextEditingController? controller;

  /// The final text style
  ///
  /// The font size will be reduced if there isn't enough space for the text
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// {@macro rounded_background_text.background_color}
  final Color? backgroundColor;

  final int? maxLines;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  ///
  /// If this is null it will default to the ambient
  /// [TextSelectionThemeData.cursorColor]. If that is null, and the
  /// [ThemeData.platform] is [TargetPlatform.iOS] or [TargetPlatform.macOS]
  /// it will use [CupertinoThemeData.primaryColor]. Otherwise it will use
  /// the value of [ColorScheme.primary] of [ThemeData.colorScheme].
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType? keyboardType;

  /// The type of action button to use with the soft keyboard.
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.onAppPrivateCommand}
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// {@macro flutter.widgets.editableText.onSelectionChanged}
  final SelectionChangedCallback? onSelectionChanged;

  /// {@macro flutter.widgets.SelectionOverlay.onSelectionHandleTapped}
  final VoidCallback? onSelectionHandleTapped;

  /// {@macro flutter.widgets.editableText.onTapOutside}
  final TapRegionCallback? onTapOutside;

  /// The text hint
  final String? hint;

  /// The text style for [hint]
  final TextStyle? hintStyle;

  /// {@macro rounded_background_text.innerRadius}
  final double innerRadius;

  /// {@macro rounded_background_text.outerRadius}
  final double outerRadius;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// Whether the text will take the full width regardless of the text width.
  ///
  /// When this is set to false, the width will be based on text width, which
  /// will also be affected by [textWidthBasis].
  ///
  /// Defaults to true. Must not be null.
  ///
  /// See also:
  ///
  ///  * [textWidthBasis], which controls the calculation of text width.
  final bool forceLine;

  /// {@macro dart.ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// Whether to show selection handles.
  ///
  /// When a selection is active, there will be two handles at each side of
  /// boundary, or one handle if the selection is collapsed. The handles can be
  /// dragged to adjust the selection.
  ///
  /// See also:
  ///
  ///  * [showCursor], which controls the visibility of the cursor.
  final bool showSelectionHandles;

  /// {@macro flutter.widgets.editableText.showCursor}
  ///
  /// See also:
  ///
  ///  * [showSelectionHandles], which controls the visibility of the selection
  /// handles.
  final bool showCursor;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// The [AutofillClient] that controls this input field's autofill behavior.
  ///
  /// When null, this widget's [EditableTextState] will be used as the
  /// [AutofillClient]. This property may override [autofillHints].
  final AutofillClient? autofillClient;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// Restoration ID to save and restore the scroll offset of the
  /// [EditableText].
  ///
  /// If a restoration id is provided, the [EditableText] will persist its
  /// current scroll offset and restore it during state restoration.
  ///
  /// The scroll offset is persisted in a [RestorationBucket] claimed from
  /// the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// Persisting and restoring the content of the [EditableText] is the
  /// responsibility of the owner of the [controller], who may use a
  /// [RestorableTextEditingController] for that purpose.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// {
  /// @macro flutter.services.TextInputConfiguration.
  /// enableIMEPersonalizedLearning
  /// }
  final bool enableIMEPersonalizedLearning;

  final List<TextInputFormatter>? inputFormatters;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If this property is null, [SystemMouseCursors.text] will be used.
  ///
  /// The [mouseCursor] is the only property of [EditableText] that controls the
  /// appearance of the mouse pointer. All other properties related to "cursor"
  /// stands for the text cursor, which is usually a blinking vertical line at
  /// the editing position.
  final MouseCursor? mouseCursor;

  /// If true, the [RenderEditable] created by this widget will not handle
  /// pointer events, see [RenderEditable] and [RenderEditable.ignorePointer].
  ///
  /// This property is false by default.
  final bool rendererIgnoresPointer;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.shadow.scrollBehavior}
  ///
  /// [ScrollBehavior]s also provide [ScrollPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [scrollPhysics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [ScrollBehavior].
  ///
  /// The [ScrollBehavior] of the inherited [ScrollConfiguration] will be
  /// modified by default to only apply a [Scrollbar] if [maxLines] is greater
  /// than 1.
  final ScrollBehavior? scrollBehavior;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.contentInsertionConfiguration}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, no context menu will be shown.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// {@macro flutter.widgets.EditableText.spellCheckConfiguration}
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// {@macro flutter.widgets.magnifier.TextMagnifierConfiguration.intro}
  ///
  /// {@macro flutter.widgets.magnifier.intro}
  ///
  /// {@macro flutter.widgets.magnifier.TextMagnifierConfiguration.details}
  final TextMagnifierConfiguration magnifierConfiguration;

  /// Controls the undo state of the current editable text.
  final UndoHistoryController? undoController;

  /// {macro flutter.widgets.editableText.scribbleEnabled}
  final bool scribbleEnabled;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with
  /// `Localizations.localeOf(context)`.
  ///
  /// See [RenderEditable.locale] for more information.
  final Locale? locale;

  @override
  State<RoundedBackgroundTextField> createState() =>
      _RoundedBackgroundTextFieldState();
}

class _RoundedBackgroundTextFieldState
    extends State<RoundedBackgroundTextField> {
  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  final fieldKey = GlobalKey<EditableTextState>();

  late TextEditingController textController =
      widget.controller ?? TextEditingController();
  late ScrollController scrollController =
      widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    textController.addListener(_handleTextChange);
    scrollController.addListener(_handleScrollChange);
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  void _handleScrollChange() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant RoundedBackgroundTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      scrollController = widget.scrollController ?? scrollController;
    }

    if (widget.controller != oldWidget.controller) {
      textController = widget.controller ?? textController;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      textController.dispose();
    } else {
      textController.removeListener(_handleTextChange);
    }

    if (widget.scrollController == null) {
      scrollController.dispose();
    } else {
      widget.scrollController!.removeListener(_handleScrollChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextSelectionThemeData selectionTheme =
        TextSelectionTheme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context);

    final fontSize =
        (widget.style?.fontSize ?? defaultTextStyle.style.fontSize ?? 16);

    TextSelectionControls? textSelectionControls = widget.selectionControls;
    final bool paintCursorAboveText;
    final bool cursorOpacityAnimates;
    Offset? cursorOffset;
    Color? cursorColor = widget.cursorColor;
    final Color selectionColor;
    Color? autocorrectionTextRectColor;
    Radius? cursorRadius = widget.cursorRadius;

    switch (theme.platform) {
      case TargetPlatform.iOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls ??= cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??=
            selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        autocorrectionTextRectColor = selectionColor;
        break;

      case TargetPlatform.macOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls ??= cupertinoDesktopTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??=
            selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        textSelectionControls ??= materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withOpacity(0.40);
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        textSelectionControls ??= desktopTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withOpacity(0.40);
        break;
    }

    const padding = EdgeInsets.all(6.0);

    final style = (widget.style ?? const TextStyle()).copyWith(
      // The text is rendered by the [EditableText] widget below.
      // It has more accuracy for a bunch of text features
      color: Colors.transparent,
      leadingDistribution: TextLeadingDistribution.proportional,
    );
    return Stack(
      clipBehavior: Clip.none,
      alignment: switch (widget.textAlign) {
        TextAlign.end => AlignmentDirectional.centerEnd,
        TextAlign.start => AlignmentDirectional.centerStart,
        TextAlign.left => Alignment.centerLeft,
        TextAlign.right => Alignment.centerRight,
        TextAlign.center || _ => Alignment.topCenter,
      },
      children: [
        if (textController.text.isNotEmpty)
          Positioned(
            top: scrollController.hasClients
                ? -scrollController.position.pixels
                : null,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.only(
                  right: 2.0,
                  left: 1.0,
                  bottom: 3.0,
                ),
                margin: padding,
                child: RoundedBackgroundText.rich(
                  text: textController.buildTextSpan(
                    context: context,
                    withComposing: !widget.readOnly,
                    style: style,
                  ),
                  textAlign: widget.textAlign,
                  backgroundColor: widget.backgroundColor,
                  innerRadius: widget.innerRadius,
                  outerRadius: widget.outerRadius,
                  textDirection: widget.textDirection,
                  textScaler: widget.textScaler ?? TextScaler.noScaling,
                  locale: widget.locale,
                  textHeightBehavior: widget.textHeightBehavior,
                  textWidthBasis: widget.textWidthBasis,
                  strutStyle: widget.strutStyle,
                ),
              ),
            ),
          )
        else if (widget.hint != null)
          Positioned(
            child: Padding(
              padding: padding,
              child: Text(
                widget.hint!,
                style: (widget.hintStyle ?? TextStyle(color: theme.hintColor))
                    .copyWith(
                  fontSize: fontSize,
                  // height: calculateHeight(fontSize),
                ),
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                locale: widget.locale,
                strutStyle: widget.strutStyle,
              ),
            ),
          ),
        Positioned(
          child: Padding(
            padding: padding,
            child: EditableText(
              key: fieldKey,
              autofocus: widget.autofocus,
              controller: textController,
              focusNode: _effectiveFocusNode,
              scrollPhysics: widget.scrollPhysics,
              scrollBehavior: widget.scrollBehavior,
              scrollController: scrollController,
              scrollPadding: widget.scrollPadding,
              style: (widget.style ?? const TextStyle()).copyWith(
                fontSize: fontSize,
                leadingDistribution: TextLeadingDistribution.proportional,
              ),
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              backgroundCursorColor: CupertinoColors.inactiveGray,
              cursorColor: widget.cursorColor ??
                  selectionTheme.cursorColor ??
                  widget.style?.color ??
                  foregroundColor(widget.backgroundColor) ??
                  Colors.black,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              paintCursorAboveText: paintCursorAboveText,
              cursorOpacityAnimates: cursorOpacityAnimates,
              cursorOffset: cursorOffset,
              autocorrectionTextRectColor: autocorrectionTextRectColor,
              textCapitalization: widget.textCapitalization,
              keyboardAppearance: widget.keyboardAppearance,
              textScaler: widget.textScaler,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              selectionColor: selectionColor,
              selectionControls:
                  widget.selectionEnabled ? textSelectionControls : null,
              textDirection: widget.textDirection,
              showSelectionHandles: widget.showSelectionHandles,
              showCursor: widget.showCursor,
              textWidthBasis: widget.textWidthBasis,
              textHeightBehavior: widget.textHeightBehavior,
              autocorrect: widget.autocorrect,
              forceLine: widget.forceLine,
              readOnly: widget.readOnly,
              smartDashesType: widget.smartDashesType,
              smartQuotesType: widget.smartQuotesType,
              enableSuggestions: widget.enableSuggestions,
              autofillHints: widget.autofillHints,
              autofillClient: widget.autofillClient,
              clipBehavior: widget.clipBehavior,
              restorationId: widget.restorationId,
              enableIMEPersonalizedLearning:
                  widget.enableIMEPersonalizedLearning,
              inputFormatters: widget.inputFormatters,
              mouseCursor: widget.mouseCursor,
              rendererIgnoresPointer: widget.rendererIgnoresPointer,
              obscureText: widget.obscureText,
              obscuringCharacter: widget.obscuringCharacter,
              textInputAction: widget.textInputAction,
              onSelectionChanged: widget.onSelectionChanged,
              dragStartBehavior: widget.dragStartBehavior,
              contentInsertionConfiguration:
                  widget.contentInsertionConfiguration,
              contextMenuBuilder: widget.contextMenuBuilder,
              spellCheckConfiguration: widget.spellCheckConfiguration,
              magnifierConfiguration: widget.magnifierConfiguration,
              undoController: widget.undoController,
              scribbleEnabled: widget.scribbleEnabled,
              selectionHeightStyle: widget.selectionHeightStyle,
              selectionWidthStyle: widget.selectionWidthStyle,
              locale: widget.locale,
              onChanged: widget.onChanged,
              onEditingComplete: widget.onEditingComplete,
              onSubmitted: widget.onSubmitted,
              onAppPrivateCommand: widget.onAppPrivateCommand,
              onSelectionHandleTapped: widget.onSelectionHandleTapped,
              onTapOutside: widget.onTapOutside,
              strutStyle: widget.strutStyle,
            ),
          ),
        ),
      ],
    );
  }
}
