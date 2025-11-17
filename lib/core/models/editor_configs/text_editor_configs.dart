// ignore_for_file: deprecated_member_use_from_same_package
// TODO: Remove the deprecated values when releasing version 12.0.0.

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../custom_widgets/text_editor_widgets.dart';
import '../icons/text_editor_icons.dart';
import '../layers/enums/layer_background_mode.dart';
import '../styles/text_editor_style.dart';
import 'utils/base_editor_layer_configs.dart';
import 'utils/base_sub_editor_configs.dart';
import 'utils/editor_safe_area.dart';

export '../custom_widgets/text_editor_widgets.dart';
export '../icons/text_editor_icons.dart';
export '../styles/text_editor_style.dart';

/// Configuration options for a text editor.
///
/// `TextEditorConfigs` allows you to define settings for a text editor,
/// including whether the editor is enabled, which text formatting options
/// are available, and the initial font size.
///
/// Example usage:
/// ```dart
/// TextEditorConfigs(
///   enabled: true,
///   canToggleTextAlign: true,
///   canToggleBackgroundMode: true,
///   initFontSize: 24.0,
/// );
/// ```
class TextEditorConfigs
    implements BaseEditorLayerConfigs, BaseSubEditorConfigs {
  /// Creates an instance of TextEditorConfigs with optional settings.
  ///
  /// By default, the text editor is enabled, and most text formatting options
  /// are enabled. The initial font size is set to 24.0.
  const TextEditorConfigs(
      {this.layerFractionalOffset = const Offset(-0.5, -0.5),
      this.enableGesturePop = true,
      this.enableSuggestions = true,
      @Deprecated(
        'Use tools inside MainEditorConfigs instead, e.g. tools: '
        '[SubEditorMode.text]',
      )
      this.enabled = true,
      this.enableEdit = true,
      this.enableAutocorrect = true,
      this.showSelectFontStyleBottomBar = false,
      this.showTextAlignButton = true,
      this.showFontScaleButton = true,
      this.showBackgroundModeButton = true,
      this.enableMainEditorZoomFactor = false,
      this.enableTapOutsideToSave = true,
      this.enableAutoOverflow = true,
      this.initFontSize = 24.0,
      this.initialPrimaryColor = const Color(0xFF000000),
      this.initialSecondaryColor,
      this.initialTextAlign = TextAlign.center,
      this.inputTextFieldAlign = Alignment.center,
      this.initFontScale = 1.0,
      this.maxFontScale = 3.0,
      this.minFontScale = 0.3,
      this.minScale = double.negativeInfinity,
      this.maxScale = double.infinity,
      this.customTextStyles,
      this.defaultTextStyle = const TextStyle(),
      this.initialBackgroundColorMode = LayerBackgroundMode.backgroundAndColor,
      this.safeArea = const EditorSafeArea(),
      this.style = const TextEditorStyle(),
      this.icons = const TextEditorIcons(),
      this.widgets = const TextEditorWidgets(),
      this.enableImageBoundaryTextWrap = false})
      : assert(initFontSize > 0, 'initFontSize must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');

  /// {@macro layerFractionalOffset}
  @override
  final Offset layerFractionalOffset;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Indicates whether the text editor is enabled.
  @Deprecated(
    'Use tools inside MainEditorConfigs instead, e.g. tools: '
    '[SubEditorMode.text]',
  )
  final bool enabled;

  /// Indicating whether created layers can be edited.
  final bool enableEdit;

  /// Whether to show the toggle button to change the text align.
  final bool showTextAlignButton;

  /// Whether to show the button to change the font scale.
  final bool showFontScaleButton;

  /// Whether to show the toggle button to change the background mode.
  final bool showBackgroundModeButton;

  /// Determines if the editor show a bottom bar where the user can select
  /// different font styles.
  final bool showSelectFontStyleBottomBar;

  /// A flag to enable or disable scaling of the text field in sync with the
  /// editor's zoom level.
  final bool enableMainEditorZoomFactor;

  /// Whether tapping outside the text field saves the text annotation.
  ///
  /// When `true` (default), tapping outside the text input area will save
  /// the current text and close the editor. When `false`, tapping outside
  /// will not trigger the save action, requiring users to use the done
  /// button or other explicit save actions.
  final bool enableTapOutsideToSave;

  /// The initial font size for text.
  final double initFontSize;

  /// The initial text alignment for the layer.
  final TextAlign initialTextAlign;

  /// The alignment of the input text field within the editor.
  ///
  /// Determines how the text field is positioned relative to its parent widget.
  /// For example, [Alignment.center] will center the text field, while
  /// [Alignment.topLeft] will align it to the top-left corner.
  final Alignment inputTextFieldAlign;

  /// The initial font scale for text.
  final double initFontScale;

  /// The max font font scale for text.
  final double maxFontScale;

  /// The min font font scale for text.
  final double minFontScale;

  /// The initial primary color which is mostly the font color.
  final Color initialPrimaryColor;

  /// The initial secondary color which is mostly the background color.
  final Color? initialSecondaryColor;

  /// The initial background color mode for the layer.
  final LayerBackgroundMode initialBackgroundColorMode;

  /// Allow users to select a different font style
  final List<TextStyle>? customTextStyles;

  /// The default text style to be used in the text editor.
  ///
  /// This style will be applied to the text if no other style is specified.
  final TextStyle defaultTextStyle;

  /// Whether the text should automatically wrap when it reaches the end of
  /// the screen.
  ///
  /// If set to `true`, the text will wrap to the next line instead of
  /// overflowing, ensuring it stays within the visible area
  /// (e.g., the screen width).
  final bool enableAutoOverflow;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Whether to show input suggestions as the user types.
  ///
  /// This flag only affects Android. On iOS, suggestions are tied directly to
  /// [enableAutocorrect], so that suggestions are only shown when
  /// [enableAutocorrect] is `true`. On Android autocorrection and suggestion
  /// are controlled separately.
  ///
  /// Defaults to true.
  final bool enableSuggestions;

  /// Whether to enable autocorrection.
  ///
  /// **Default** `true`.
  final bool enableAutocorrect;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Style configuration for the text editor.
  final TextEditorStyle style;

  /// Icons used in the text editor.
  final TextEditorIcons icons;

  /// Widgets associated with the text editor.
  final TextEditorWidgets widgets;

  /// Enable automatic text wrapping when text reach the image boundaries
  final bool enableImageBoundaryTextWrap;

  /// Creates a copy of this `TextEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TextEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  TextEditorConfigs copyWith({
    Offset? layerFractionalOffset,
    bool? enableGesturePop,
    bool? enabled,
    bool? enableEdit,
    bool? showSelectFontStyleBottomBar,
    bool? enableMainEditorZoomFactor,
    bool? enableTapOutsideToSave,
    bool? enableAutoOverflow,
    Color? initialPrimaryColor,
    Color? initialSecondaryColor,
    double? initFontSize,
    TextAlign? initialTextAlign,
    Alignment? inputTextFieldAlign,
    double? initFontScale,
    double? maxFontScale,
    double? minFontScale,
    LayerBackgroundMode? initialBackgroundColorMode,
    List<TextStyle>? customTextStyles,
    TextStyle? defaultTextStyle,
    double? minScale,
    double? maxScale,
    bool? enableSuggestions,
    bool? enableAutocorrect,
    EditorSafeArea? safeArea,
    TextEditorStyle? style,
    TextEditorIcons? icons,
    TextEditorWidgets? widgets,
    bool? enableImageBoundaryTextWrap,
  }) {
    return TextEditorConfigs(
      layerFractionalOffset:
          layerFractionalOffset ?? this.layerFractionalOffset,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      safeArea: safeArea ?? this.safeArea,
      enabled: enabled ?? this.enabled,
      enableEdit: enableEdit ?? this.enableEdit,
      showSelectFontStyleBottomBar:
          showSelectFontStyleBottomBar ?? this.showSelectFontStyleBottomBar,
      enableMainEditorZoomFactor:
          enableMainEditorZoomFactor ?? this.enableMainEditorZoomFactor,
      enableTapOutsideToSave:
          enableTapOutsideToSave ?? this.enableTapOutsideToSave,
      enableAutoOverflow: enableAutoOverflow ?? this.enableAutoOverflow,
      initialPrimaryColor: initialPrimaryColor ?? this.initialPrimaryColor,
      initialSecondaryColor:
          initialSecondaryColor ?? this.initialSecondaryColor,
      initFontSize: initFontSize ?? this.initFontSize,
      initialTextAlign: initialTextAlign ?? this.initialTextAlign,
      inputTextFieldAlign: inputTextFieldAlign ?? this.inputTextFieldAlign,
      initFontScale: initFontScale ?? this.initFontScale,
      maxFontScale: maxFontScale ?? this.maxFontScale,
      minFontScale: minFontScale ?? this.minFontScale,
      initialBackgroundColorMode:
          initialBackgroundColorMode ?? this.initialBackgroundColorMode,
      customTextStyles: customTextStyles ?? this.customTextStyles,
      defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      enableAutocorrect: enableAutocorrect ?? this.enableAutocorrect,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      enableImageBoundaryTextWrap:
          enableImageBoundaryTextWrap ?? this.enableImageBoundaryTextWrap,
    );
  }
}
