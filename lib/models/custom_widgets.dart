import 'package:flutter/widgets.dart';

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
  /// A custom widget for removing a layer or element from the editor interface.
  final Widget? removeLayer;

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

  /// Creates an instance of the `CustomWidgets` class with the specified properties.
  const ImageEditorCustomWidgets({
    this.removeLayer,
    this.appBar,
    this.appBarPaintingEditor,
    this.appBarTextEditor,
    this.appBarCropRotateEditor,
    this.appBarFilterEditor,
    this.appBarBlurEditor,
    this.bottomNavigationBar,
    this.bottomBarPaintingEditor,
  });
}
