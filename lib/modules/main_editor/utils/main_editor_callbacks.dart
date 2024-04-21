import 'dart:typed_data';

/// A typedef representing a callback function invoked when image editing is complete.
///
/// This callback typically receives the edited image as bytes in the form of a Uint8List.
/// It should return a Future indicating the completion of any asynchronous operations.
typedef ImageEditingCompleteCallback = Future<void> Function(Uint8List bytes);

/// A typedef representing a callback function invoked when no image editing is performed.
///
/// This callback does not receive any parameters and is typically used to handle scenarios
/// where the user cancels or exits the image editing process without making any changes.
typedef ImageEditingEmptyCallback = void Function();
