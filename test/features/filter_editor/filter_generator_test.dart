import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/filter_editor/types/filter_state.dart';
import 'package:pro_image_editor/features/filter_editor/widgets/filter_generator.dart';
import 'package:pro_image_editor/features/tune_editor/models/tune_adjustment_matrix.dart';

// A darken matrix (scale RGB by 0.8).
const _matrixDarken = <double>[
  0.8, 0, 0, 0, 0, //
  0, 0.8, 0, 0, 0, //
  0, 0, 0.8, 0, 0, //
  0, 0, 0, 1, 0, //
];

List<ColorFilterLayer> _colorFilterLayers(WidgetTester tester) =>
    tester.layers.whereType<ColorFilterLayer>().toList();

bool _generatorIsDirty(WidgetTester tester) =>
    tester.element(find.byType(ColorFilterGenerator)).dirty;

Future<void> _pumpGenerator(
  WidgetTester tester, {
  List<List<double>> filters = const [],
  List<TuneAdjustmentMatrix> tuneAdjustments = const [],
  List<FilterState>? filterStates,
  ValueNotifier<Duration>? playTimeNotifier,
}) {
  return tester.pumpWidget(
    ColorFilterGenerator(
      filters: filters,
      tuneAdjustments: tuneAdjustments,
      filterStates: filterStates,
      playTimeNotifier: playTimeNotifier,
      child: const _MountProbe(),
    ),
  );
}

