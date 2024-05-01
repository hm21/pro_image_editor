import 'package:flutter/material.dart';

class Constants extends InheritedWidget {
  final double minLayerSize = 64.0;

  const Constants({
    super.key,
    required super.child,
  });

  static Constants? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Constants>();
  }

  @override
  bool updateShouldNotify(Constants oldWidget) {
    return oldWidget.minLayerSize != minLayerSize;
  }
}
