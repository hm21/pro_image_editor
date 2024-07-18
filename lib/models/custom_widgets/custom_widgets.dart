// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'custom_widgets_blur_editor.dart';
import 'custom_widgets_crop_rotate_editor.dart';
import 'custom_widgets_filter_editor.dart';
import 'custom_widgets_main_editor.dart';
import 'custom_widgets_paint_editor.dart';
import 'custom_widgets_text_editor.dart';

export 'custom_widgets_blur_editor.dart';
export 'custom_widgets_crop_rotate_editor.dart';
export 'custom_widgets_filter_editor.dart';
export 'custom_widgets_paint_editor.dart';
export 'custom_widgets_text_editor.dart';
export 'custom_widgets_main_editor.dart';

/// The `ImageEditorCustomWidgets` class encapsulates custom widget components that can be
/// used within various parts of the application's user interface. It provides
/// flexibility for customizing the appearance and behavior of specific UI elements
/// such as app bars, bottom navigation bars, and more.
class ImageEditorCustomWidgets {
  /// The main editor instance.
  final CustomWidgetsMainEditor mainEditor;

  /// The paint editor instance.
  final CustomWidgetsPaintEditor paintEditor;

  /// The text editor instance.
  final CustomWidgetsTextEditor textEditor;

  /// The crop and rotate editor instance.
  final CustomWidgetsCropRotateEditor cropRotateEditor;

  /// The filter editor instance.
  final CustomWidgetsFilterEditor filterEditor;

  /// The blur editor instance.
  final CustomWidgetsBlurEditor blurEditor;

  /// Replace the existing loading dialog.
  final Widget? loadingDialog;

  /// Replace the existing CircularProgressIndicator.
  final Widget? circularProgressIndicator;

  /// Creates an instance of the `CustomWidgets` class with the specified properties.
  const ImageEditorCustomWidgets({
    this.loadingDialog,
    this.circularProgressIndicator,
    this.mainEditor = const CustomWidgetsMainEditor(),
    this.paintEditor = const CustomWidgetsPaintEditor(),
    this.textEditor = const CustomWidgetsTextEditor(),
    this.cropRotateEditor = const CustomWidgetsCropRotateEditor(),
    this.filterEditor = const CustomWidgetsFilterEditor(),
    this.blurEditor = const CustomWidgetsBlurEditor(),
  });
}
