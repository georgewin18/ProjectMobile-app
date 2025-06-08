import 'package:flutter/material.dart';

class AlertSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double thumbHeight;

  const AlertSliderThumb({
    this.thumbHeight = 32,
    this.thumbRadius = 40,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbHeight * 1.5, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: center, width: getPreferredSize(true, false).width, height: thumbHeight),
      topLeft: Radius.circular(thumbRadius),
      topRight: Radius.circular(thumbRadius),
      bottomLeft: Radius.circular(thumbRadius),
      bottomRight: Radius.circular(thumbRadius),
    );
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRRect(rrect, borderPaint);

    final textSpan = TextSpan(
      text: '${(value * 100).round()}%',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: sliderTheme.disabledThumbColor,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textCenter = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );

    textPainter.paint(canvas, textCenter);
  }
}