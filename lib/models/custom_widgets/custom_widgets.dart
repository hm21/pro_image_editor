// Flutter imports:
import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import 'custom_widgets_layer_interaction.dart';

export 'custom_widgets_blur_editor.dart';
export 'custom_widgets_crop_rotate_editor.dart';
export 'custom_widgets_filter_editor.dart';
export 'custom_widgets_main_editor.dart';
export 'custom_widgets_paint_editor.dart';
export 'custom_widgets_text_editor.dart';
export 'custom_widgets_tune_editor.dart';

/// The `ImageEditorCustomWidgets` class encapsulates custom widget components
/// that can be used within various parts of the application's user interface.
/// It provides flexibility for customizing the appearance and behavior of
/// specific UI elements such as app bars, bottom navigation bars, and more.
class ImageEditorCustomWidgets {
  /// Creates an instance of the `CustomWidgets` class with the specified
  /// properties.
  const ImageEditorCustomWidgets({
    this.loadingDialog,
    this.circularProgressIndicator,
    this.mainEditor = const CustomWidgetsMainEditor(),
    this.paintEditor = const CustomWidgetsPaintEditor(),
    this.textEditor = const CustomWidgetsTextEditor(),
    this.cropRotateEditor = const CustomWidgetsCropRotateEditor(),
    this.filterEditor = const CustomWidgetsFilterEditor(),
    this.blurEditor = const CustomWidgetsBlurEditor(),
    this.tuneEditor = const CustomWidgetsTuneEditor(),
    this.layerInteraction = const CustomWidgetsLayerInteraction(),
  });

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

  /// The tune editor instance.
  final CustomWidgetsTuneEditor tuneEditor;

  /// The blur editor instance.
  final CustomWidgetsBlurEditor blurEditor;

  /// Defines the set of interactions (edit, remove, rotate/scale) for
  /// custom widgets.
  final CustomWidgetsLayerInteraction layerInteraction;

  /// Replace the existing loading dialog.
  ///
  /// **Example:**
  /// ```dart
  /// loadingDialog: (message, configs) => Stack(
  ///   children: [
  ///     ModalBarrier(
  ///       onDismiss: kDebugMode ? LoadingDialog.instance.hide : null,
  ///       color: Colors.black54,
  ///       dismissible: kDebugMode,
  ///     ),
  ///     Center(
  ///       child: Theme(
  ///         data: Theme.of(context),
  ///         child: AlertDialog(
  ///           contentPadding:
  ///               const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  ///           content: ConstrainedBox(
  ///             constraints: const BoxConstraints(maxWidth: 500),
  ///             child: Padding(
  ///               padding: const EdgeInsets.only(top: 3.0),
  ///               child: Row(
  ///                 crossAxisAlignment: CrossAxisAlignment.center,
  ///                 mainAxisAlignment: MainAxisAlignment.start,
  ///                 children: [
  ///                   Padding(
  ///                     padding: const EdgeInsets.only(right: 20.0),
  ///                     child: SizedBox(
  ///                       height: 40,
  ///                       width: 40,
  ///                       child: FittedBox(
  ///                         child: PlatformCircularProgressIndicator(
  ///                           configs: configs,
  ///                         ),
  ///                       ),
  ///                     ),
  ///                   ),
  ///                   Expanded(
  ///                     child: Text(
  ///                       message,
  ///                       style: platformTextStyle(
  ///                         context,
  ///                         configs.designMode,
  ///                       ).copyWith(
  ///                         fontSize: 16,
  ///                         color: configs.imageEditorTheme
  ///                             .loadingDialogTheme.textColor,
  ///                       ),
  ///                       textAlign: TextAlign.start,
  ///                     ),
  ///                   ),
  ///                 ],
  ///               ),
  ///             ),
  ///           ),
  ///         ),
  ///       ),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final Widget Function(String message, ProImageEditorConfigs configs)?
      loadingDialog;

  /// Replace the existing CircularProgressIndicator.
  final Widget? circularProgressIndicator;

  /// Creates a copy of this `ImageEditorCustomWidgets` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ImageEditorCustomWidgets] with some properties updated while keeping the
  /// others unchanged.
  ImageEditorCustomWidgets copyWith({
    CustomWidgetsMainEditor? mainEditor,
    CustomWidgetsPaintEditor? paintEditor,
    CustomWidgetsTextEditor? textEditor,
    CustomWidgetsCropRotateEditor? cropRotateEditor,
    CustomWidgetsFilterEditor? filterEditor,
    CustomWidgetsTuneEditor? tuneEditor,
    CustomWidgetsBlurEditor? blurEditor,
    Widget Function(String message, ProImageEditorConfigs configs)?
        loadingDialog,
    Widget? circularProgressIndicator,
    CustomWidgetsLayerInteraction? layerInteraction,
  }) {
    return ImageEditorCustomWidgets(
      mainEditor: mainEditor ?? this.mainEditor,
      paintEditor: paintEditor ?? this.paintEditor,
      textEditor: textEditor ?? this.textEditor,
      cropRotateEditor: cropRotateEditor ?? this.cropRotateEditor,
      filterEditor: filterEditor ?? this.filterEditor,
      tuneEditor: tuneEditor ?? this.tuneEditor,
      blurEditor: blurEditor ?? this.blurEditor,
      loadingDialog: loadingDialog ?? this.loadingDialog,
      circularProgressIndicator:
          circularProgressIndicator ?? this.circularProgressIndicator,
      layerInteraction: layerInteraction ?? this.layerInteraction,
    );
  }
}
