// Flutter imports:
import 'package:flutter/widgets.dart';

export 'whatsapp/whatsapp_custom_text_styles.dart';

/// The `ImageEditorCustomWidgets` class encapsulates custom widget components that can be
/// used within various parts of the application's user interface. It provides
/// flexibility for customizing the appearance and behavior of specific UI elements
/// such as app bars, bottom navigation bars, and more.
///
/// Usage:
///
/// ```dart
/// ImageEditorCustomWidgets customUI = ImageEditorCustomWidgets(
///   appBar: CustomAppBar(),
///   bottomNavigationBar: CustomBottomNavigationBar(),
///   // Additional custom widgets...
/// );
/// ```
///
/// Properties:
///
/// - `removeLayer` (optional): A custom widget that can be used as a UI element
///   to remove a layer or element from the editor interface.
///
/// - `appBar` (optional): A custom app bar widget that can be used as the top
///   navigation bar in the application.
///
/// - `appBarPaintingEditor` (optional): A custom app bar widget specifically designed
///   for the painting editor component, if applicable.
///
/// - `appBarTextEditor` (optional): A custom app bar widget specifically designed for
///   the text editor component, if applicable.
///
/// - `appBarCropRotateEditor` (optional): A custom app bar widget specifically designed
///   for the crop and rotate editor component, if applicable.
///
/// - `appBarFilterEditor` (optional): A custom app bar widget specifically designed for
///   the filter editor component, if applicable.
///
/// - `appBarBlurEditor` (optional): A custom app bar widget specifically designed for
///   the blur editor component, if applicable.
///
/// - `bottomNavigationBar` (optional): A custom widget that can be used as a bottom
///   navigation bar in the application's user interface.
///
/// Example Usage:
///
/// ```dart
/// ImageEditorCustomWidgets customUI = ImageEditorCustomWidgets(
///   appBar: CustomAppBar(),
///   bottomNavigationBar: CustomBottomNavigationBar(),
/// );
/// ```
///
/// Please refer to the documentation of individual properties and methods for more details.
class ImageEditorCustomWidgets {
  /// A custom widget for removing a layer or element from the editor interface,
  /// when hover the layer over the area.
  ///
  /// **Example:**
  /// ```dart
  /// configs: ProImageEditorConfigs(
  ///   customWidgets: ImageEditorCustomWidgets(
  ///     removeLayer: (key, stream) {
  ///       return Positioned(
  ///         key: key, // Important add the key
  ///         top: 0,
  ///         left: 0,
  ///         child: SafeArea(
  ///           bottom: false,
  ///           child: StreamBuilder(
  ///               stream: stream, // Important add the stream
  ///               initialData: false,
  ///               builder: (context, snapshot) {
  ///                 return Container(
  ///                   height: 56,
  ///                   width: 56,
  ///                   decoration: BoxDecoration(
  ///                     color:
  ///                         snapshot.data ? Colors.red : Colors.grey.shade800,
  ///                     borderRadius: const BorderRadius.only(
  ///                         bottomRight: Radius.circular(100)),
  ///                   ),
  ///                   padding: const EdgeInsets.only(right: 12, bottom: 7),
  ///                   child: const Center(
  ///                     child: Icon(Icons.delete_outline, size: 28),
  ///                   ),
  ///                 );
  ///               },
  ///            ),
  ///         ),
  ///       );
  ///     },
  ///   ),
  /// );
  /// ```
  final RemoveButton? removeLayer;

  /// A custom app bar widget for the top navigation bar.
  final PreferredSizeWidget? appBar;

  /// A custom app bar widget for the painting editor component.
  final PreferredSizeWidget? appBarPaintingEditor;

  /// A custom app bar widget for the text editor component.
  final PreferredSizeWidget? appBarTextEditor;

  /// A custom app bar widget for the crop and rotate editor component.
  final PreferredSizeWidget? appBarCropRotateEditor;

  /// A custom app bar widget for the filter editor component.
  final PreferredSizeWidget? appBarFilterEditor;

  /// A custom app bar widget for the blur editor component.
  final PreferredSizeWidget? appBarBlurEditor;

  /// A custom widget for the bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// A custom bottom bar widget for the painting editor component.
  final Widget? bottomBarPaintingEditor;

  /// A custom bottom bar widget for the crop-rotate editor component.
  final Widget? bottomBarCropRotateEditor;

  /// A custom bottom bar widget for the text editor component.
  final Widget? bottomBarTextEditor;

  /// A custom color picker widget for the paint editor.
  ///
  /// This widget allows users to pick a color for the paint editor.
  final CustomColorPicker? colorPickerPaintEditor;

