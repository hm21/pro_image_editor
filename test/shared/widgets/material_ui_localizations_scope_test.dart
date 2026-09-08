import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/shared/widgets/material_ui_localizations_scope.dart';

void main() {
  testWidgets('keeps a host regional MaterialLocalizations instance', (
    WidgetTester tester,
  ) async {
    late MaterialLocalizations localizations;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'GB'),
        supportedLocales: const [Locale('en', 'GB')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: MaterialUiLocalizationsScope(
          child: Builder(
            builder: (context) {
              localizations = MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(localizations, isA<GlobalMaterialLocalizations>());
    expect(localizations.firstDayOfWeekIndex, 1);
  });

  testWidgets('falls back when material_ui localizations are missing', (
    WidgetTester tester,
  ) async {
    late MaterialLocalizations localizations;

    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        builder: (context, _) {
          return MaterialUiLocalizationsScope(
            child: Builder(
              builder: (context) {
                localizations = MaterialLocalizations.of(context);
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );

    expect(localizations, isA<MaterialLocalizations>());
  });

  testWidgets('supplies English material resources for an unsupported locale', (
    WidgetTester tester,
  ) async {
    late MaterialLocalizations localizations;

    await tester.pumpWidget(
      Localizations(
        locale: const Locale('xx'),
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: MaterialUiLocalizationsScope(
          child: Builder(
            key: const ValueKey('unsupported-locale'),
            builder: (context) {
              localizations = MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(localizations, isA<DefaultMaterialLocalizations>());
    expect(
      Localizations.localeOf(
        tester.element(find.byKey(const ValueKey('unsupported-locale'))),
      ),
      const Locale('en'),
    );
  });
}
