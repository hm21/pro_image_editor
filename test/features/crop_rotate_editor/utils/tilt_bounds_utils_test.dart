import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/utils/tilt_bounds_utils.dart';

/// Returns `true` if [p] lies inside (or on) the convex polygon [poly].
bool _pointInConvex(List<Offset> poly, Offset p) {
  int sign = 0;
  for (int i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final cross = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
    if (cross.abs() < 1e-6) continue;
    final s = cross > 0 ? 1 : -1;
    if (sign == 0) {
      sign = s;
    } else if (s != sign) {
      return false;
    }
  }
  return true;
}

/// Rebuilds the screen-space image quad for [result] and checks that every
/// crop corner (centered at the origin) is contained.
void _expectCropInsideQuad(
  List<Offset> baseTiltCorners,
  Size cropSize,
  TiltFitResult result,
) {
  // q_i = scale * (B_i + translate)
  final quad = [
    for (final b in baseTiltCorners) (b + result.translate) * result.scale,
  ];
  final hw = cropSize.width / 2;
  final hh = cropSize.height / 2;
  final corners = [
    Offset(-hw, -hh),
    Offset(hw, -hh),
    Offset(hw, hh),
    Offset(-hw, hh),
  ];
  for (final c in corners) {
    expect(
      _pointInConvex(quad, c),
      isTrue,
      reason: 'crop corner $c must stay inside the tilted image quad $quad',
    );
  }
}

void main() {
  group('fitCropInsideTiltedImage', () {
    // A 400x300 image, corners relative to its center.
    final imageCorners = <Offset>[
      const Offset(-200, -150),
      const Offset(200, -150),
      const Offset(200, 150),
      const Offset(-200, 150),
    ];

    test('untilted crop smaller than image fits at the manual scale', () {
      final result = fitCropInsideTiltedImage(
        baseTiltCorners: imageCorners,
        cropSize: const Size(200, 150),
        minScale: 1,
        maxScale: 7,
        currentTranslate: Offset.zero,
      );

      expect(result.fits, isTrue);
      expect(result.scale, closeTo(1.0, 1e-6));
      _expectCropInsideQuad(imageCorners, const Size(200, 150), result);
    });

    test('never zooms out below the manual scale', () {
      final result = fitCropInsideTiltedImage(
        baseTiltCorners: imageCorners,
        cropSize: const Size(200, 150),
        minScale: 2,
        maxScale: 7,
        currentTranslate: Offset.zero,
      );

      expect(result.fits, isTrue);
      expect(result.scale, greaterThanOrEqualTo(2.0));
    });

    test('auto-zooms in so a near-full crop stays inside a tilted image', () {
      // Simulate a perspective tilt: a trapezoid whose top edge is narrower.
      final tilted = <Offset>[
        const Offset(-150, -150), // top-left pulled in
        const Offset(150, -150), // top-right pulled in
        const Offset(200, 150), // bottom-right
        const Offset(-200, 150), // bottom-left
      ];
      const cropSize = Size(360, 280);

      final result = fitCropInsideTiltedImage(
        baseTiltCorners: tilted,
        cropSize: cropSize,
        minScale: 1,
        maxScale: 7,
        currentTranslate: Offset.zero,
      );

      expect(result.fits, isTrue);
      // The plain trapezoid at scale 1 can't cover the wide crop, so it must
      // have zoomed in.
      expect(result.scale, greaterThan(1.0));
      _expectCropInsideQuad(tilted, cropSize, result);
    });

    test('reports failure when even maxScale cannot cover the crop', () {
      // Extremely degenerate (near-collapsed) quad that can never contain the
      // crop regardless of uniform scaling.
      final degenerate = <Offset>[
        const Offset(-100, -1),
        const Offset(100, -1),
        const Offset(100, 1),
        const Offset(-100, 1),
      ];

      final result = fitCropInsideTiltedImage(
        baseTiltCorners: degenerate,
        cropSize: const Size(200, 200),
        minScale: 1,
        maxScale: 2,
        currentTranslate: Offset.zero,
      );

      expect(result.fits, isFalse);
    });
  });
}
