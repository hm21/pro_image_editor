import 'dart:typed_data';

import '/core/platform/io/io_helper.dart';
import '/shared/utils/converters.dart';
import '/shared/utils/file_constructor_utils.dart';

/// Represents an audio source used in the editor.
///
/// Can be created from bytes, a local file, a network URL, or an asset path.
class EditorAudio {
  /// Creates an instance of the `EditorAudio` class with the specified
  /// properties.
  ///
  /// At least one of `byteArray`, `file`, `networkUrl`, or `assetPath`
  /// must not be null.
  EditorAudio({this.bytes, this.networkUrl, this.assetPath, dynamic file})
    : file = file == null ? null : ensureFileInstance(file),
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

  /// Returns the type of the audio source, determined by the available
  /// properties.
  EditorAudioType get type {
    if (hasFile) {
      return EditorAudioType.file;
    } else if (hasBytes) {
      return EditorAudioType.memory;
    } else if (hasNetworkUrl) {
      return EditorAudioType.network;
    } else {
      return EditorAudioType.asset;
    }
  }

  /// A future that retrieves a file path for the audio.
  ///
  /// If the audio is already a file, returns its path directly.
  /// Otherwise, writes the audio data to a temporary file and returns
  /// that path.
  ///
  /// The [fileExtension] parameter specifies the file extension for the
  /// temporary file (e.g., '.mp3', '.wav'). If not provided, it will be
  /// extracted from the asset path or network URL. Defaults to '.mp3' if
  /// extraction fails.
  Future<String> safeFilePath({String? fileExtension}) async {
    switch (type) {
      case EditorAudioType.file:
        return file!.path;
      case EditorAudioType.memory:
        return _writeBytesToTempFile(bytes!, fileExtension ?? '.mp3');
      case EditorAudioType.asset:
        final ext = fileExtension ?? _extractExtension(assetPath!) ?? '.mp3';
        final assetBytes = await loadAssetImageAsUint8List(assetPath!);
        bytes = assetBytes;
        return _writeBytesToTempFile(assetBytes, ext);
      case EditorAudioType.network:
        final ext = fileExtension ?? _extractExtension(networkUrl!) ?? '.mp3';
        final networkBytes = await fetchImageAsUint8List(networkUrl!);
        bytes = networkBytes;
        return _writeBytesToTempFile(networkBytes, ext);
    }
  }

  /// Extracts the file extension from a path or URL.
  /// Returns null if no extension could be extracted.
  String? _extractExtension(String path) {
    final uri = Uri.tryParse(path);
    final pathSegment = uri?.pathSegments.lastOrNull ?? path;
    final lastDot = pathSegment.lastIndexOf('.');
    if (lastDot != -1 && lastDot < pathSegment.length - 1) {
      return pathSegment.substring(lastDot);
    }
    return null;
  }

  Future<String> _writeBytesToTempFile(
    Uint8List data,
    String fileExtension,
  ) async {
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File(
      '${tempDir.path}/editor_audio_$timestamp$fileExtension',
    );
    await tempFile.writeAsBytes(data);
    return tempFile.path;
  }
}

/// The `EditorAudioType` enum represents different types of audio sources
/// that can be used with the `EditorAudio` class.
enum EditorAudioType {
  /// Represents audio loaded from a file.
  file,

  /// Represents audio loaded from a network URL.
  network,

  /// Represents audio loaded from memory (byte array).
  memory,

  /// Represents audio loaded from an asset path.
  asset,
}
