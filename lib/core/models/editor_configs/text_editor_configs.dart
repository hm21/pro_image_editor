import 'package:material_ui/material_ui.dart';

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
  const TextEditorConfigs({
    this.layerFractionalOffset = const Offset(-0.5, -0.5),
    this.enableGesturePop = true,
    this.enableSuggestions = true,
    this.enableEdit = true,
    this.enableAutocorrect = true,
    this.showSelectFontStyleBottomBar = false,
    this.showTextAlignButton = true,
    this.showFontScaleButton = true,
    this.showBackgroundModeButton = true,
    this.enableMainEditorZoomFactor = false,
    this.enableTapOutsideToSave = true,
    this.enableAutoOverflow = true,
    this.enableAutoWrapOnLayer = true,
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
    this.enableImageBoundaryTextWrap = false,
    this.layerBounds,
    this.resizeToAvoidBottomInset = true,
    this.composingTextDecoration = TextDecoration.none,
    this.spellCheckConfiguration,
  }) : assert(initFontSize > 0, 'initFontSize must be positive'),
       assert(
         maxScale >= minScale,
         'maxScale must be greater than or equal to minScale',
       );

  /// {@macro layerFractionalOffset}
  @override
  final Offset layerFractionalOffset;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

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

  /// Whether the text should automatically wrap when it reaches the end of
  /// the screen on the final image.
  ///
  /// If set to `true`, the text will wrap to the next line instead of
  /// overflowing, ensuring it stays within the visible area
  /// (e.g., the screen width).
  ///
  /// If set to `false`, the text will only wrap if the user deliberately
  /// entered a new line while editing.
  final bool enableAutoWrapOnLayer;

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

  /// Returns the area of the editor body that text layers keep their lines
  /// inside, in the logical pixels of the body.
  ///
  /// A text layer otherwise keeps its line breaks wherever it is moved and
  /// however far it is scaled, so it can run past the canvas edges. With
  /// bounds set, its lines wrap where they would reach past an edge, measured
  /// from the center of the layer along its text, so its rotation counts too.
  /// Scaling a layer up or moving it towards an edge wraps its lines, and
  /// scaling it down or moving it back unwraps them. The width covers the
  /// whole layer, so its background, outline and shadows stay inside as well.
  ///
  /// Making room at an edge never wraps a layer narrower than its longest
  /// word; only a word wider than the bounds themselves is broken.
  /// [TextLayer.maxTextWidth] still applies when it is narrower. The layer is
  /// expected to be centered on its [Layer.offset], as the default
  /// [layerFractionalOffset] places it.
  ///
  /// The function receives the size of the main editor's body, which is the
  /// space [Layer.offset] is measured in. Sub-editors pass the same size, so
  /// layers wrap there as they do in the main editor. Defaults to `null`,
  /// which leaves text layers unconstrained.
  ///
  /// The bounds only decide how layers are drawn and are not stored in them,
  /// so anything that renders the same layers outside this editor, such as a
  /// `LayerRasterizer` capture, has to pass the same function to wrap their
  /// lines the same way.
  final Rect Function(Size editorBodySize)? layerBounds;

  /// Whether the Scaffold should resize to avoid the bottom inset (keyboard).
  ///
  /// When `true` (default), the editor will resize when the keyboard appears.
  /// When `false`, the editor will not resize and the keyboard may overlap
  /// the content.
  final bool resizeToAvoidBottomInset;

  /// The text decoration applied to the composing region while the user is
  /// typing with IME/suggestions active.
  ///
  /// By default this is [TextDecoration.none] so no underline is shown.
  /// Set to [TextDecoration.underline] to restore the default Flutter
  /// behavior.
  final TextDecoration composingTextDecoration;

  /// The spell check configuration for the text input field.
  ///
  /// When provided, enables spell checking with the given configuration.
  /// When `null`, spell checking is disabled.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// Creates a copy of this `TextEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TextEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  TextEditorConfigs copyWith({
    Offset? layerFractionalOffset,
    bool? enableGesturePop,
    bool? enableEdit,
    bool? showSelectFontStyleBottomBar,
    bool? enableMainEditorZoomFactor,
    bool? enableTapOutsideToSave,
    bool? enableAutoOverflow,
    bool? enableAutoWrapOnLayer,
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
    Rect Function(Size editorBodySize)? layerBounds,
    bool? showBackgroundModeButton,
    bool? showFontScaleButton,
    bool? showTextAlignButton,
    bool? resizeToAvoidBottomInset,
    TextDecoration? composingTextDecoration,
    SpellCheckConfiguration? spellCheckConfiguration,
  }) {
    return TextEditorConfigs(
      layerFractionalOffset:
          layerFractionalOffset ?? this.layerFractionalOffset,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      safeArea: safeArea ?? this.safeArea,
      enableEdit: enableEdit ?? this.enableEdit,
      showSelectFontStyleBottomBar:
          showSelectFontStyleBottomBar ?? this.showSelectFontStyleBottomBar,
      enableMainEditorZoomFactor:
          enableMainEditorZoomFactor ?? this.enableMainEditorZoomFactor,
      enableTapOutsideToSave:
          enableTapOutsideToSave ?? this.enableTapOutsideToSave,
      enableAutoOverflow: enableAutoOverflow ?? this.enableAutoOverflow,
      enableAutoWrapOnLayer:
          enableAutoWrapOnLayer ?? this.enableAutoWrapOnLayer,
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
      layerBounds: layerBounds ?? this.layerBounds,
      showBackgroundModeButton:
          showBackgroundModeButton ?? this.showBackgroundModeButton,
      showFontScaleButton: showFontScaleButton ?? this.showFontScaleButton,
      showTextAlignButton: showTextAlignButton ?? this.showTextAlignButton,
      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset ?? this.resizeToAvoidBottomInset,
      composingTextDecoration:
          composingTextDecoration ?? this.composingTextDecoration,
      spellCheckConfiguration:
          spellCheckConfiguration ?? this.spellCheckConfiguration,
    );
  }
}
