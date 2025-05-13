import 'dart:ui';

/// Gets the minimum size between two sizes.
  ///
  /// This method returns the smaller of two sizes, ensuring that the resulting
  /// size is neither null nor empty. If the first size (`a`) 
  /// is valid (non-null and non-empty), it is returned.
  /// Otherwise, the second size (`b`) is checked. If `b` is also empty, 
  /// a default size of (1, 1) is returned.
  /// If `b` is valid, it is returned.
  Size getValidSizeOrDefault(Size? a, Size b) {
    return a == null || a.isEmpty
        ? b.isEmpty
            ? const Size(1, 1)
            : b
        : a;
  }