import 'package:flutter/material.dart';

/// A wrapper widget that provides a themed layout for bottom UI components.
///
/// The [GroundedBottomWrapper] is designed to wrap the bottom sections of the
/// image editor, applying a given theme or falling back to a dark theme if none
/// is provided. It uses a [LayoutBuilder] to build its child widgets based on
/// the available constraints.
///
/// ## Parameters:
///
/// * [theme] - The [ThemeData] to apply to the child widgets. If null, a dark
///   theme is used by default.
/// * [children] - A function that returns a list of widgets based on the
///   constraints of the layout.
///
/// ## Example:
///
/// ```dart
/// GroundedBottomWrapper(
///   theme: ThemeData.light(),
///   children: (constraints) => [
///     Widget1(),
///     Widget2(),
///   ],
/// )
/// ```
///
/// The children are built dynamically using the provided [BoxConstraints],
/// allowing for flexible layout adjustments.
///
/// ## See also:
/// * [LayoutBuilder] - Used to access the constraints for building the
/// children.
/// * [Theme] - Provides the themed data to the child widgets.
class GroundedBottomWrapper extends StatefulWidget {
  /// Constructor for the [GroundedBottomWrapper].
  ///
  /// Requires the [theme] and [children] parameters.
  const GroundedBottomWrapper({
    super.key,
    required this.theme,
    required this.children,
  });

  /// The theme to apply to the child widgets.
  final ThemeData? theme;

  /// A function that returns the list of widgets to display, based on
  /// [BoxConstraints].
  final List<Widget> Function(BoxConstraints constraints) children;
  @override
  State<GroundedBottomWrapper> createState() => _GroundedBottomWrapperState();
}

/// State class for [GroundedBottomWrapper].
///
/// This state class manages the layout and theme application for the bottom
/// wrapper. It uses [LayoutBuilder] to provide the available constraints to
/// the child widgets.
class _GroundedBottomWrapperState extends State<GroundedBottomWrapper> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          data: widget.theme ?? ThemeData.dark(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.children(constraints),
          ),
        );
      },
    );
  }
}
