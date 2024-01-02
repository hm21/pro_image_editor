import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/editor_image.dart';

import '../fake/fake_image.dart';

void main() {
  group('EditorImage', () {
    test('Constructor should initialize properties correctly', () {
      final Uint8List byteArray = fakeMemoryImage;
      final File file = fakeFileImage;
      const String networkUrl = fakeNetworkImage;
      const String assetPath = 'assets/image.png';

      final EditorImage image = EditorImage(
        byteArray: byteArray,
        file: file,
        networkUrl: networkUrl,
        assetPath: assetPath,
      );

      expect(image.byteArray, byteArray);
      expect(image.file, file);
      expect(image.networkUrl, networkUrl);
      expect(image.assetPath, assetPath);
    });

    test('Constructor should throw an error if all properties are null', () {
      expect(
        () => EditorImage(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('hasBytes should return true when byteArray is not null', () {
      final Uint8List byteArray = fakeMemoryImage;
      final EditorImage image = EditorImage(byteArray: byteArray);
      expect(image.hasBytes, isTrue);
    });

    test('type should return the correct EditorImageType', () {
      final Uint8List byteArray = fakeMemoryImage;
      final File file = fakeFileImage;
      const String networkUrl = fakeNetworkImage;
      const String assetPath = 'assets/image.png';

      expect(
        EditorImage(byteArray: byteArray).type,
        equals(EditorImageType.memory),
      );

      expect(
        EditorImage(file: file).type,
        equals(EditorImageType.file),
      );

      expect(
        const EditorImage(networkUrl: networkUrl).type,
        equals(EditorImageType.network),
      );

      expect(
        const EditorImage(assetPath: assetPath).type,
        equals(EditorImageType.asset),
      );
    });

    test('safeByteArray should return the correct data', () async {
      final Uint8List byteArray = Uint8List.fromList(fakeMemoryImage);

      final EditorImage memoryImage = EditorImage(byteArray: byteArray);

      final Uint8List memoryData = await memoryImage.safeByteArray;
      expect(memoryData, fakeMemoryImage);
    });
  });
}
