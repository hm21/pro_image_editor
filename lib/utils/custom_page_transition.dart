import 'package:flutter/material.dart';

/// A custom page route builder that allows specifying custom page transitions.
///
/// The `CustomPageRouteBuilder` is an extension of the `PageRouteBuilder` class that enables you to define custom page transition animations for your routes. It takes a `pageBuilder` and a `pageTransitionsBuilder` as required parameters.
///
/// Parameters:
/// - `pageBuilder`: A function that builds the content of the page.
/// - `pageTransitionsBuilder`: A `PageTransitionsBuilder` that defines the custom page transition animation.
///
/// Example Usage:
/// ```dart
/// final customPageRoute = CustomPageRouteBuilder(
///   pageBuilder: (context, animation, secondaryAnimation) => MyPage(),
///   pageTransitionsBuilder: MyCustomPageTransitions(),
/// );
///
/// Navigator.of(context).push(customPageRoute);
/// ```
class CustomPageRouteBuilder<T> extends PageRouteBuilder<T> {
  /// The custom page transitions builder.
  final PageTransitionsBuilder pageTransitionsBuilder;

  /// Creates a custom page route builder.
  ///
  /// The `pageBuilder` parameter is required and defines the content of the page.
  /// The `pageTransitionsBuilder` parameter is required and specifies the custom page transition animation.
  ///
  /// Example Usage:
  /// ```dart
  /// final customPageRoute = CustomPageRouteBuilder(
  ///   pageBuilder: (context, animation, secondaryAnimation) => MyPage(),
  ///   pageTransitionsBuilder: MyCustomPageTransitions(),
  /// );
  ///
  /// Navigator.of(context).push(customPageRoute);
  /// ```
  CustomPageRouteBuilder({
    required super.pageBuilder,
    required this.pageTransitionsBuilder,
  });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return pageTransitionsBuilder.buildTransitions(
        this, context, animation, secondaryAnimation, child);
  }
}
