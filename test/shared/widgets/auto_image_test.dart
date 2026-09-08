// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/auto_image.dart';

import '../../mock/mock_image.dart';
import 'auto_image_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EditorImage>()])
void main() {
  final mockEditorImage = MockEditorImage();

  group('AutoImage Widget Tests', () {
    testWidgets('displays image from memory', (WidgetTester tester) async {
      when(mockEditorImage.type).thenReturn(EditorImageType.memory);
      when(mockEditorImage.byteArray).thenReturn(mockMemoryImage);

      await tester.pumpWidget(
        AutoImage(mockEditorImage, configs: const ProImageEditorConfigs()),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays image from network', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        when(mockEditorImage.type).thenReturn(EditorImageType.network);
        when(mockEditorImage.networkUrl).thenReturn(mockNetworkImage);

        await tester.pumpWidget(
          AutoImage(mockEditorImage, configs: const ProImageEditorConfigs()),
        );

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
