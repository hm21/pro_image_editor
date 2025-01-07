// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:http/http.dart' as http;

/// Loads an image asset as a Uint8List.
///
/// This function allows you to load an image asset from the app's assets
/// directory and convert it into a Uint8List for further use.
///
/// Parameters:
/// - `assetPath`: A String representing the asset path of the image to be
/// loaded.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the image data.
///
/// Example Usage:
/// ```dart
/// final Uint8List imageBytes = await loadAssetImageAsUint8List('assets/image.png');
/// ```
Future<Uint8List> loadAssetImageAsUint8List(String assetPath) async {
  // Load the asset as a ByteData
  final ByteData data = await rootBundle.load(assetPath);

  // Convert the ByteData to a Uint8List
  final Uint8List uint8List = data.buffer.asUint8List();

  return uint8List;
}

/// Fetches an image from a network URL as a Uint8List.
///
/// This function allows you to fetch an image from a network URL and convert
/// it into a Uint8List for further use.
///
/// Parameters:
/// - `imageUrl`: A String representing the network URL of the image to be
/// fetched.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the image data.
///
/// Example Usage:
/// ```dart
/// final Uint8List imageBytes = await fetchImageAsUint8List('https://example.com/image.jpg');
/// ```
Future<Uint8List> fetchImageAsUint8List(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    // Convert the response body to a Uint8List
    final Uint8List uint8List = Uint8List.fromList(response.bodyBytes);
    return uint8List;
  } else {
    throw Exception('Failed to load image: $imageUrl');
  }
}

/// Reads a file as a Uint8List.
///
/// This function allows you to read the contents of a file and convert it into
/// a Uint8List for further use.
///
/// Parameters:
/// - `file`: A File object representing the image file to be read.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the file's data.
///
/// Example Usage:
/// ```dart
/// final File imageFile = File('path/to/image.png');
/// final Uint8List fileBytes = await readFileAsUint8List(imageFile);
/// ```
Future<Uint8List> readFileAsUint8List(File file) async {
  try {
    // Read the file as bytes
    final Uint8List uint8List = await file.readAsBytes();

    return uint8List;
  } catch (e) {
    throw Exception('Failed to read file: ${file.path}');
  }
}
