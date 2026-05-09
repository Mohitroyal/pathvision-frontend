// lib/widgets/jarvis_sidebar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class JarvisSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const JarvisSidebar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Slightly wider for better breathing room
      decoration: const BoxDecoration(
        color: Color(0xFF030303),
        border: Border(
          right: BorderSide(
            color: Color(0x38C9A84C),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JARVIS',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC9A84C),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PATHVISION OS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 6,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6A6058),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0x1AC9A84C),
            thickness: 1,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _buildListItems().length,
              itemBuilder: (context, index) {
                final item = _buildListItems()[index];
                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
                    child: Text(
                      item,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6A6058),
                        letterSpacing: 2.5,
                      ),
                    ),
                  );
                } else if (item is SidebarItem) {
                  final actualIndex = items.indexOf(item);
                  final isSelected = selectedIndex == actualIndex;
                  return _SidebarNavItem(
                    label: item.label,
                    icon: item.icon,
                    isSelected: isSelected,
                    onTap: () => onItemTap(actualIndex),
                    badge: item.badge,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _buildListItems() {
    final list = <dynamic>[];
    String? currentSection;
    
    for (var item in items) {
      if (item.section != null && item.section != currentSection) {
        currentSection = item.section;
        list.add(currentSection!.toUpperCase());
      }
      list.add(item);
    }
    return list;
  }
}

class _SidebarNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFC9A84C);
    final inactiveColor = const Color(0xFF6A6058);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected ? null : (_isHovered ? const Color(0xFFC9A84C).withOpacity(0.05) : null),
            gradient: widget.isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xFF1A1405),
                      Color(0xFF2A2008),
                    ],
                  )
                : null,
            border: widget.isSelected
                ? Border.all(color: activeColor.withOpacity(0.5), width: 1)
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (widget.isSelected)
                Positioned(
                  left: -12,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isSelected ? activeColor : inactiveColor,
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isSelected ? const Color(0xFFE8C96D) : inactiveColor,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE74C3C).withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.badge!,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final String label;
  final IconData icon;
  final String? badge;
  final String? section;

  SidebarItem({
    required this.label,
    required this.icon,
    this.badge,
    this.section,
  });
}
