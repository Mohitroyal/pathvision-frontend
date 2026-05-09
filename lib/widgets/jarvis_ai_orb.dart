// lib/widgets/jarvis_ai_orb.dart

import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class AiOrb extends StatefulWidget {
  final double size;
  final IconData icon;
  final bool animate;

  const AiOrb({
    Key? key,
    this.size = 60,
    this.icon = Icons.psychology,
    this.animate = true,
  }) : super(key: key);

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget orb = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0.4, 0.4),
          colors: [
            goldLight.withOpacity(0.9),
            gold,
            const Color(0xFF5C3A08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: goldGlow,
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: bgPrimary,
          size: widget.size * 0.5,
        ),
      ),
    );

    if (widget.animate) {
      return ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: orb,
      );
    }

    return orb;
  }
}

class AiOrbSmall extends StatelessWidget {
  final double size;

  const AiOrbSmall({
    Key? key,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0.4, 0.4),
          colors: [
            goldLight,
            gold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: goldGlow,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
