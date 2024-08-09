// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

/// A typedef representing a callback function invoked when image editing is
/// complete.
///
/// This callback typically receives the edited image as bytes in the form of a
/// Uint8List.
/// It should return a Future indicating the completion of any asynchronous
/// operations.
typedef ImageEditingCompleteCallback = Future<void> Function(Uint8List bytes);

/// A callback function type that is invoked when a thumbnail image is
/// generated.
///
/// This callback provides the generated thumbnail image bytes and the raw image
/// as its parameters. It is expected to return a `Future<void>`, allowing for
/// asynchronous operations to be performed if needed.
///
/// The [thumbnailBytes] parameter contains the bytes of the generated
/// thumbnail image.
/// The [rawImage] parameter contains the raw `ui.Image` object of the
/// original image.
typedef ThumbnailGeneratedCallback = Future<void> Function(
    Uint8List thumbnailBytes, ui.Image rawImage);

/// A typedef representing a callback function invoked when no image editing is
/// performed.
///
/// This callback does not receive any parameters and is typically used to
/// handle scenarios where the user cancels or exits the image editing process
/// without making any changes.
typedef ImageEditingEmptyCallback = void Function();

/// A typedef representing a callback function invoked when the ui should
/// update.
typedef UpdateUiCallback = void Function();

/// A typedef representing a callback function invoked when a flip action is
/// performed.
///
/// The [flipX] parameter indicates whether the image is flipped horizontally.
/// The [flipY] parameter indicates whether the image is flipped vertically.
typedef FlipCallback = Function(bool flipX, bool flipY);
