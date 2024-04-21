/// Represents the history of a blur state.
class BlurStateHistory {
  /// The opacity of the blur.
  final double blur;

  /// Constructs a [BlurStateHistory] instance.
  BlurStateHistory({
    this.blur = 0,
  });

  /// Constructs a [BlurStateHistory] instance from a map representation.
  ///
  /// The [map] should contain 'blur' keys.
  BlurStateHistory.fromMap(Map map)
      : blur = num.tryParse(map['blur']?.toString() ?? '0')?.toDouble() ?? 0;

  /// Converts this blur state history object to a Map.
  ///
  /// Returns a Map representing the properties of this blur state history object,
  /// including the blur.
  Map toMap() {
    return {
      'blur': blur,
    };
  }
}
