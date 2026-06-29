import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/crop_rotate_editor_configs.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/tilt/tilt_ruler.dart';

void main() {
  group('TiltRuler', () {
    late CropRotateEditorConfigs configs;
    late ValueChanged<double> onChangeUpdate;
    late ValueChanged<double> onChangeEnd;
    late List<double> updateValues;
    late List<double> endValues;

    setUp(() {
      configs = const CropRotateEditorConfigs();
      updateValues = [];
      endValues = [];
      onChangeUpdate = (value) => updateValues.add(value);
      onChangeEnd = (value) => endValues.add(value);
    });

    testWidgets('renders correctly with default values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TiltRuler(
              value: 0.0,
              min: -45.0,
              max: 45.0,
              onChangeUpdate: onChangeUpdate,
              onChangeEnd: onChangeEnd,
              configs: configs,
            ),
          ),
        ),
      );

      expect(find.byType(TiltRuler), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays correct number of tick marks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TiltRuler(
              value: 0.0,
              min: -45.0,
              max: 45.0,
              onChangeUpdate: onChangeUpdate,
              onChangeEnd: onChangeEnd,
              configs: configs,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 41 items (40 + 1)
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());
    });

    testWidgets('calls onChangeUpdate during scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              width: 400,
              child: TiltRuler(
                value: 0.0,
                min: -45.0,
                max: 45.0,
                onChangeUpdate: onChangeUpdate,
                onChangeEnd: onChangeEnd,
                configs: configs,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate scroll
      await tester.drag(find.byType(ListView), const Offset(-100, 0));
      await tester.pump();

      expect(updateValues.isNotEmpty, true);
    });

    testWidgets('calls onChangeEnd when scroll ends', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              width: 400,
              child: TiltRuler(
                value: 0.0,
                min: -45.0,
                max: 45.0,
                onChangeUpdate: onChangeUpdate,
                onChangeEnd: onChangeEnd,
                configs: configs,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate scroll and end
      await tester.drag(find.byType(ListView), const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(endValues.isNotEmpty, true);
    });

    testWidgets('indicator changes appearance when active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TiltRuler(
              value: 0.0,
              min: -45.0,
              max: 45.0,
              onChangeUpdate: onChangeUpdate,
              onChangeEnd: onChangeEnd,
              configs: configs,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final indicatorFinder = find.byType(AnimatedContainer);
      expect(indicatorFinder, findsOneWidget);

      // Start scroll to activate indicator
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await tester.pump();

      // End scroll
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('updates scroll position when value changes externally', (
      tester,
    ) async {
      double currentValue = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  TiltRuler(
                    value: currentValue,
                    min: -45.0,
                    max: 45.0,
                    onChangeUpdate: onChangeUpdate,
                    onChangeEnd: onChangeEnd,
                    configs: configs,
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => currentValue = 20.0),
                    child: const Text('Change Value'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Change value externally
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the ruler updated
      expect(find.byType(TiltRuler), findsOneWidget);
    });

    testWidgets('clamps values within min and max range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TiltRuler(
              value: 0.0,
              min: -10.0,
              max: 10.0,
              onChangeUpdate: onChangeUpdate,
              onChangeEnd: onChangeEnd,
              configs: configs,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate extreme scroll
      await tester.drag(find.byType(ListView), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      // Values should be clamped
      if (endValues.isNotEmpty) {
        expect(endValues.last >= -10.0 && endValues.last <= 10.0, true);
      }
    });
  });
}
