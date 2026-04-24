import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class SpendingAreaChart extends StatefulWidget {
  const SpendingAreaChart({
    super.key,
    this.height = 220,
    this.selectionIndex = 1,
    this.showSelectionGuideline = true,
    required this.series,
  });

  final double height;
  final int selectionIndex;
  final bool showSelectionGuideline;
  final List<double> series;

  @override
  State<SpendingAreaChart> createState() => _SpendingAreaChartState();
}

class _DashedVLinePainter extends CustomPainter {
  _DashedVLinePainter({required this.x});

  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    const dash = 6.0;
    const gap = 5.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVLinePainter oldDelegate) => oldDelegate.x != x;
}

class _SpendingAreaChartState extends State<SpendingAreaChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void didUpdateWidget(SpendingAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.series, widget.series)) {
      _controller.forward(from: 0);
    }
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _spotsFor(List<double> data, double t) {
    final n = data.length;
    if (n == 0) return [];
    final maxIndex = ((n - 1) * t).clamp(0, n - 1).floor();
    final partial = ((n - 1) * t) - maxIndex;
    final spots = <FlSpot>[];
    for (var i = 0; i <= maxIndex; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    if (maxIndex < n - 1 && t > 0) {
      final y0 = data[maxIndex];
      final y1 = data[maxIndex + 1];
      spots.add(FlSpot(maxIndex + partial, y0 + (y1 - y0) * partial));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.series;
    if (data.length < 2) {
      return SizedBox(height: widget.height);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final spots = _spotsFor(data, Curves.easeOutCubic.transform(_controller.value));
        if (spots.isEmpty) {
          return SizedBox(height: widget.height);
        }
        final maxY = data.reduce((a, b) => a > b ? a : b) * 1.15;

        return LayoutBuilder(
          builder: (context, c) {
            final chartWidth = c.maxWidth;
            const leftPad = 8.0;
            final usable = (chartWidth - 16).clamp(1, double.infinity);
            final maxX = (data.length - 1).toDouble();
            final sel = widget.selectionIndex.clamp(0, data.length - 1);
            final lineX = leftPad + usable * (maxX == 0 ? 0 : sel / maxX);

            return SizedBox(
              height: widget.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxX,
                      minY: 0,
                      maxY: maxY,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (v, meta) {
                              const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              final i = v.round();
                              if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[i],
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.28,
                          barWidth: 2.5,
                          color: AppColors.accent,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              final isSelection = (spot.x - sel).abs() < 0.08;
                              if (!isSelection) {
                                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                              }
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: AppColors.accent,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.chartBlueOpaque.withValues(alpha: 0.45),
                                AppColors.chartBlueTransparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showSelectionGuideline && _controller.value > 0.35)
                    Positioned(
                      top: 8,
                      bottom: 36,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _DashedVLinePainter(x: lineX),
                        ),
                      ),
                    ),
                  ..._selectionTooltip(spots, sel, maxX),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _selectionTooltip(List<FlSpot> spots, int sel, double maxX) {
    FlSpot? find(double x) {
      for (final s in spots) {
        if ((s.x - x).abs() < 0.12) return s;
      }
      return null;
    }

    final spot = find(sel.toDouble());
    if (spot == null || _controller.value < 0.55) return const [];

    final alignX = maxX == 0 ? 0.0 : (sel / maxX) * 2 - 1;

    return [
      IgnorePointer(
        child: Align(
          alignment: Alignment(alignX, -0.72),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              '\$${spot.y.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.background,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
