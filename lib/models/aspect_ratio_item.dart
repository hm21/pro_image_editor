/// The `AspectRatioItem` class represents an item with an aspect ratio value and an
/// optional text description. It is commonly used to define aspect ratio options for
/// widgets or components that require a specific aspect ratio.
///
/// Usage:
///
/// ```dart
/// AspectRatioItem aspectRatioOption = AspectRatioItem(
///   value: 16 / 9, // Aspect ratio value (e.g., 16:9)
///   text: 'Wide Screen', // Optional text description
/// );
/// ```
///
/// Properties:
///
/// - `text`: The text description for this aspect ratio item, which is typically
///   used to provide a label or description for the aspect ratio.
///
/// - `value`: The numerical value representing the aspect ratio. It is expressed as
///   a double value, e.g., 16:9 is represented as `16 / 9`. This property is optional
///   but commonly used when setting aspect ratios for widgets.
///
/// Example Usage:
///
/// ```dart
/// AspectRatioItem aspectRatioOption = AspectRatioItem(
///   value: 16 / 9, // Aspect ratio value (e.g., 16:9)
///   text: 'Wide Screen', // Optional text description
/// );
/// ```
class AspectRatioItem {
  /// The text for this aspect ratio item.
  final String text;

  /// The numerical value representing the aspect ratio.
  final double? value;

  /// Creates an instance of the `AspectRatioItem` class with the specified properties.
  const AspectRatioItem({this.value, required this.text});
}
