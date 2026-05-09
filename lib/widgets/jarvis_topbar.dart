// lib/widgets/jarvis_topbar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../providers/jarvis_provider.dart';

class JarvisTopbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const JarvisTopbar({
    Key? key,
    this.title = 'JARVIS',
    this.actions,
    this.leading,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgPrimary.withOpacity(0.97),
        border: Border(
          bottom: BorderSide(
            color: goldLine,
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leading / Logo
                Row(
                  children: [
                    if (leading == null) ...[
                      if (ModalRoute.of(context)?.canPop ?? false)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: TopbarIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        )
                      else if (context.watch<JarvisProvider>().navigationIndex != 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: TopbarIconButton(
                            icon: Icons.home_outlined,
                            onTap: () => context.read<JarvisProvider>().setNavigationIndex(0),
                          ),
                        ),
                    ],
                    leading ??
                        Text(
                          title,
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gold,
                            letterSpacing: 2,
                          ),
                        ),
                  ],
                ),
                
                // Actions
                if (actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < actions!.length; i++) ...[
                        actions![i],
                        if (i < actions!.length - 1)
                          const SizedBox(width: Spacing.md),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));
}

class TopbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double? size;

  const TopbarIconButton({
    Key? key,
    required this.icon,
    this.onTap,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderValues.sm),
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: gold.withOpacity(0.05),
          border: Border.all(
            color: goldLine,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(BorderValues.sm),
        ),
        child: Icon(
          icon,
          color: color ?? gold,
          size: size ?? 16,
        ),
      ),
    );
  }
}

class TopbarAvatar extends StatelessWidget {
  final String initials;
  final Color? backgroundColor;
  final Color? textColor;

  const TopbarAvatar({
    Key? key,
    required this.initials,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? gold,
            backgroundColor ?? goldLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: goldGlow,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.orbitron(
            color: textColor ?? bgPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
