/// A typedef representing a matrix for image filtering operations.
///
/// This typedef defines a two-dimensional list of doubles, used as a matrix
/// for applying various image filtering transformations. Each sub-list
/// represents a row in the matrix, and each element in the sub-list represents
/// a coefficient used in the filtering calculation.
///
/// The [FilterMatrix] is typically used in image processing to define how
/// different color channels should be adjusted to achieve effects like
/// brightness, contrast, saturation, and other visual modifications.
///
/// Example:
/// ```
/// FilterMatrix exampleMatrix = [
///   [1.0, 0.0, 0.0, 0.0, 0.0],
///   [0.0, 1.0, 0.0, 0.0, 0.0],
///   [0.0, 0.0, 1.0, 0.0, 0.0],
///   [0.0, 0.0, 0.0, 1.0, 0.0],
///   [0.0, 0.0, 0.0, 0.0, 1.0],
/// ];
/// ```
///
/// In this example, the [exampleMatrix] is an identity matrix that does not
/// alter the image when applied, as it keeps the color channels unchanged.
typedef FilterMatrix = List<List<double>>;
