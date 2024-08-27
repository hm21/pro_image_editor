// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for the main editor interface in an image editor.
///
/// This widget provides a customizable interface for the main editing area,
/// allowing for configuration of the app bar, bottom bar, body items, and
/// additional components specific to the main editor functionality.
class CustomWidgetsMainEditor {
  /// Creates a [CustomWidgetsMainEditor] widget.
  ///
  /// This widget allows customization of various components in the main editor,
  /// enabling a flexible design tailored to specific editing needs.
  ///
  /// Example:
  /// ```
  /// CustomWidgetsMainEditor(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   closeWarningDialog: myCloseWarningDialog,
  ///   removeLayerArea: myRemoveLayerArea,
  ///   wrapBody: myWrapBody,
  /// )
  /// ```
  const CustomWidgetsMainEditor({
    this.closeWarningDialog,
    this.removeLayerArea,
    this.wrapBody,
    this.appBar,
    this.bottomBar,
    this.bodyItems,
  });

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
  ///              content: const Text('Are you sure you want to close the
  /// Image Editor? Your changes will not be saved.'),
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
  final Future<bool> Function(ProImageEditorState editor)? closeWarningDialog;

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
  final RemoveButton? removeLayerArea;

  /// This is helpful when you want to interact with the full body.
  final Widget Function(
    ProImageEditorState editor,
    Stream<void> rebuildStream,
    Widget content,
  )? wrapBody;

  /// A custom app bar widget.
  ///
  /// **Example**
  /// ```dart
  /// appBar: (editor, rebuildStream) => ReactiveCustomAppbar(
  ///   stream: rebuildStream,
  ///   builder: (_) => AppBar(
  ///     title: const Text('Title'),
  ///   ),
  /// ),
  /// ```
  final ReactiveCustomAppbar? Function(
    ProImageEditorState editor,
    Stream<void> rebuildStream,
  )? appBar;

  /// A custom bottom bar widget.
  ///
  /// **IMPORTANT:** You must add the `key` to your bottombar widget that the
  /// editor calculate layer movements correctly.
  ///
  /// **Example:**
  /// ```dart
  /// bottomBar: (editor, rebuildStream, key) {
  ///   return ReactiveCustomWidget(
  ///     stream: rebuildStream,
  ///     builder: (_) => BottomAppBar(
  ///       key: key,
  ///       child: const Icon(Icons.abc),
  ///     ),
  ///   );
  /// },
  /// ```
  final ReactiveCustomWidget? Function(
    ProImageEditorState editor,
    Stream<void> rebuildStream,
    Key key,
  )? bottomBar;

  /// Add custom widgets at a specific position inside the body.
  ///
  /// **Example:**
  /// ```dart
  /// bodyItems: (editor, rebuildStream) => [
  ///   ReactiveCustomWidget(
  ///     stream: rebuildStream,
  ///     builder: (_) => Container(
  ///       width: 100,
  ///       height: 100,
  ///       color: Colors.red,
  ///     ),
  ///   ),
  /// ],
  /// ```
  final List<ReactiveCustomWidget> Function(
    ProImageEditorState editor,
    Stream<void> rebuildStream,
  )? bodyItems;

  /// Creates a copy of this `CustomWidgetsMainEditor` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [CustomWidgetsMainEditor] with some properties updated while keeping the
  /// others unchanged.
  CustomWidgetsMainEditor copyWith({
    Future<bool> Function(ProImageEditorState editor)? closeWarningDialog,
    RemoveButton? removeLayerArea,
    Widget Function(
      ProImageEditorState editor,
      Stream<void> rebuildStream,
      Widget content,
    )? wrapBody,
    ReactiveCustomAppbar? Function(
      ProImageEditorState editor,
      Stream<void> rebuildStream,
    )? appBar,
    ReactiveCustomWidget? Function(
      ProImageEditorState editor,
      Stream<void> rebuildStream,
      Key key,
    )? bottomBar,
    List<ReactiveCustomWidget> Function(
      ProImageEditorState editor,
      Stream<void> rebuildStream,
    )? bodyItems,
  }) {
    return CustomWidgetsMainEditor(
      closeWarningDialog: closeWarningDialog ?? this.closeWarningDialog,
      removeLayerArea: removeLayerArea ?? this.removeLayerArea,
      wrapBody: wrapBody ?? this.wrapBody,
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
    );
  }
}
