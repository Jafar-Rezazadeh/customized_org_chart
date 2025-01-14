import 'dart:ui';

class LineStyle {
  final Color color;
  final double strokeWidth;
  final bool isDashed;
  final double dashWidth;
  final double dashSpace;

  LineStyle({
    required this.color,
    required this.strokeWidth,
    this.isDashed = false,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  Paint toPaint() {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }
}
