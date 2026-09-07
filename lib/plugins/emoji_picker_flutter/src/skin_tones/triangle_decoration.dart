import 'package:material_ui/material_ui.dart';

/// Decoration that can be used to render a triangle in the bottom-right
/// corner of a container
class TriangleDecoration extends Decoration {
  /// Constructor
  const TriangleDecoration({required this.color, required this.size}) : super();

  /// Color of the triangle
  final Color color;

  /// Width and height of the triangle
  final double size;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TriangleShapePainter(color, size);
  }
}

class _TriangleShapePainter extends BoxPainter {
  /// Constructor
  /// Expects color that the triangle will be filled with and
  /// size of the triangle
  _TriangleShapePainter(Color color, double size) {
    _painter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _size = size;
  }

  late final Paint _painter;
  late final double _size;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // per documentation, the size should be always not null here, no need
    // for null checks
    final s = configuration.size!;
    var path = Path()
      ..moveTo(s.width + offset.dx, s.height - _size + offset.dy)
      ..lineTo(s.width - _size + offset.dx, s.height + offset.dy)
      ..lineTo(s.width + offset.dx, s.height + offset.dy)
      ..lineTo(s.width + offset.dx, s.height - _size + offset.dy)
      ..close();

    canvas.drawPath(path, _painter);
  }
}
