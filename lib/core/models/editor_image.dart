// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/platform/io/io_helper.dart';
import '/shared/utils/converters.dart';
import '/shared/utils/file_constructor_utils.dart';

/// Flutter EditorImage Class Documentation
///
/// The `EditorImage` class represents an image with multiple sources, including
/// bytes, file, network URL, and asset path. It provides flexibility for
/// loading images from various sources in a Flutter application.
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
/// - `networkUrl` (optional): A URL string pointing to an image on the
///   internet.
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
/// - `safeByteArray`: A future that retrieves the image data as a `Uint8List`
///   from the appropriate source based on the `EditorImageType`.
///
/// - `type`: Returns the type of the image source, determined by the available
///   properties.
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
/// Please refer to the documentation of individual properties and methods for
/// more details.
class EditorImage {
  /// Creates an instance of the `EditorImage` class with the specified
  /// properties.
  ///
  /// At least one of `byteArray`, `file`, `networkUrl`, or `assetPath`
  /// must not be null.
  EditorImage({
    this.byteArray,
    this.networkUrl,
    this.networkHeaders,
    this.assetPath,
    dynamic file,
  })  : file = file == null ? null : ensureFileInstance(file),
        assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not '
          'be null.',
        );

  /// A byte array representing the image data.
  Uint8List? byteArray;

  /// A `File` object representing the image file.
  final File? file;

  /// A URL string pointing to an image on the internet.
  final String? networkUrl;

  /// Optional HTTP headers to use when fetching the network image.
  final Map<String, String>? networkHeaders;

  /// A string representing the asset path of an image.
  final String? assetPath;

  /// Indicates whether the `byteArray` property is not null.
  bool get hasBytes => byteArray != null;

  /// Indicates whether the `networkUrl` property is not null.
  bool get hasNetworkUrl => networkUrl != null;

  /// Indicates whether the `file` property is not null.
  bool get hasFile => file != null;

  /// Indicates whether the `assetPath` property is not null.
  bool get hasAssetPath => assetPath != null;

  /// Converts the current `EditorImage` instance to an `ImageProvider`.
  ///
  /// The type of `ImageProvider` returned depends on the `EditorImageType`:
  /// - `EditorImageType.memory`: Returns a `MemoryImage` created from the
  ///   `byteArray`.
  /// - `EditorImageType.asset`: Returns an `AssetImage` created from the
  ///   `assetPath`.
  /// - `EditorImageType.file`: Returns a `FileImage` created from the `file`.
  /// - `EditorImageType.network`: Returns a `NetworkImage` created from the
  ///   `networkUrl`.
  ImageProvider<Object> toImageProvider() {
    switch (type) {
      case EditorImageType.memory:
        return MemoryImage(byteArray!);
      case EditorImageType.asset:
        return AssetImage(assetPath!);
      case EditorImageType.file:
        return FileImage(file! as dynamic);
      case EditorImageType.network:
        return NetworkImage(networkUrl!, headers: networkHeaders);
    }
  }

  /// A future that retrieves the image data as a `Uint8List` from the
  /// appropriate source based on the `EditorImageType`.
  Future<Uint8List> safeByteArray([BuildContext? context]) async {
    Uint8List bytes;
    switch (type) {
      case EditorImageType.memory:
        return byteArray!;
      case EditorImageType.asset:
        bytes = await loadAssetImageAsUint8List(assetPath!);
        break;
      case EditorImageType.file:
        bytes = await readFileAsUint8List(file!);
        break;
      case EditorImageType.network:
        bytes = await fetchImageAsUint8List(
          networkUrl!,
          headers: networkHeaders,
        );
        break;
    }

    if (context != null) {
      if (!context.mounted) return bytes;

      await precacheImage(
        MemoryImage(bytes),
        context,
        size: MediaQuery.sizeOf(context),
      );
    }

    byteArray = bytes;

    return bytes;
  }

  /// Returns the type of the image source, determined by the available
  /// properties.
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is EditorImage &&
        _areUint8ListsEqual(byteArray, other.byteArray) &&
        file?.path == other.file?.path &&
        networkUrl == other.networkUrl &&
        mapEquals(networkHeaders, other.networkHeaders) &&
        assetPath == other.assetPath;
  }

  @override
  int get hashCode {
    return Object.hash(
      _hashUint8List(byteArray),
      file?.path,
      networkUrl,
      networkHeaders,
      assetPath,
    );
  }

  bool _areUint8ListsEqual(Uint8List? a, Uint8List? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _hashUint8List(Uint8List? list) {
    if (list == null) return 0;
    return list.fold(0, (hash, byte) => hash * 31 + byte);
  }

  /// Creates a copy of this [EditorImage] with optional new values for its
  /// fields.
  ///
  /// If a parameter is not provided, the current value from this instance
  /// is used.
  /// - [byteArray]: The new image data as a [Uint8List]. If provided, a
  /// copy is created.
  /// - [file]: The new image file as a [File]. If provided, a new [File]
  /// instance is created with the same path.
  /// - [networkUrl]: The new network URL for the image.
  /// - [assetPath]: The new asset path for the image.
  ///
  /// Returns a new [EditorImage] instance with the updated values.
  EditorImage copyWith({
    Uint8List? byteArray,
    File? file,
    String? networkUrl,
    Map<String, String>? networkHeaders,
    String? assetPath,
  }) {
    final bytes = byteArray ?? this.byteArray;
    final fileHelper = file ?? this.file;
    return EditorImage(
      byteArray: bytes != null ? Uint8List.fromList(bytes) : null,
      file: fileHelper != null ? File(fileHelper.path) : null,
      networkUrl: networkUrl ?? this.networkUrl,
      networkHeaders: networkHeaders ?? this.networkHeaders,
      assetPath: assetPath ?? this.assetPath,
    );
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
/// Please refer to the documentation of individual enum values for more
/// details.
enum EditorImageType {
  /// Represents an image loaded from a file.
  file,

  /// Represents an image loaded from a network URL.
  network,

  /// Represents an image loaded from memory (byte array).
  memory,

  /// Represents an image loaded from an asset path.
  asset
}
