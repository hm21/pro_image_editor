/// An enumeration representing the modes of swipe interaction.
///
/// The [SwipeMode] enum defines the possible directions for swipe gestures
/// and a default state representing no swipe action. It can be used in
/// applications to determine how user swipe inputs should be handled.
enum SwipeMode {
  /// Represents an upward swipe gesture.
  ///
  /// This mode indicates that a user has swiped up on the interface, and it
  /// can be used to trigger actions or transitions that correspond to upward
  /// motion.
  up,

  /// Represents a downward swipe gesture.
  ///
  /// This mode indicates that a user has swiped down on the interface, and it
  /// can be used to trigger actions or transitions that correspond to downward
  /// motion.
  down,

  /// Represents the absence of any swipe gesture.
  ///
  /// This mode is used to indicate that no swipe action has occurred, and it
  /// can serve as a default state for handling swipe interactions.
  none,
}
