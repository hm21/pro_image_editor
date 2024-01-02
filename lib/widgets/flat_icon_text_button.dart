import 'package:flutter/material.dart';

/// A custom TextButton widget with an icon placed above the label.
class FlatIconTextButton extends TextButton {
  /// Creates a [FlatIconTextButton] widget with the specified properties.
  ///
  /// The [icon] and [label] parameters are required, while the others are optional.
  FlatIconTextButton({
    Key? key,
    VoidCallback? onPressed,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    required Widget icon,
    required Widget label,
  }) : super(
          key: key,
          onPressed: onPressed,
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              const SizedBox(height: 4.0),
              label,
            ],
          ),
        );
}
