/// Compares two dynamic objects to check if they are equal.
///
/// This function supports comparison of nested Maps and Lists. It recursively
/// checks the equality of each element in the Maps or Lists. If the objects are
/// neither Maps nor Lists, it performs a simple equality check.
///
/// - Parameters:
///   - a: The first dynamic object to compare.
///   - b: The second dynamic object to compare.
///
/// - Returns: A boolean value indicating whether the two objects are equal.
bool mapIsEqual(dynamic a, dynamic b) {
  // Layer copies share their meta maps, and the state history export compares
  // every layer of every step, so skip walking a map compared with itself.
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || !mapIsEqual(a[key], b[key])) {
        return false;
      }
    }
    return true;
  } else if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!mapIsEqual(a[i], b[i])) {
        return false;
      }
    }
    return true;
  } else {
    return a == b;
  }
}