void main() {
  group(ColorFilterGenerator, () {
    setUp(() => _MountProbe.initCount = 0);

    group('paint', () {
      testWidgets('adds no ColorFilterLayer when no filter is set', (
        tester,
      ) async {
        await _pumpGenerator(tester);

        expect(_colorFilterLayers(tester), isEmpty);
      });

      testWidgets('adds a ColorFilterLayer for a filter', (tester) async {
        await _pumpGenerator(tester, filters: [_matrixDarken]);

        final layers = _colorFilterLayers(tester);
        expect(layers, hasLength(1));
        expect(
          layers.single.colorFilter,
          equals(const ColorFilter.matrix(_matrixDarken)),
        );
      });

      testWidgets('adds a ColorFilterLayer for a tune adjustment', (
        tester,
      ) async {
        await _pumpGenerator(
          tester,
          tuneAdjustments: [
            TuneAdjustmentMatrix(id: 'x', value: 1, matrix: _matrixDarken),
          ],
        );

        expect(_colorFilterLayers(tester), hasLength(1));
      });
    });

    group('playback', () {
      late ValueNotifier<Duration> playTime;

      setUp(() => playTime = ValueNotifier(Duration.zero));
      tearDown(() => playTime.dispose());

      testWidgets('does not rebuild on a tick when no filter is set', (
        tester,
      ) async {
        await _pumpGenerator(
          tester,
          filterStates: const [],
          playTimeNotifier: playTime,
        );

        playTime.value = const Duration(seconds: 1);

        expect(_generatorIsDirty(tester), isFalse);
        await tester.pump();
        expect(_colorFilterLayers(tester), isEmpty);
      });

      testWidgets('does not rebuild on a tick for an untimed filter', (
        tester,
      ) async {
        await _pumpGenerator(
          tester,
          filters: [_matrixDarken],
          filterStates: [
            FilterState(name: 'darken', matrices: [_matrixDarken]),
          ],
          playTimeNotifier: playTime,
        );

        playTime.value = const Duration(seconds: 1);

        expect(_generatorIsDirty(tester), isFalse);
      });

      testWidgets('rebuilds on a tick during a filter enter transition', (
        tester,
      ) async {
        await _pumpGenerator(
          tester,
          filters: [_matrixDarken],
          filterStates: [
            FilterState(
              name: 'darken',
              matrices: [_matrixDarken],
              startTime: const Duration(seconds: 1),
              endTime: const Duration(seconds: 3),
              enterDuration: const Duration(seconds: 1),
            ),
          ],
          playTimeNotifier: playTime,
        );

        playTime.value = const Duration(milliseconds: 1500);

        expect(_generatorIsDirty(tester), isTrue);
      });

      testWidgets(
        'applies a timed filter only inside its range without remounting '
        'the child',
        (tester) async {
          await _pumpGenerator(
            tester,
            filters: [_matrixDarken],
            filterStates: [
              FilterState(
                name: 'darken',
                matrices: [_matrixDarken],
                startTime: const Duration(seconds: 1),
                endTime: const Duration(seconds: 2),
              ),
            ],
            playTimeNotifier: playTime,
          );
          final probe = tester.state(find.byType(_MountProbe));
          expect(_colorFilterLayers(tester), isEmpty);

          playTime.value = const Duration(milliseconds: 1500);
          await tester.pump();

          final layers = _colorFilterLayers(tester);
          expect(layers, hasLength(1));
          expect(
            layers.single.colorFilter,
            equals(const ColorFilter.matrix(_matrixDarken)),
          );

          playTime.value = const Duration(seconds: 3);
          await tester.pump();

          expect(_colorFilterLayers(tester), isEmpty);
          expect(tester.state(find.byType(_MountProbe)), same(probe));
          expect(_MountProbe.initCount, equals(1));
        },
      );

      testWidgets('applies a timed tune adjustment only inside its range', (
        tester,
      ) async {
        await _pumpGenerator(
          tester,
          tuneAdjustments: [
            TuneAdjustmentMatrix(
              id: 'x',
              value: 1,
              matrix: _matrixDarken,
              startTime: const Duration(seconds: 1),
              endTime: const Duration(seconds: 2),
            ),
          ],
          filterStates: const [],
          playTimeNotifier: playTime,
        );
        expect(_colorFilterLayers(tester), isEmpty);

        playTime.value = const Duration(milliseconds: 1500);
        await tester.pump();
        expect(_colorFilterLayers(tester), hasLength(1));

        playTime.value = const Duration(seconds: 3);
        await tester.pump();
        expect(_colorFilterLayers(tester), isEmpty);
      });

      testWidgets('recomputes the matrix when the notifier is replaced', (
        tester,
      ) async {
        final filters = [_matrixDarken];
        final filterStates = [
          FilterState(
            name: 'darken',
            matrices: [_matrixDarken],
            startTime: const Duration(seconds: 1),
            endTime: const Duration(seconds: 2),
          ),
        ];
        await _pumpGenerator(
          tester,
          filters: filters,
          filterStates: filterStates,
          playTimeNotifier: playTime,
        );
        expect(_colorFilterLayers(tester), isEmpty);

        final otherPlayTime = ValueNotifier(const Duration(milliseconds: 1500));
        addTearDown(otherPlayTime.dispose);
        await _pumpGenerator(
          tester,
          filters: filters,
          filterStates: filterStates,
          playTimeNotifier: otherPlayTime,
        );

        expect(_colorFilterLayers(tester), hasLength(1));
      });

      testWidgets('recomputes the matrix when the filter states change', (
        tester,
      ) async {
        final filters = [_matrixDarken];
        await _pumpGenerator(
          tester,
          filters: filters,
          filterStates: const [],
          playTimeNotifier: playTime,
        );
        expect(_colorFilterLayers(tester), isEmpty);

        await _pumpGenerator(
          tester,
          filters: filters,
          filterStates: [
            FilterState(name: 'darken', matrices: [_matrixDarken]),
          ],
          playTimeNotifier: playTime,
        );

        expect(_colorFilterLayers(tester), hasLength(1));
      });
    });
  });
}

/// Stands in for the video player and counts how often it is mounted.
class _MountProbe extends StatefulWidget {
  const _MountProbe();

  static int initCount = 0;

  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    _MountProbe.initCount++;
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF00FF00),
      child: SizedBox(width: 10, height: 10),
    );
  }
}
