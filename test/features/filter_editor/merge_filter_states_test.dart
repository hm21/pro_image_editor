import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/filter_editor/types/filter_state.dart';
import 'package:pro_image_editor/features/filter_editor/utils/combine_color_matrix_utils.dart';
import 'package:pro_image_editor/features/filter_editor/utils/merge_filter_states.dart';

// A darken matrix (scale RGB by 0.8).
const _matrixDarken = <double>[
  0.8, 0, 0, 0, 0, //
  0, 0.8, 0, 0, 0, //
  0, 0, 0.8, 0, 0, //
  0, 0, 0, 1, 0, //
];

// A brightness-offset matrix (+10 on RGB).
const _matrixOffset = <double>[
  1, 0, 0, 0, 10, //
  0, 1, 0, 0, 10, //
  0, 0, 1, 0, 10, //
  0, 0, 0, 1, 0, //
];

// A contrast-ish tune matrix.
const _matrixTune = <double>[
  1.2, 0, 0, 0, -25, //
  0, 1.2, 0, 0, -25, //
  0, 0, 1.2, 0, -25, //
  0, 0, 0, 1, 0, //
];

void _expectMatrixClose(List<double> a, List<double> b) {
  expect(a.length, b.length);
  for (var i = 0; i < a.length; i++) {
    expect(a[i], closeTo(b[i], 1e-9), reason: 'index $i');
  }
}

void main() {
  group('mergeFilterStates', () {
    test('flattens to a single state whose matrix composes all sources', () {
      final f1 = FilterState(name: 'a', matrices: [_matrixDarken]);
      final f2 = FilterState(name: 'b', matrices: [_matrixOffset]);

      final merged = mergeFilterStates([f1, f2]);
      expect(merged.matrices.length, 1);

      // Rendering the merged filter (with tune on top) is byte-identical to
      // rendering the original stack.
      final full = mergeColorMatrices(
        filterList: [_matrixDarken, _matrixOffset],
        tuneAdjustmentList: [_matrixTune],
      );
      final afterMerge = mergeColorMatrices(
        filterList: merged.matrices,
        tuneAdjustmentList: [_matrixTune],
      );
      _expectMatrixClose(afterMerge, full);
    });

    test('handles states that already carry multiple matrices', () {
      final f1 = FilterState(
        name: 'a',
        matrices: [_matrixDarken, _matrixOffset],
      );
      final f2 = FilterState(name: 'b', matrices: [_matrixOffset]);

      final merged = mergeFilterStates([f1, f2]);
      expect(merged.matrices.length, 1);

      final full = mergeColorMatrices(
        filterList: [_matrixDarken, _matrixOffset, _matrixOffset],
        tuneAdjustmentList: const [],
      );
      _expectMatrixClose(merged.matrices.first, full);
    });

    test('carries over the metadata of every source filter', () {
      final f1 = FilterState(
        name: 'a',
        matrices: [_matrixDarken],
        meta: const {'from': 'a', 'shared': 1},
      );
      final f2 = FilterState(
        name: 'b',
        matrices: [_matrixOffset],
        meta: const {'from': 'b', 'shared': 2},
      );

      final merged = mergeFilterStates([f1, f2]);

      // All keys preserved; later filters win on conflicts.
      expect(merged.meta, {'from': 'b', 'shared': 2});
    });
  });

  group('canMergeFilterStates gating', () {
    test('true for two or more timeline-free filters', () {
      expect(
        canMergeFilterStates([
          FilterState(name: 'a', matrices: [_matrixDarken]),
          FilterState(name: 'b', matrices: [_matrixOffset]),
        ]),
        isTrue,
      );
    });

    test('false for fewer than two', () {
      expect(
        canMergeFilterStates([
          FilterState(name: 'a', matrices: [_matrixDarken]),
        ]),
        isFalse,
      );
      expect(canMergeFilterStates([]), isFalse);
    });

    test('false when any filter carries video-timeline metadata', () {
      expect(
        canMergeFilterStates([
          FilterState(name: 'a', matrices: [_matrixDarken]),
          FilterState(
            name: 'b',
            matrices: [_matrixOffset],
            startTime: const Duration(seconds: 1),
          ),
        ]),
        isFalse,
      );
    });
  });
}
