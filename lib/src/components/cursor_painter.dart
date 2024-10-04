import 'package:flutter/material.dart';

class CursorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path arrowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height * 0.8)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.red.shade300
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
