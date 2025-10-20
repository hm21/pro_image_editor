import 'dart:typed_data';

import '/shared/utils/file_constructor_utils.dart';
import '../platform/io/io_helper.dart';

/// Represents an video-clips source used in the editor.
///
/// Can be created from bytes, a local file, a network URL, or an asset path.
class EditorVideoClip {
  /// Creates an instance of the [EditorVideoClip] class with the specified
  /// properties.
  ///
  /// At least one of `byteArray`, `file`, `networkUrl`, or `assetPath`
  /// must not be null.
  EditorVideoClip({
    this.bytes,
    this.networkUrl,
    this.assetPath,
    dynamic file,
  })  : file = file == null ? null : ensureFileInstance(file),
        assert(
          bytes != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not '
          'be null.',
        );

  /// Creates an [EditorVideoClip] from raw memory bytes.
  factory EditorVideoClip.memory(Uint8List bytes) {
    return EditorVideoClip(bytes: bytes);
  }

  /// Creates an [EditorVideoClip] from a network URL.
  factory EditorVideoClip.network(String networkUrl) {
    return EditorVideoClip(networkUrl: networkUrl);
  }

  /// Creates an [EditorVideoClip] from an asset path.
  factory EditorVideoClip.asset(String assetPath) {
    return EditorVideoClip(assetPath: assetPath);
  }

  /// Creates an [EditorVideoClip] from a local file.
  factory EditorVideoClip.file(dynamic file) {
    return EditorVideoClip(file: file);
  }

  /// Creates an [EditorVideoClip] from a local file.
  factory EditorVideoClip.autoSource({
    Uint8List? bytes,
    String? networkUrl,
    String? assetPath,
    dynamic file,
  }) {
    return EditorVideoClip(
      bytes: bytes,
      networkUrl: networkUrl,
      assetPath: assetPath,
      file: file,
    );
  }

  /// A byte array representing the image data.
  Uint8List? bytes;

  /// A `File` object representing the image file.
  final File? file;

  /// A URL string pointing to an image on the internet.
  final String? networkUrl;

  /// A string representing the asset path of an image.
  final String? assetPath;

  /// Indicates whether the `byteArray` property is not null.
  bool get hasBytes => bytes != null;

  /// Indicates whether the `networkUrl` property is not null.
  bool get hasNetworkUrl => networkUrl != null;

  /// Indicates whether the `file` property is not null.
  bool get hasFile => file != null;

  /// Indicates whether the `assetPath` property is not null.
  bool get hasAssetPath => assetPath != null;
}
