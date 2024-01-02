import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/models/editor_image.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:pro_image_editor/widgets/auto_image.dart';
import 'package:mockito/annotations.dart';

import '../fake/fake_image.dart';
import 'auto_image_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EditorImage>()])
void main() {
  final mockEditorImage = MockEditorImage();

  group('AutoImage Widget Tests', () {
    testWidgets('displays image from memory', (WidgetTester tester) async {
      when(mockEditorImage.type).thenReturn(EditorImageType.memory);
      when(mockEditorImage.byteArray).thenReturn(fakeMemoryImage);

      await tester.pumpWidget(
        AutoImage(
          mockEditorImage,
          designMode: ImageEditorDesignModeE.material,
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays image from file', (WidgetTester tester) async {
      when(mockEditorImage.type).thenReturn(EditorImageType.file);
      when(mockEditorImage.file).thenReturn(fakeFileImage);

      await tester.pumpWidget(
        AutoImage(
          mockEditorImage,
          designMode: ImageEditorDesignModeE.material,
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays image from network', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockEditorImage.type).thenReturn(EditorImageType.network);
        when(mockEditorImage.networkUrl).thenReturn(fakeNetworkImage);

        await tester.pumpWidget(
          AutoImage(
            mockEditorImage,
            designMode: ImageEditorDesignModeE.material,
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
