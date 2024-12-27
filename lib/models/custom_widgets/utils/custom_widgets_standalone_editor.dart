// Project imports:
import 'package:pro_image_editor/models/custom_widgets/utils/custom_widgets_typedef.dart';
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_appbar.dart';
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_widget.dart';

/// An abstract class representing a customizable standalone editor widget.
///
/// This class provides a base for creating standalone editor widgets, allowing
/// customization of the app bar, bottom bar, and body items.
abstract class CustomWidgetsStandaloneEditor<EditorState> {
  /// Creates a [CustomWidgetsStandaloneEditor] instance.
  ///
  /// This constructor allows subclasses to specify the app bar, bottom bar,
  /// and body items, enabling flexible design and functionality for editor
  /// widgets.
  ///
  /// Example:
  /// ```
  /// class MyEditor extends CustomWidgetsStandaloneEditor<MyEditorState> {
  ///   const MyEditor({
  ///     super.appBar,
  ///     super.bottomBar,
  ///     super.bodyItems,
  ///     super.bodyItemsRecorded,
  ///   });
  /// }
  /// ```
  const CustomWidgetsStandaloneEditor({
    this.appBar,
    this.bottomBar,
    this.bodyItems,
    this.bodyItemsRecorded,
  });

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
      EditorState editorState, Stream<void> rebuildStream)? appBar;

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
      EditorState editorState, Stream<void> rebuildStream)? bottomBar;

  /// {@macro customBodyItem}
  final CustomBodyItems<EditorState>? bodyItems;

  /// {@macro customBodyItemRecorded}
  final CustomBodyItems<EditorState>? bodyItemsRecorded;

  /// An abstract method to enforce implementation of the `copyWith` method
  /// in all subclasses.
  CustomWidgetsStandaloneEditor<EditorState> copyWith({
    ReactiveCustomAppbar? Function(
            EditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            EditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<EditorState>? bodyItems,
  });
}
