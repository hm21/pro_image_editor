// Flutter imports:
import 'package:flutter/material.dart';

class Constants extends InheritedWidget {
  const Constants({
    super.key,
    required super.child,
  });

  static Constants? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Constants>();
  }

  @override
  bool updateShouldNotify(Constants oldWidget) {
    return false;
  }
}
