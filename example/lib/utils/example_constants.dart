// Flutter imports:
import 'package:flutter/material.dart';

class ExampleConstants extends InheritedWidget {
  final String demoAssetPath = 'assets/demo.png';
  final String demoNetworkUrl = 'https://picsum.photos/id/230/2000';

  const ExampleConstants({
    super.key,
    required super.child,
  });

  static ExampleConstants? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ExampleConstants>();
  }

  @override
  bool updateShouldNotify(ExampleConstants oldWidget) {
    return false;
  }
}
