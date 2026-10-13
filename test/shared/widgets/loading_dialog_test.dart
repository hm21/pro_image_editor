import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
  );

  final dialog = LoadingDialog.instance;

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return hostContext;
  }

  testWidgets('is no longer active once it starts to fade out', (tester) async {
    final context = await pumpHost(tester);
    dialog.show(context, message: 'first', configs: configs);
    await tester.pumpAndSettle();

    dialog.hide();
    expect(dialog.hasActiveOverlay, isFalse);

    await tester.pump();
    expect(find.text('first'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
  });

  testWidgets('a dialog shown during a fade-out stays on screen', (
    tester,
  ) async {
    final context = await pumpHost(tester);
    dialog.show(context, message: 'first', configs: configs);
    await tester.pumpAndSettle();

    dialog.hide();
    await tester.pump();
    dialog.show(context, message: 'second', configs: configs);
    await tester.pumpAndSettle();

    expect(dialog.hasActiveOverlay, isTrue);
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);

    dialog.hide();
    await tester.pumpAndSettle();
  });
}
