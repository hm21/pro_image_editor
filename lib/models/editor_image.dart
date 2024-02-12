import 'dart:io';
import 'dart:typed_data';

import '../utils/converters.dart';

/// Flutter EditorImage Class Documentation
///
/// The `EditorImage` class represents an image with multiple sources, including
/// bytes, file, network URL, and asset path. It provides flexibility for loading
/// images from various sources in a Flutter application.
///
/// Usage:
///
/// ```dart
/// EditorImage image = EditorImage(
///   byteArray: imageBytes,
/// );
/// ```
///
/// Properties:
///
/// - `byteArray` (optional): A byte array representing the image data.
///
/// - `file` (optional): A `File` object representing the image file.
///
/// - `networkUrl` (optional): A URL string pointing to an image on the internet.
///
/// - `assetPath` (optional): A string representing the asset path of an image.
///
/// Methods:
///
/// - `hasBytes`: Indicates whether the `byteArray` property is not null.
///
/// - `hasNetworkUrl`: Indicates whether the `networkUrl` property is not null.
///
/// - `hasFile`: Indicates whether the `file` property is not null.
///
/// - `hasAssetPath`: Indicates whether the `assetPath` property is not null.
///
/// - `safeByteArray`: A future that retrieves the image data as a `Uint8List` from
///   the appropriate source based on the `EditorImageType`.
///
/// - `type`: Returns the type of the image source, determined by the available properties.
///
/// Example Usage:
///
/// ```dart
/// EditorImage image = EditorImage(
///   byteArray: imageBytes,
/// );
///
/// if (image.hasBytes) {
///   // Handle image loaded from bytes.
/// }
///
/// EditorImageType imageType = image.type;
/// switch (imageType) {
///   case EditorImageType.memory:
///     // Handle image loaded from memory.
///     break;
///   case EditorImageType.asset:
///     // Handle image loaded from assets.
///     break;
///   case EditorImageType.file:
///     // Handle image loaded from file.
///     break;
///   case EditorImageType.network:
///     // Handle image loaded from network.
///     break;
/// }
/// ```
///
/// Please refer to the documentation of individual properties and methods for more details.
class EditorImage {
  /// A byte array representing the image data.
  final Uint8List? byteArray;

  /// A `File` object representing the image file.
  final File? file;

  /// A URL string pointing to an image on the internet.
  final String? networkUrl;

  /// A string representing the asset path of an image.
  final String? assetPath;

  /// Creates an instance of the `EditorImage` class with the specified properties.
  ///
  /// At least one of `byteArray`, `file`, `networkUrl`, or `assetPath` must not be null.
  const EditorImage({
    this.byteArray,
    this.file,
    this.networkUrl,
    this.assetPath,
  }) : assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Indicates whether the `byteArray` property is not null.
  bool get hasBytes => byteArray != null;

  /// Indicates whether the `networkUrl` property is not null.
  bool get hasNetworkUrl => networkUrl != null;

  /// Indicates whether the `file` property is not null.
  bool get hasFile => file != null;

  /// Indicates whether the `assetPath` property is not null.
  bool get hasAssetPath => assetPath != null;

  /// A future that retrieves the image data as a `Uint8List` from the appropriate source
  /// based on the `EditorImageType`.
  Future<Uint8List> get safeByteArray {
    switch (type) {
      case EditorImageType.memory:
        return Future.value(byteArray!);
      case EditorImageType.asset:
        return loadAssetImageAsUint8List(assetPath!);
      case EditorImageType.file:
        return readFileAsUint8List(file!);
      case EditorImageType.network:
        return fetchImageAsUint8List(networkUrl!);
    }
  }

  /// Returns the type of the image source, determined by the available properties.
  EditorImageType get type {
    if (hasBytes) {
      return EditorImageType.memory;
    } else if (hasFile) {
      return EditorImageType.file;
    } else if (hasNetworkUrl) {
      return EditorImageType.network;
    } else {
      return EditorImageType.asset;
    }
  }
}

/// Flutter EditorImageType Enum Documentation
///
/// The `EditorImageType` enum represents different types of image sources
/// that can be used with the `EditorImage` class. It specifies whether the
/// image is loaded from memory, a file, a network URL, or an asset.
///
/// Usage:
///
/// ```dart
/// EditorImageType imageType = EditorImageType.network;
/// ```
///
/// Enum Values:
///
/// - `file`: Represents an image loaded from a file.
///
/// - `network`: Represents an image loaded from a network URL.
///
/// - `memory`: Represents an image loaded from memory (byte array).
///
/// - `asset`: Represents an image loaded from an asset path.
///
/// Example Usage:
///
/// ```dart
/// EditorImageType imageType = EditorImageType.network;
///
/// switch (imageType) {
///   case EditorImageType.file:
///     // Handle image loaded from file.
///     break;
///   case EditorImageType.network:
///     // Handle image loaded from network URL.
///     break;
///   case EditorImageType.memory:
///     // Handle image loaded from memory (byte array).
///     break;
///   case EditorImageType.asset:
///     // Handle image loaded from asset path.
///     break;
/// }
/// ```
///
/// Please refer to the documentation of individual enum values for more details.
enum EditorImageType { file, network, memory, asset }
