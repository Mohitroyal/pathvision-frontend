// lib/widgets/jarvis_chip.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

enum ChipType { ok, warn, danger, blue, gold, income, expense, purple }

class JarvisChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final bool showDot;
  final VoidCallback? onTap;

  const JarvisChip({
    Key? key,
    required this.label,
    this.type = ChipType.gold,
    this.showDot = true,
    this.onTap,
  }) : super(key: key);

  Color _getColor() {
    switch (type) {
      case ChipType.ok:
        return okColor;
      case ChipType.warn:
        return warnColor;
      case ChipType.danger:
        return dangerColor;
      case ChipType.blue:
        return blueColor;
      case ChipType.gold:
        return gold;
      case ChipType.income:
        return incomeLight;
      case ChipType.expense:
        return expenseLight;
      case ChipType.purple:
        return purpleColor;
    }
  }

  Color _getBackgroundColor() {
    final color = _getColor();
    switch (type) {
      case ChipType.ok:
        return const Color.fromARGB(38, 30, 138, 74);
      case ChipType.warn:
        return const Color.fromARGB(38, 212, 131, 10);
      case ChipType.danger:
        return const Color.fromARGB(38, 192, 57, 43);
      case ChipType.blue:
        return const Color.fromARGB(38, 36, 113, 163);
      case ChipType.gold:
        return goldDim;
      case ChipType.income:
        return incomeDim;
      case ChipType.expense:
        return expenseDim;
      case ChipType.purple:
        return purpleDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getColor().withOpacity(0.5),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(BorderValues.xs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColor(),
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _getColor(),
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Variant with custom text only (no dot)
class SimpleChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const SimpleChip({
    Key? key,
    required this.label,
    required this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.15),
        border: Border.all(color: color, width: 0.6),
        borderRadius: BorderRadius.circular(BorderValues.xs),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
