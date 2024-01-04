import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_rotate_editor_helper.dart';

import '../../../fake/fake_image.dart';

void main() {
  group('Image Crop Tests', () {
    final EditActionDetails editAction = EditActionDetails();
    final Rect cropRect =
        Rect.fromPoints(const Offset(10, 10), const Offset(50, 50));
    final ExtendedImage extendedImage = ExtendedImage(
      image: MemoryImage(fakeMemoryImage),
    );

    test('Test cropImage with Dart Library', () async {
      final croppedImage = await cropImageDataWithDartLibrary(
        rawImage: fakeMemoryImage,
        editAction: editAction,
        cropRect: cropRect,
        imageWidth: 100,
        imageHeight: 100,
        extendedImage: extendedImage,
        imageProvider: MemoryImage(fakeMemoryImage),
      );
      expect(croppedImage, isNotNull);
    });

    /* test('Test cropImage with Native Library', () async {
      final croppedImage = await cropImageDataWithNativeLibrary(
        rawImage: fakeMemoryImage,
        editAction: editAction,
        cropRect: cropRect,
        imageWidth: 100,
        imageHeight: 100,
        isExtendedResizeImage: false,
      );
      expect(croppedImage, isNotNull);
    }); */
  });
}
