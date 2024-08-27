/// Configuration settings for a draggable bottom sheet component.
class ThemeDraggableSheet {
  /// Creates an instance of [ThemeDraggableSheet] with customizable settings.
  ///
  /// Example:
  ///
  /// ```dart
  /// ThemeDraggableSheet(
  ///   initialChildSize: 0.5,
  ///   minChildSize: 0.25,
  ///   maxChildSize: 1.0,
  ///   expand: false,
  ///   snap: true,
  ///   snapSizes: [0.25, 0.5, 0.75],
  ///   snapAnimationDuration: Duration(milliseconds: 200),
  ///   shouldCloseOnMinExtent: true,
  /// )
  /// ```
  const ThemeDraggableSheet({
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.expand = false,
    this.snap = false,
    this.snapSizes,
    this.snapAnimationDuration,
    this.shouldCloseOnMinExtent = true,
  });

  /// The initial size of the child as a fraction of the parent.
  ///
  /// Defaults to `0.5` (50% of the parent size).
  final double initialChildSize;

  /// The minimum size of the child as a fraction of the parent.
  ///
  /// Defaults to `0.25` (25% of the parent size).
  final double minChildSize;

  /// The maximum size of the child as a fraction of the parent.
  ///
  /// Defaults to `1.0` (100% of the parent size).
  final double maxChildSize;

  /// Whether the sheet should expand to fill the available space.
  ///
  /// Defaults to `false`.
  final bool expand;

  /// Whether the sheet should snap to certain sizes when dragged.
  ///
  /// Defaults to `false`.
  final bool snap;

  /// The list of sizes to which the sheet can snap.
  ///
  /// Each size is a fraction of the parent size. Only used if [snap] is `true`.
  final List<double>? snapSizes;

  /// The duration of the snapping animation.
  ///
  /// Only used if [snap] is `true`.
  final Duration? snapAnimationDuration;

  /// Whether the sheet should close when it reaches the minimum extent.
  ///
  /// Defaults to `true`.
  final bool shouldCloseOnMinExtent;

  /// Creates a copy of this `ThemeDraggableSheet` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ThemeDraggableSheet] with some properties updated while keeping the
  /// others unchanged.
  ThemeDraggableSheet copyWith({
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    bool? expand,
    bool? snap,
    List<double>? snapSizes,
    Duration? snapAnimationDuration,
    bool? shouldCloseOnMinExtent,
  }) {
    return ThemeDraggableSheet(
      initialChildSize: initialChildSize ?? this.initialChildSize,
      minChildSize: minChildSize ?? this.minChildSize,
      maxChildSize: maxChildSize ?? this.maxChildSize,
      expand: expand ?? this.expand,
      snap: snap ?? this.snap,
      snapSizes: snapSizes ?? this.snapSizes,
      snapAnimationDuration:
          snapAnimationDuration ?? this.snapAnimationDuration,
      shouldCloseOnMinExtent:
          shouldCloseOnMinExtent ?? this.shouldCloseOnMinExtent,
    );
  }
}
