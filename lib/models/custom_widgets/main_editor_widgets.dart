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
class MainEditorWidgets {
  /// Creates a [MainEditorWidgets] widget.
  ///
  /// This widget allows customization of various components in the main editor,
  /// enabling a flexible design tailored to specific editing needs.
  ///
  /// Example:
  /// ```
  /// MainEditorWidgets(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   closeWarningDialog: myCloseWarningDialog,
  ///   removeLayerArea: myRemoveLayerArea,
  ///   wrapBody: myWrapBody,
  /// )
  /// ```
  const MainEditorWidgets({
    this.closeWarningDialog,
    this.removeLayerArea,
    this.wrapBody,
    this.appBar,
    this.bottomBar,
    this.bodyItems,
    this.bodyItemsRecorded,
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
  ///              content: const Text('''Are you sure you want to close the
  /// Image Editor? Your changes will not be saved.'''),
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

  /// {@macro removeLayerArea}
  final RemoveLayerArea? removeLayerArea;

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

  /// {@macro customBodyItem}
  final CustomBodyItems<ProImageEditorState>? bodyItems;

  /// {@macro customBodyItemRecorded}
  final CustomBodyItems<ProImageEditorState>? bodyItemsRecorded;

  /// Creates a copy of this `MainEditorWidgets` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [MainEditorWidgets] with some properties updated while keeping the
  /// others unchanged.
  MainEditorWidgets copyWith({
    Future<bool> Function(ProImageEditorState editor)? closeWarningDialog,
    RemoveLayerArea? removeLayerArea,
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
    CustomBodyItems<ProImageEditorState>? bodyItems,
    CustomBodyItems<ProImageEditorState>? bodyItemsRecorded,
  }) {
    return MainEditorWidgets(
      closeWarningDialog: closeWarningDialog ?? this.closeWarningDialog,
      removeLayerArea: removeLayerArea ?? this.removeLayerArea,
      wrapBody: wrapBody ?? this.wrapBody,
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      bodyItemsRecorded: bodyItemsRecorded ?? this.bodyItemsRecorded,
    );
  }
}
