// lib/widgets/jarvis_card.dart

import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class JarvisCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final BorderSide? topBorderAccent;

  const JarvisCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth,
    this.shadows,
    this.onTap,
    this.topBorderAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? bgTertiary,
        border: Border.all(
          color: borderColor ?? goldLine,
          width: borderWidth ?? 0.8,
        ),
        borderRadius: BorderRadius.circular(BorderValues.md),
        boxShadow: shadows,
      ),
      padding: padding ?? const EdgeInsets.all(Spacing.md),
      child: child,
    );

    // Add top accent line if provided
    if (topBorderAccent != null) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
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
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

// Variant: Card with left accent bar
class JarvisCardAccent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color accentColor;
  final double accentWidth;

  const JarvisCardAccent({
    Key? key,
    required this.child,
    this.padding,
    this.accentColor = gold,
    this.accentWidth = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BorderValues.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          JarvisCard(
            backgroundColor: bgTertiary,
            borderColor: goldLine,
            padding: padding ?? const EdgeInsets.all(Spacing.md),
            child: child,
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: accentWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BorderValues.md),
                  bottomLeft: Radius.circular(BorderValues.md),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card with income theme
class IncomeCard extends JarvisCard {
  const IncomeCard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) : super(
    key: key,
    child: child,
    padding: padding,
    backgroundColor: const Color.fromARGB(255, 10, 18, 13),
    borderColor: incomeLine,
  );
}

// Card with expense theme
class ExpenseCard extends JarvisCard {
  const ExpenseCard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) : super(
    key: key,
    child: child,
    padding: padding,
    backgroundColor: const Color.fromARGB(255, 18, 10, 10),
    borderColor: expenseLine,
  );
}
