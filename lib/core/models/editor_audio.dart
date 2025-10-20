import 'dart:typed_data';

import '/shared/utils/file_constructor_utils.dart';
import '../platform/io/io_helper.dart';

/// Represents an audio source used in the editor.
///
/// Can be created from bytes, a local file, a network URL, or an asset path.
class EditorAudio {
  /// Creates an instance of the `EditorAudio` class with the specified
  /// properties.
  ///
  /// At least one of `byteArray`, `file`, `networkUrl`, or `assetPath`
  /// must not be null.
  EditorAudio({
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

  /// Creates an [EditorAudio] from raw memory bytes.
  factory EditorAudio.memory(Uint8List bytes) {
    return EditorAudio(bytes: bytes);
  }

  /// Creates an [EditorAudio] from a network URL.
  factory EditorAudio.network(String networkUrl) {
    return EditorAudio(networkUrl: networkUrl);
  }

  /// Creates an [EditorAudio] from an asset path.
  factory EditorAudio.asset(String assetPath) {
    return EditorAudio(assetPath: assetPath);
  }

  /// Creates an [EditorAudio] from a local file.
  factory EditorAudio.file(dynamic file) {
    return EditorAudio(file: file);
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
