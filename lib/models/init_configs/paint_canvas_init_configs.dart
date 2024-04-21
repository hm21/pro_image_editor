import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Configuration class for initializing the paint canvas.
class PaintCanvasInitConfigs {
  /// A widget to display as a placeholder.
  final Widget? placeholderWidget;

  /// Determines whether the canvas is scalable.
  final bool? scalable;

  /// Determines whether to show the color picker.
  final bool? showColorPicker;

  /// List of colors to be used in the color picker.
  final List<Color>? colors;

  /// Callback function to save the canvas.
  final Function? save;

  /// Callback function to update the canvas.
  final VoidCallback? onUpdate;

  /// Icon widget for undo action.
  final Widget? undoIcon;

  /// Icon widget for color selection.
  final Widget? colorIcon;

  /// Size of the image.
  final Size imageSize;

  /// Theme data for the canvas.
  final ThemeData theme;

  /// Internationalization settings.
  final I18n i18n;

  /// Theme settings for the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// Icons used in the image editor.
  final ImageEditorIcons icons;

  /// Design mode for the image editor.
  final ImageEditorDesignModeE designMode;

  /// Configuration options for the paint editor.
  final PaintEditorConfigs configs;

  /// Creates a new instance of [PaintCanvasInitConfigs].
  ///
  /// The [imageSize] parameter specifies the size of the image.
  /// The [theme] parameter specifies the theme data for the canvas.
  /// The [i18n] parameter specifies internationalization settings.
  /// The [imageEditorTheme] parameter specifies theme settings for the image editor.
  /// The [icons] parameter specifies icons used in the image editor.
  /// The [designMode] parameter specifies the design mode for the image editor.
  /// The [configs] parameter specifies configuration options for the paint editor.
  const PaintCanvasInitConfigs({
    this.placeholderWidget,
    this.scalable,
    this.showColorPicker,
    this.colors,
    this.save,
    this.onUpdate,
    this.undoIcon,
    this.colorIcon,
    required this.imageSize,
    required this.theme,
    required this.i18n,
    required this.imageEditorTheme,
    required this.icons,
    required this.designMode,
    required this.configs,
  });
}
