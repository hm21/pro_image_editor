import 'dart:ui';

/// The result of fitting a crop rectangle inside a tilted image quad.
class TiltFitResult {
  /// Creates a [TiltFitResult].
  const TiltFitResult({
    required this.fits,
    required this.scale,
    required this.translate,
  });

  /// Whether the crop rectangle could be kept fully inside the image quad.
  ///
  /// `false` means even at the maximum scale no translation keeps the crop
  /// covered, so the caller should reject the tilt change.
  final bool fits;

  /// The (effective) scale factor to apply.
  final double scale;

  /// The image translation (in unscaled image space) to apply.
  final Offset translate;
}

/// Computes the scale and translation that keep an axis-aligned crop rectangle
/// (centered on the screen) fully inside the convex, perspective-tilted image.
///
/// - [baseTiltCorners]: the four image corners after applying *only* the tilt
///   transform, measured relative to the screen center and in screen-pixel
///   units (i.e. the corners at scale `1`, translation `0`). They are scaled
///   uniformly here to model zooming.
/// - [cropSize]: the size of the (axis-aligned) crop selection.
/// - [minScale]: the lower bound for the scale, i.e. the user's manual zoom.
///   The result never zooms out below this.
/// - [maxScale]: the upper bound for the auto-zoom.
/// - [currentTranslate]: the current image translation; the chosen translation
///   stays as close to it as possible to minimize visible panning.
///
/// The image quad grows monotonically with the scale, so the minimal scale for
/// which a valid translation exists is found via binary search.
TiltFitResult fitCropInsideTiltedImage({
  required List<Offset> baseTiltCorners,
  required Size cropSize,
  required double minScale,
  required double maxScale,
  required Offset currentTranslate,
}) {
  final double hw = cropSize.width / 2;
  final double hh = cropSize.height / 2;

  /// Returns the crop-center (in the centered screen frame) closest to the
  /// target that keeps the crop inside the scaled image quad, or `null` if no
  /// such center exists for [scale].
  Offset? solveCenter(double scale) {
    final poly = [for (final b in baseTiltCorners) b * scale];
    // center = -scale * translate  (see _setOffsetLimits derivation)
    final target = currentTranslate * (-scale);
    return _erodeAndNearest(poly, hw, hh, target);
  }

  final double lowerBound = minScale.clamp(1.0, maxScale).toDouble();

  // 1) Does it already fit at the manual zoom?
  Offset? center = solveCenter(lowerBound);
  if (center != null) {
    return TiltFitResult(
      fits: true,
      scale: lowerBound,
      translate: center / -lowerBound,
    );
  }

  // 2) Can the maximum zoom cover it at all?
  final Offset? maxCenter = solveCenter(maxScale);
  if (maxCenter == null) {
    // Not coverable even at maxScale -> reject (caller reverts the tilt).
    return TiltFitResult(
      fits: false,
      scale: maxScale,
      translate: currentTranslate,
    );
  }

  // 3) Binary-search the minimal scale that still fits.
  double lo = lowerBound;
  double hi = maxScale;
  Offset hiCenter = maxCenter;
  for (int i = 0; i < 26; i++) {
    final double mid = (lo + hi) / 2;
    final Offset? midCenter = solveCenter(mid);
    if (midCenter != null) {
      hi = mid;
      hiCenter = midCenter;
    } else {
      lo = mid;
    }
  }

  return TiltFitResult(fits: true, scale: hi, translate: hiCenter / -hi);
}

/// Erodes the convex polygon [poly] by an axis-aligned rectangle with half
/// extents [hw], [hh] and returns the point of the eroded region closest to
/// [target], or `null` when the eroded region is empty (the rectangle can't
/// fit inside [poly]).
Offset? _erodeAndNearest(
  List<Offset> poly,
  double hw,
  double hh,
  Offset target,
) {
  if (poly.length < 3) return null;

  // Centroid is used to orient the inward edge normals.
  double cx = 0;
  double cy = 0;
  for (final p in poly) {
    cx += p.dx;
    cy += p.dy;
  }
  final centroid = Offset(cx / poly.length, cy / poly.length);

  final normals = <Offset>[];
  final distances = <double>[];

  for (int i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final edge = b - a;
    Offset n = Offset(-edge.dy, edge.dx);
    // Flip the normal so it points towards the polygon interior.
    if ((n.dx * (centroid.dx - a.dx) + n.dy * (centroid.dy - a.dy)) < 0) {
      n = Offset(-n.dx, -n.dy);
    }
    final len = n.distance;
    if (len == 0) continue;
    n = n / len;

    // Erode: shrink the half-plane inward by the rectangle's support width in
    // direction n. Interior constraint becomes n·c >= d'.
    final d = n.dx * a.dx + n.dy * a.dy;
    final dEroded = d + hw * n.dx.abs() + hh * n.dy.abs();
    normals.add(n);
    distances.add(dEroded);
  }

  // Feasibility: clip a large square by all eroded half-planes.
  final double r = _polyExtent(poly) * 4 + 1;
  List<Offset> region = [
    Offset(-r, -r),
    Offset(r, -r),
    Offset(r, r),
    Offset(-r, r),
  ];
  for (int i = 0; i < normals.length; i++) {
    region = _clipHalfPlane(region, normals[i], distances[i]);
    if (region.isEmpty) return null;
  }
  if (region.isEmpty) return null;

  // If the target already satisfies every constraint it is the optimal center.
  bool targetInside = true;
  for (int i = 0; i < normals.length; i++) {
    final n = normals[i];
    if (n.dx * target.dx + n.dy * target.dy < distances[i] - 1e-6) {
      targetInside = false;
      break;
    }
  }
  if (targetInside) return target;

  // Otherwise return the closest point on the eroded region boundary.
  return _nearestPointOnPolygon(region, target);
}

double _polyExtent(List<Offset> poly) {
  double m = 0;
  for (final p in poly) {
    m = m > p.dx.abs() ? m : p.dx.abs();
    m = m > p.dy.abs() ? m : p.dy.abs();
  }
  return m;
}

/// Sutherland–Hodgman clip of [poly] keeping the side where `n·p >= d`.
List<Offset> _clipHalfPlane(List<Offset> poly, Offset n, double d) {
  if (poly.isEmpty) return poly;
  final out = <Offset>[];
  for (int i = 0; i < poly.length; i++) {
    final cur = poly[i];
    final nxt = poly[(i + 1) % poly.length];
    final curDist = n.dx * cur.dx + n.dy * cur.dy - d;
    final nxtDist = n.dx * nxt.dx + n.dy * nxt.dy - d;
    final curIn = curDist >= 0;
    final nxtIn = nxtDist >= 0;
    if (curIn) out.add(cur);
    if (curIn != nxtIn) {
      final t = curDist / (curDist - nxtDist);
      out.add(
        Offset(cur.dx + (nxt.dx - cur.dx) * t, cur.dy + (nxt.dy - cur.dy) * t),
      );
    }
  }
  return out;
}

Offset _nearestPointOnPolygon(List<Offset> poly, Offset target) {
  double best = double.infinity;
  Offset bestPt = poly.first;
  for (int i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final p = _closestOnSegment(a, b, target);
    final dd = (p - target).distanceSquared;
    if (dd < best) {
      best = dd;
      bestPt = p;
    }
  }
  return bestPt;
}

Offset _closestOnSegment(Offset a, Offset b, Offset p) {
  final ab = b - a;
  final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lenSq == 0) return a;
  double t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lenSq;
  t = t.clamp(0.0, 1.0);
  return Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
}
