/// A class that defines the safe area configuration for the editor.
///
/// The [EditorSafeArea] class is used to specify which edges of the editor
/// should have padding to avoid overlapping with system UI elements, such
/// as notches, status bars, or side obstructions. Each edge (top, left, right,
/// and bottom) can be individually enabled or disabled based on the needs
/// of the layout.
///
/// By default, all edges are set to `true`, meaning padding will be applied
/// on all sides of the editor.
///
/// ## Parameters:
///
/// * [top] - If `true`, padding will be applied at the top to avoid system
///   UI elements (default is `true`).
/// * [left] - If `true`, padding will be applied on the left edge
///   (default is `true`).
/// * [right] - If `true`, padding will be applied on the right edge
///   (default is `true`).
/// * [bottom] - If `true`, padding will be applied at the bottom to avoid
///   system UI elements (default is `true`).
///
/// ## Example:
///
/// ```dart
/// const EditorSafeArea(
///   top: true,
///   left: false,
///   right: true,
///   bottom: false,
/// )
/// ```
/// This example applies padding to the top and right edges, but not the
/// left or bottom.
class EditorSafeArea {
  /// Creates an [EditorSafeArea] with customizable safe area padding for
  /// each edge.
  ///
  /// By default, padding is applied to all edges.
  const EditorSafeArea({
    this.top = true,
    this.left = true,
    this.right = true,
    this.bottom = true,
  });

  /// If `true`, applies safe area padding to the top edge.
  final bool top;

  /// If `true`, applies safe area padding to the left edge.
  final bool left;

  /// If `true`, applies safe area padding to the right edge.
  final bool right;

  /// If `true`, applies safe area padding to the bottom edge.
  final bool bottom;
}