  /// A custom color picker widget for the text editor.
  ///
  /// This widget allows users to pick a color for the text editor.
  final CustomColorPicker? colorPickerTextEditor;

  /// A custom slider widget for the filter editor.
  ///
  /// This widget allows users to adjust values using a slider in the filter editor.
  final CustomSlider? sliderFilterEditor;

  /// A custom slider widget for the blur editor.
  ///
  /// This widget allows users to adjust the blur factor using a slider in the blur
  /// editor.
  final CustomSlider? sliderBlurEditor;

  /// A widget for selecting aspect ratio options in the crop editor.
  ///
  /// This widget allows users to select different aspect ratio options for the crop
  /// editor.
  final CropEditorAspectRatioOptions? cropEditorAspectRatioOptions;

  /// A custom widget that will be displayed in WhatsApp mode in the app bar on the top right, providing a useful custom "Done" button.
  final Widget? whatsAppOwnAppBarIcons;

  /// Add a custom widget at a specific position in the body.
  /// For example, you can use the Position widget to place a container:
  ///
  /// ```dart
  /// Position(
  ///   left: 0,
  ///   right: 0,
  ///   child: Container(),
  /// )
  /// ```
  final Widget? paintEditorBodyItem;

  /// Override the close warning dialog when we made changes.
  ///
  /// **Example:**
  /// ```dart
  /// configs: ProImageEditorConfigs(
  ///  customWidgets: ImageEditorCustomWidgets(
  ///    closeWarningDialog: () async {
  ///      return await showDialog<bool>(
  ///            context: context,
  ///            builder: (BuildContext context) => AlertDialog(
  ///              title: const Text('Close?'),
  ///              content: const Text('Are you sure you want to close the Image Editor? Your changes will not be saved.'),
  ///              actions: <Widget>[
  ///                TextButton(
  ///                  onPressed: () => Navigator.pop(context, false),
  ///                  child: const Text('Cancel'),
  ///                ),
  ///                TextButton(
  ///                  onPressed: () => Navigator.pop(context, true),
  ///                  child: const Text('OK'),
  ///                ),
  ///              ],
  ///            ),
  ///          ) ??
  ///          false;
  ///    },
  ///  ),
  /// ),
  /// ```
  final Future<bool> Function()? closeWarningDialog;

  /// The widget that is below the `Filter` button in the material design.
  /// You can create a text field and send button just like in whatsapp.
  ///
  /// Available in the WhatsApp theme only.
  final Widget? whatsAppBottomWidget;

  /// Creates an instance of the `CustomWidgets` class with the specified properties.
  const ImageEditorCustomWidgets({
    this.cropEditorAspectRatioOptions,
    this.sliderFilterEditor,
    this.sliderBlurEditor,
    this.colorPickerPaintEditor,
    this.colorPickerTextEditor,
    this.removeLayer,
    this.appBar,
    this.appBarPaintingEditor,
    this.appBarTextEditor,
    this.appBarCropRotateEditor,
    this.appBarFilterEditor,
    this.appBarBlurEditor,
    this.bottomNavigationBar,
    this.bottomBarPaintingEditor,
    this.bottomBarCropRotateEditor,
    this.bottomBarTextEditor,
    this.whatsAppBottomWidget,
    this.paintEditorBodyItem,
    this.closeWarningDialog,
    this.whatsAppOwnAppBarIcons,
  });
}

/// A function type that defines a widget for removing layers.
typedef RemoveButton = Widget Function(GlobalKey key, Stream stream);

/// A function type that defines a widget for selecting aspect ratio options
/// in a crop editor.
///
/// The function takes two parameters:
/// - `aspectRatio`: The selected aspect ratio.
/// - `originalAspectRatio`: The original aspect ratio of the image.
///
/// Returns a [Widget] that allows the user to select the given aspect ratio.
typedef CropEditorAspectRatioOptions = Widget Function(
  double aspectRatio,
  double originalAspectRatio,
);

/// A function type that defines a custom color picker widget.
///
/// The function takes two parameters:
/// - `currentColor`: The currently selected [Color].
/// - `color`: A function that will be called with the selected [Color].
///
/// Returns a [Widget] that allows the user to pick a color.
typedef CustomColorPicker = Widget Function(
    Color currentColor, void Function(Color color) setColor);

/// A function type that defines a custom slider widget.
///
/// - `value`: The current active value.
/// - `onChanged`: A function that will be called when the slider value changes.
/// - `onChangeEnd`: A function that will be called when the slider value change ends.
///
/// Returns a [Widget] that allows the user to adjust a value using a slider.
typedef CustomSlider = Widget Function(
  double value,
  Function(double value) onChanged,
  Function(double value) onChangeEnd,
);
