// lib/widgets/jarvis_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final int sectionNumber;
  final String title;
  final String? description;

  const SectionHeader({
    Key? key,
    required this.sectionNumber,
    required this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xl,
        horizontal: Spacing.xxxl,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: goldLine, width: 0.8),
              borderRadius: BorderRadius.circular(BorderValues.xs),
            ),
            child: Text(
              '${sectionNumber.toString().padLeft(2, '0')}',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: gold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: 2,
            ),
          ),
          if (description != null) ...[
            const SizedBox(width: Spacing.sm),
            Text(
              description!,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: textDim,
                letterSpacing: 0.5,
              ),
            ),
          ],
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: Spacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [goldLine, goldLine.withOpacity(0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Task Item
class TaskItem extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final String? meta;
  final VoidCallback? onTap;

  const TaskItem({
    Key? key,
    required this.label,
    this.isCompleted = false,
    this.meta,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderValues.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCompleted ? gold : goldLine,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(BorderValues.xs),
                color: isCompleted ? gold : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 10,
                      color: bgPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? textDim : textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      meta!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: textDim,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Title (smaller)
class SectionTitle extends StatelessWidget {
  final String title;
  final String? link;
  final VoidCallback? onLinkTap;

  const SectionTitle({
    Key? key,
    required this.title,
    this.link,
    this.onLinkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: gold,
            letterSpacing: 1.5,
          ),
        ),
        if (link != null)
          InkWell(
            onTap: onLinkTap,
            borderRadius: BorderRadius.circular(4),
            child: Text(
              link!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                color: textDim,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

// Divider with gradient
class GradieDivider extends StatelessWidget {
  final Color? color;
  final double? thickness;

  const GradieDivider({
    Key? key,
    this.color,
    this.thickness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness ?? 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color ?? goldLine,
            (color ?? goldLine).withOpacity(0),
          ],
        ),
      ),
    );
  }
}

// Device Shell (Mobile mockup frame)
class MobileDeviceShell extends StatelessWidget {
  final Widget child;

  const MobileDeviceShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          border: Border.all(
            color: const Color(0xFF252525),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              blurRadius: 80,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Desktop DeviceShell
class DesktopDeviceShell extends StatelessWidget {
  final Widget child;

  const DesktopDeviceShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        height: 700,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          border: Border.all(
            color: const Color(0xFF252525),
            width: 1.5,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              blurRadius: 80,
            ),
          ],
        ),
        child: Column(
          children: [
            // Window bar
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF252525),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
