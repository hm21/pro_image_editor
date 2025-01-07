// Dart imports:
import 'dart:typed_data';

/// Represents a response containing image data from the image processing
/// thread.
class ThreadResponse {
  /// Constructs a [ThreadResponse] instance.
  ///
  /// All parameters are required.
  const ThreadResponse({
    required this.id,
    required this.bytes,
  });

  /// The unique identifier.
  final String id;

  /// The byte data of the image, can be null.
  final Uint8List? bytes;
}
