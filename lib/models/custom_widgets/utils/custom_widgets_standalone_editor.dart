// Project imports:
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_appbar.dart';
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_widget.dart';

abstract class CustomWidgetsStandaloneEditor<EditorState> {
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
      EditorState editorState, Stream rebuildStream)? appBar;

  /// A custom bottom bar widget.
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
      EditorState editorState, Stream rebuildStream)? bottomBar;

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
    EditorState editorState,
    Stream rebuildStream,
  )? bodyItems;

  const CustomWidgetsStandaloneEditor({
    this.appBar,
    this.bottomBar,
    this.bodyItems,
  });
}
