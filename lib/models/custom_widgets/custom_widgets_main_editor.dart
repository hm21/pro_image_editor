// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_typedef.dart';

class CustomWidgetsMainEditor {
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
    Stream rebuildStream,
    Widget content,
  )? wrapBody;

  /// A custom app bar widget.
  ///
  /// **Example**
  /// appBar: (editor, rebuildStream) => ReactiveCustomAppbar(
  ///   stream: rebuildStream,
  ///   builder: (_) => AppBar(
  ///     title: const Text('Title'),
  ///   ),
  /// ),
  final ReactiveCustomAppbar? Function(
    ProImageEditorState editor,
    Stream rebuildStream,
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
    Stream rebuildStream,
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
    Stream rebuildStream,
  )? bodyItems;

  const CustomWidgetsMainEditor({
    this.closeWarningDialog,
    this.removeLayerArea,
    this.wrapBody,
    this.appBar,
    this.bottomBar,
    this.bodyItems,
  });
}
