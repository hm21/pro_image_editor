// Flutter imports:
import 'package:flutter/material.dart';

/// A custom app bar widget that reacts to stream updates.
///
/// This class extends [StatelessWidget] and implements [PreferredSizeWidget],
/// providing a reactive app bar that updates its content based on changes
/// emitted by a given stream.
class ReactiveCustomAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates an instance of [ReactiveCustomAppbar].
  ///
  /// The constructor initializes the app bar with a builder function and a
  /// stream. The app bar size can be customized using the [appbarSize]
  /// parameter, defaulting to the standard toolbar height.
  ///
  /// Example:
  /// ```
  /// ReactiveCustomAppbar(
  ///   builder: (context) => AppBar(title: Text('Reactive App Bar')),
  ///   stream: myUpdateStream,
  ///   appbarSize: Size.fromHeight(60.0),
  /// )
  /// ```
  const ReactiveCustomAppbar({
    super.key,
    required this.builder,
    required this.stream,
    Size? appbarSize,
  }) : preferredSize = appbarSize ?? const Size.fromHeight(kToolbarHeight);

  /// A builder function to create the app bar widget.
  ///
  /// This function is called to build the app bar based on the current context
  /// and any changes in the stream.
  final PreferredSizeWidget Function(BuildContext context) builder;

  /// A stream that triggers updates to the app bar.
  ///
  /// This [Stream<void>] is used to listen for changes that require the app
  /// bar to rebuild, allowing for dynamic updates in response to events.
  final Stream<void> stream;

  /// The preferred size of the app bar.
  ///
  /// This [Size] determines the height of the app bar, defaulting to the
  /// standard toolbar height if not specified.
  @override
  final Size preferredSize;

  /// Builds the widget tree for the reactive app bar.
  ///
  /// This method constructs a [StreamBuilder] that listens to the specified
  /// stream and uses the builder function to update the app bar in response to
  /// stream events.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return builder(context);
      },
    );
  }
}
