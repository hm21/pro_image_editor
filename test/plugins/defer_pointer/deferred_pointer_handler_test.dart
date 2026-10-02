import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/plugins/defer_pointer/defer_pointer.dart';

void main() {
  group(DeferredPointerHandler, () {
    /// Two deferred children stacked on the same spot. The top one is
    /// registered last, so the handler tests it first.
    Future<List<String>> tapStack(
      WidgetTester tester, {
      required bool ignoreTop,
    }) async {
      final taps = <String>[];

      Widget target(String name) => DeferPointer(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => taps.add(name),
          child: const SizedBox(width: 100, height: 100),
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: DeferredPointerHandler(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    target('bottom'),
                    IgnorePointer(ignoring: ignoreTop, child: target('top')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(tester.getCenter(find.byType(Stack)));
      return taps;
    }

    testWidgets('delivers the pointer to the topmost deferred child', (
      tester,
    ) async {
      expect(await tapStack(tester, ignoreTop: false), equals(['top']));
    });

    testWidgets('skips a deferred child under an ignoring IgnorePointer', (
      tester,
    ) async {
      expect(await tapStack(tester, ignoreTop: true), equals(['bottom']));
    });
  });
}
