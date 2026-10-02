import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/plugins/defer_pointer/defer_pointer.dart';

void main() {
  group(DeferredPointerHandler, () {
    late List<String> taps;

    setUp(() => taps = []);

    Widget target(String name) => DeferPointer(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => taps.add(name),
        child: const SizedBox(width: 100, height: 100),
      ),
    );

    /// Two deferred children stacked on the same spot, the top one wrapped in
    /// [wrapTop].
    Future<List<String>> tapStack(
      WidgetTester tester, {
      Widget Function(Widget child)? wrapTop,
      Key bottomKey = const ValueKey('bottom'),
    }) async {
      final top = target('top');
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
                    KeyedSubtree(key: bottomKey, child: target('bottom')),
                    wrapTop?.call(top) ?? top,
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
      expect(
        await tapStack(
          tester,
          wrapTop: (child) => IgnorePointer(ignoring: false, child: child),
        ),
        equals(['top']),
      );
    });

    testWidgets('skips a deferred child under an ignoring IgnorePointer', (
      tester,
    ) async {
      expect(
        await tapStack(tester, wrapTop: (child) => IgnorePointer(child: child)),
        equals(['bottom']),
      );
    });

    testWidgets('skips a deferred child under an absorbing AbsorbPointer', (
      tester,
    ) async {
      expect(
        await tapStack(tester, wrapTop: (child) => AbsorbPointer(child: child)),
        equals(['bottom']),
      );
    });

    testWidgets('skips a deferred child under an Offstage', (tester) async {
      expect(
        await tapStack(tester, wrapTop: (child) => Offstage(child: child)),
        equals(['bottom']),
      );
    });

    testWidgets('tests a re-attached deferred child in paint order', (
      tester,
    ) async {
      await tapStack(tester);
      taps.clear();

      // A new key re-attaches the bottom child after the top one.
      expect(
        await tapStack(tester, bottomKey: const ValueKey('bottom-again')),
        equals(['top']),
      );
    });
  });
}
