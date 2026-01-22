import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';

class AppIconWidget extends StatelessWidget {
  final double size;

  const AppIconWidget({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: GraphIconPainter(),
      ),
    );
  }
}

class GraphIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final width = size.width;
    final height = size.height;
    final padding = width * 0.2;

    // Draw three vertical bars
    final barWidth = width * 0.08;
    final bar1Height = height * 0.25;
    final bar2Height = height * 0.4;
    final bar3Height = height * 0.55;

    final bar1X = padding + barWidth * 2;
    final bar2X = bar1X + barWidth * 2;
    final bar3X = bar2X + barWidth * 2;
    final barY = height * 0.7;

    // Bar 1
    canvas.drawRect(
      Rect.fromLTWH(
        bar1X - barWidth / 2,
        barY - bar1Height,
        barWidth,
        bar1Height,
      ),
      paint,
    );

    // Bar 2
    canvas.drawRect(
      Rect.fromLTWH(
        bar2X - barWidth / 2,
        barY - bar2Height,
        barWidth,
        bar2Height,
      ),
      paint,
    );

    // Bar 3
    canvas.drawRect(
      Rect.fromLTWH(
        bar3X - barWidth / 2,
        barY - bar3Height,
        barWidth,
        bar3Height,
      ),
      paint,
    );

    // Draw line graph from top of bar 3
    final linePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startX = bar3X;
    final startY = barY - bar3Height;
    final endX = width * 0.75;
    final endY = height * 0.25;
    final controlX = (startX + endX) / 2;
    final controlY = (startY + endY) / 2 - height * 0.1;

    final path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(controlX, controlY, endX, endY);
    canvas.drawPath(path, linePaint);

    // Draw glowing dot at the end
    canvas.drawCircle(
      Offset(endX, endY),
      width * 0.05,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(endX, endY),
      width * 0.03,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

