// Flutter imports:
import 'package:flutter/material.dart';

/// A class that provides constant values like asset paths and network URLs
/// using [InheritedWidget], allowing them to be accessed anywhere in the
/// widget tree.
///
/// The [ExampleConstants] widget can be accessed using the `of` method, which
/// retrieves the nearest instance of this widget up the widget tree.
class ExampleConstants extends InheritedWidget {
  /// Creates an [ExampleConstants] widget.
  ///
  /// [child] is the widget subtree that can access the constants provided by
  /// this class.
  const ExampleConstants({
    super.key,
    required super.child,
  });

  /// A path to a demo image asset in the project.
  final String demoAssetPath = 'assets/demo.png';

  /// A URL to a demo image hosted on a remote server.
  final String demoNetworkUrl = 'https://picsum.photos/id/230/2000';

  /// Retrieves the nearest [ExampleConstants] instance from the widget tree.
  ///
  /// This method allows other widgets to access the constants (like asset paths
  /// and URLs) defined in this widget. Returns `null` if no [ExampleConstants]
  /// instance is found.
  static ExampleConstants? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ExampleConstants>();
  }

  /// Determines whether the widget should notify its dependents when it
  /// updates.
  ///
  /// In this case, since the constants won't change, it always returns `false`.
  @override
  bool updateShouldNotify(ExampleConstants oldWidget) {
    return false;
  }
}
