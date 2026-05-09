// lib/widgets/jarvis_kpi.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import 'jarvis_card.dart';

class JarvisKpi extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;
  final bool showBottomAccent;

  const JarvisKpi({
    Key? key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.showBottomAccent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: bgTertiary,
            border: Border.all(color: goldLine, width: 0.8),
            borderRadius: BorderRadius.circular(BorderValues.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: valueColor ?? gold,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      color: gold.withOpacity(0.5),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: textDim,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showBottomAccent)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(BorderValues.md),
                  bottomRight: Radius.circular(BorderValues.md),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    goldLine,
                    goldLine.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class KpiRow extends StatelessWidget {
  final List<KpiData> items;

  const KpiRow({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            SizedBox(
              width: 140,
              child: JarvisKpi(
                value: items[i].value,
                label: items[i].label,
                icon: items[i].icon,
                valueColor: items[i].valueColor,
              ),
            ),
            if (i < items.length - 1) const SizedBox(width: Spacing.lg),
          ],
        ],
      ),
    );
  }
}

class KpiData {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  const KpiData({
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });
}

// Variant: KPI with progress
class JarvisKpiWithProgress extends StatelessWidget {
  final String value;
  final String label;
  final double progress;
  final Color? progressColor;

  const JarvisKpiWithProgress({
    Key? key,
    required this.value,
    required this.label,
    required this.progress,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: progressColor ?? gold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 8,
              color: textDim,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: Spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(BorderValues.xs),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: bgQuaternary,
              valueColor: AlwaysStoppedAnimation(progressColor ?? gold),
            ),
          ),
        ],
      ),
    );
  }
}
