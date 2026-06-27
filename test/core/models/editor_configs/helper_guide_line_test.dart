// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/helper_guide_line.dart';

void main() {
  group('HelperGuideLine.resolvePosition', () {
    const editorSize = Size(400, 800);

    test('returns the raw value for absolute positions', () {
      const guide = HelperGuideLine(axis: Axis.vertical, position: 120);
      expect(guide.resolvePosition(editorSize), 120);
    });

    test('scales a normalized vertical guide by the editor width', () {
      const guide = HelperGuideLine(
        axis: Axis.vertical,
        position: 0.25,
        positionMode: HelperGuidePositionMode.normalized,
      );
      expect(guide.resolvePosition(editorSize), 100);
    });

    test('scales a normalized horizontal guide by the editor height', () {
      const guide = HelperGuideLine(
        axis: Axis.horizontal,
        position: 0.5,
        positionMode: HelperGuidePositionMode.normalized,
      );
      expect(guide.resolvePosition(editorSize), 400);
    });
  });

  group('HelperGuideLine equality', () {
    test('equal guides share a hash code and compare equal', () {
      const a = HelperGuideLine(axis: Axis.vertical, position: 0.5);
      const b = HelperGuideLine(axis: Axis.vertical, position: 0.5);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing axis or position are not equal', () {
      const base = HelperGuideLine(axis: Axis.vertical, position: 0.5);
      expect(
        base == const HelperGuideLine(axis: Axis.horizontal, position: 0.5),
        isFalse,
      );
      expect(
        base == const HelperGuideLine(axis: Axis.vertical, position: 0.25),
        isFalse,
      );
    });
  });
}
