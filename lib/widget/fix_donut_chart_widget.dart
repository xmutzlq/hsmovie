import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

import 'fix_pie_chart_painter.dart';

/// Modern donut chart with gradient sections
class FixDonutChartWidget extends StatefulWidget {
  final List<PieData> data;
  final ChartTheme? theme;
  final double borderWidth;
  final double centerSpaceRadius;
  final bool showLegend;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final String? centerTitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final PieSegmentCallback? onSegmentTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const FixDonutChartWidget({
    super.key,
    required this.data,
    this.theme,
    this.borderWidth = 2.0,
    this.centerSpaceRadius = 60,
    this.showLegend = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.centerTitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onSegmentTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<FixDonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<FixDonutChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    final total = widget.data.map((d) => d.value).reduce((a, b) => a + b);

    final Widget content = Row(
      children: [
        Expanded(
          flex: 2,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                    math.min(constraints.maxWidth, 250.0).toDouble();
                    return GestureDetector(
                      behavior: HitTestBehavior
                          .translucent, // Allow taps even when overlay is present
                      onTapDown: widget.onSegmentTap != null
                          ? (details) {
                        // Hide any existing context menu first to prevent blocking
                        ChartContextMenuHelper.hide();

                        // Use localPosition directly (relative to SizedBox)
                        final result =
                        ChartInteractionHelper.findPieSegment(
                          details.localPosition,
                          widget.data,
                          Size(size, 250),
                          widget.centerSpaceRadius,
                        );

                        debugPrint('element index : ${result?.elementIndex}');

                        if (result != null && result.isHit) {
                          // Provide haptic feedback
                          HapticFeedback.selectionClick();

                          // Set new selection (optimized single setState)
                          setState(() {
                            _selectedSegment = result;
                          });

                          // Get global position for context menu
                          final RenderBox? renderBox =
                          context.findRenderObject() as RenderBox?;
                          final globalPosition = renderBox != null
                              ? renderBox
                              .localToGlobal(details.localPosition)
                              : details.localPosition;

                          // Small delay to ensure overlay is removed before showing new menu
                          Future.microtask(() {
                            widget.onSegmentTap?.call(
                              result.segment!,
                              result.elementIndex!,
                              globalPosition,
                            );
                          });
                        } else {
                          // Clear selection if tap is outside any segment
                          setState(() {
                            _selectedSegment = null;
                          });
                        }
                      }
                          : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: size,
                            height: 250,
                            child: CustomPaint(
                              size: Size(size, 250),
                              painter: FixPieChartPainter(
                                data: widget.data,
                                theme: effectiveTheme,
                                centerSpaceRadius: widget.centerSpaceRadius,
                                borderWidth: widget.borderWidth,
                                showLabel: widget.showLabel,
                                animationProgress: _animation.value,
                                selectedSegment: _selectedSegment,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.centerTitle ?? 'Total',
                                style: TextStyle(
                                  color: effectiveTheme.textColor
                                      .withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                total.toStringAsFixed(0),
                                style: TextStyle(
                                  color: effectiveTheme.textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        if (widget.showLegend && effectiveTheme.showLegend)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: effectiveTheme.textColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${((item.value / total) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color:
                          effectiveTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );

    return ChartContainer(
      theme: effectiveTheme,
      title: widget.title,
      subtitle: widget.subtitle,
      useGlassmorphism: widget.useGlassmorphism,
      useNeumorphism: widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.errorMessage,
      child: content,
    );
  }
}
