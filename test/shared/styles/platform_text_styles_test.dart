import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/enums/design_mode.dart';
import 'package:pro_image_editor/shared/styles/platform_text_styles.dart';

void main() {
  group('platformTextStyle', () {
    testWidgets('returns Cupertino text style for cupertino mode', (
      tester,
    ) async {
      late TextStyle result;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              result = platformTextStyle(
                context,
                ImageEditorDesignMode.cupertino,
              );
              return Container();
            },
          ),
        ),
      );
      final cupertinoStyle = const CupertinoThemeData().textTheme.textStyle;
      expect(result.fontSize, cupertinoStyle.fontSize);
      expect(result.fontFamily, cupertinoStyle.fontFamily);
    });

    testWidgets('returns Material text style for material mode', (
      tester,
    ) async {
      late TextStyle result;
      const initialStyle = TextStyle(fontSize: 30, fontFamily: 'Roboto');
      final theme = ThemeData(
        textTheme: const TextTheme(bodyLarge: initialStyle),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              result = platformTextStyle(
                context,
                ImageEditorDesignMode.material,
              );
              return Container();
            },
          ),
        ),
      );
      expect(result.fontSize, initialStyle.fontSize);
      expect(result.fontFamily, initialStyle.fontFamily);
    });
  });
}
