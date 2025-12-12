import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Custom painter for pie and donut charts
class FixPieChartPainter extends CustomPainter {
  final List<PieData> data;
  final ChartTheme theme;
  final double centerSpaceRadius;
  final double borderWidth;
  final double animationProgress;
  final ChartInteractionResult? selectedSegment;
  final bool showLabel;

  FixPieChartPainter({
    required this.data,
    required this.theme,
    this.centerSpaceRadius = 0.0,
    this.borderWidth = 2.0,
    this.animationProgress = 1.0,
    this.selectedSegment,
    this.showLabel = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final total = data.map((d) => d.value).reduce((a, b) => a + b);

    double startAngle = -math.pi; // Start from top

    for (int index = 0; index < data.length; index++) {
      final item = data[index];
      final sweepAngle = (item.value / total) * 1.9999 * math.pi;

      // Animate each segment with stagger
      final segmentProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - (index / data.length) * 0.5) / 0.5,
        ),
      );
      final animatedSweepAngle = sweepAngle * segmentProgress;

      // Check if this segment is selected
      final isSelected = selectedSegment != null &&
          selectedSegment!.isHit &&
          selectedSegment!.elementIndex == index;

      // Draw segment with professional gradient (brighter if selected)
      final rect = Rect.fromCircle(center: center, radius: radius);
      final midAngle = startAngle + sweepAngle / 2;
      final gradientCenter = Offset(
        center.dx + math.cos(midAngle) * (radius * 0.3),
        center.dy + math.sin(midAngle) * (radius * 0.3),
      );

      // Adjust colors if selected
      final baseColor = isSelected ? item.color : item.color;
      final secondaryColor = isSelected
          ? item.color.withValues(alpha: 0.85)
          : item.color.withValues(alpha: 0.75);

      final paint = Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (gradientCenter.dx - center.dx) / radius,
            (gradientCenter.dy - center.dy) / radius,
          ),
          radius: 0.8,
          colors: [
            baseColor,
            secondaryColor,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      if (centerSpaceRadius > 0) {
        // Donut chart
        final outerPath = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(rect, startAngle, animatedSweepAngle, false)
          ..lineTo(center.dx, center.dy)
          ..close();
        // final outerPath = Path()..addOval(rect)..close();

        final innerRect = Rect.fromCircle(center: center, radius: centerSpaceRadius);
        final innerPath = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            innerRect,
            startAngle + animatedSweepAngle,
            -animatedSweepAngle,
            false,
          )
          ..lineTo(center.dx, center.dy)
          ..close();
        // final innerPath = Path()..addOval(innerRect)..close();

        final combinedPath = Path.combine(
          PathOperation.difference,
          outerPath,
          innerPath,
        );

        canvas.drawPath(combinedPath, paint);

        // Add border if selected
        if (isSelected) {
          final borderPaint = Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth + 2;
          canvas.drawPath(combinedPath, borderPaint);
        }
      } else {
        // Pie chart
        canvas.drawArc(
          rect,
          startAngle,
          animatedSweepAngle,
          true,
          paint,
        );

        // Add border if selected
        if (isSelected) {
          final borderPaint = Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth + 2;
          canvas.drawArc(
            rect,
            startAngle,
            animatedSweepAngle,
            true,
            borderPaint,
          );
        }
      }

      // Draw percentage label - only for larger segments
      if (showLabel && animatedSweepAngle > 0.3 && segmentProgress > 0.5) {
        final labelAngle = startAngle + animatedSweepAngle / 2;
        final labelRadius = centerSpaceRadius > 0
            ? (radius + centerSpaceRadius) / 2
            : radius * 0.7;
        final labelX = center.dx + math.cos(labelAngle) * labelRadius;
        final labelY = center.dy + math.sin(labelAngle) * labelRadius;

        final percentage = ((item.value / total) * 100).toStringAsFixed(1);

        // Background for better readability
        final textSpan = TextSpan(
          text: '$percentage%',
          style: TextStyle(
            color: theme.backgroundColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        // Draw text background
        final bgRect = Rect.fromCenter(
          center: Offset(labelX, labelY),
          width: textPainter.width + 8,
          height: textPainter.height + 4,
        );
        final bgPaint = Paint()
          ..color = item.color.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
          bgPaint,
        );

        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle; // Use original angle for positioning
    }
  }

  @override
  bool shouldRepaint(covariant FixPieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.theme != theme ||
        oldDelegate.centerSpaceRadius != centerSpaceRadius ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedSegment != selectedSegment ||
        oldDelegate.showLabel != showLabel;
  }
}
