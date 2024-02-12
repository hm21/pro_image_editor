import 'package:flutter/material.dart';

/// A custom TextButton widget with an icon placed above the label.
class FlatIconTextButton extends TextButton {
  /// Creates a [FlatIconTextButton] widget with the specified properties.
  ///
  /// The [icon] and [label] parameters are required, while the others are optional.
  FlatIconTextButton({
    super.key,
    super.onPressed,
    super.clipBehavior,
    super.focusNode,
    required Widget icon,
    required Widget label,
  }) : super(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            maximumSize:
                const Size(double.infinity, kBottomNavigationBarHeight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              const SizedBox(height: 5.0),
              label,
            ],
          ),
        );
}
