// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Project imports:
import '../../../utils/unique_id_generator.dart';

/// A class representing the state of a thread capturing an image.
///
/// This class maintains the state and necessary data for capturing images
/// within a separate thread, providing information about the capture process
/// and managing the captured data.
class ThreadCaptureState {
  /// Creates an instance of [ThreadCaptureState].
  ///
  /// This constructor initializes the capture state, generating a unique
  /// identifier for the capture and setting up a completer for managing
  /// captured image data.
  ///
  /// Example:
  /// ```
  /// ThreadCaptureState captureState = ThreadCaptureState();
  /// ```
  ThreadCaptureState() {
    completer = Completer();
    id = generateUniqueId();
  }

  /// Indicates whether the capture process encountered an error.
  ///
  /// This boolean flag is set to `true` if the capture process is broken due
  /// to an error or unexpected issue.
  bool broken = false;

  /// Indicates whether the rendered image data has been read.
  ///
  /// This boolean flag is set to `true` once the captured image data has been
  /// successfully read and processed.
  bool processedRenderedImage = false;

  /// A unique identifier for the capture process.
  ///
  /// This string is generated upon creation of the capture state, providing a
  /// unique reference for the capture operation.
  late String id;

  /// A completer for managing the captured image data.
  ///
  /// This completer is used to handle the asynchronous operation of capturing
  /// the image data, allowing for completion handling and result retrieval.
  late Completer<Uint8List> completer;
}
