// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Project imports:
import 'package:pro_image_editor/utils/converters.dart';
import '../fake/fake_image.dart';

void main() {
  group('converters tests', () {
    test('fetchImageAsUint8List', () async {
      await mockNetworkImagesFor(() async {
        final Uint8List imageBytes =
            await fetchImageAsUint8List(fakeNetworkImage);

        expect(imageBytes, isNotNull);
      });
    });

    test('readFileAsUint8List', () async {
      final Uint8List fileBytes = await readFileAsUint8List(fakeFileImage);

      expect(fileBytes, isNotNull);
    });
  });
}
