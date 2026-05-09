// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tasks_screen.dart';
import 'add_task_screen.dart';
import 'notifications_screen.dart';
import 'ai_screen.dart';
import 'team_screen.dart';
import 'company_intel_screen.dart';
import 'placeholder_screen.dart';
import '../providers/task_provider.dart';
import '../providers/team_provider.dart';
import '../providers/milestone_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'profile_screen.dart';
import '../providers/jarvis_provider.dart';
import '../providers/auth_provider.dart';

// ─── Design System ─────────────────────────────────────────────────────────
const Color _bg = Color(0xFF030303);
const Color _card = Color(0xFF111111);
const Color _cardAlt = Color(0xFF0A0A0A);
const Color _gold = Color(0xFFC9A84C);
const Color _goldLight = Color(0xFFE8C96D);
const Color _text = Color(0xFFE8E0D0);
const Color _dim = Color(0xFF6A6058);
const Color _border = Color(0xFF1F1B14);

const Color _green = Color(0xFF4ED38A);
const Color _red = Color(0xFFE25C5C);
const Color _yellow = Color(0xFFE8C96D);
const Color _blue = Color(0xFF5CA8E2);

const double _radius = 6;

TextStyle _orbitron({double size = 14, FontWeight w = FontWeight.w600, Color c = _text, double sp = 1.2}) =>
    GoogleFonts.orbitron(fontSize: size, fontWeight: w, color: c, letterSpacing: sp);

TextStyle _rajdhani({double size = 13, FontWeight w = FontWeight.w500, Color c = _text, double sp = 0.2}) =>
    GoogleFonts.rajdhani(fontSize: size, fontWeight: w, color: c, letterSpacing: sp);

TextStyle _mono({double size = 11, FontWeight w = FontWeight.w400, Color c = _dim, double sp = 0.4}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, color: c, letterSpacing: sp);

BoxDecoration _cardDeco({Color? color, Color border = _border, bool glow = false}) => BoxDecoration(
      color: color ?? _card,
      borderRadius: BorderRadius.circular(_radius),
      border: Border.all(color: border, width: 1),
      boxShadow: glow
          ? [
              BoxShadow(color: _gold.withOpacity(0.18), blurRadius: 18, spreadRadius: -2),
              BoxShadow(color: _gold.withOpacity(0.06), blurRadius: 36, spreadRadius: 2),
            ]
          : null,
    );

// ─── Screen ────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1200;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: _MainArea()),
                  SizedBox(width: 320, child: _RightPanel()),
                ],
              )
            else
              const _MainArea(),
            const Positioned(right: 28, bottom: 28, child: _Fab()),
          ],
        ),
      ),
    );
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _TopBar(),
            SizedBox(height: 22),
            _CommandBar(),
            SizedBox(height: 20),
            _KpiRow(),
            SizedBox(height: 20),
            _MainGrid(),
            SizedBox(height: 20),
            _ProjectHealth(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JARVIS', style: _orbitron(size: 18, c: _gold, w: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Command Center', style: _mono(size: 11, c: _dim)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text('⌘K', style: _mono(size: 9, c: _dim)),
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              borderRadius: BorderRadius.circular(_radius),
              child: Container(
                width: 36,
                height: 36,
                decoration: _cardDeco(),
                child: const Icon(Icons.notifications_none_rounded, size: 16, color: _text),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _red.withOpacity(0.6), blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => context.read<JarvisProvider>().setNavigationIndex(1),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _card,
              border: Border.all(color: _gold, width: 1),
              boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 10)],
              image: DecorationImage(
                image: NetworkImage(
                  user != null 
                    ? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['full_name'] ?? 'User')}&background=0D0D0D&color=D4AF37'
                    : 'https://ui-avatars.com/api/?name=User&background=0D0D0D&color=D4AF37'
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiScreen())),
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: _cardDeco(border: _gold.withOpacity(0.55), glow: true),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _gold.withOpacity(0.5)),
              ),
              child: const Icon(Icons.bolt_rounded, color: _gold, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'JARVIS command:  add task review IMAS by 2pm...',
                style: _rajdhani(size: 14, c: _dim.withOpacity(0.9), w: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: _gold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('PRESS', style: _mono(size: 9, c: _gold, sp: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final data = dashboardProvider.data;

    // Compute dynamic counts from real-time data
    final tasks = data['tasks'] as List? ?? [];
    final myTasksCount = tasks.fold(0, (acc, curr) => curr['status'] != 'done' ? acc + int.parse(curr['count'].toString()) : acc);
    final projectsCount = (data['projects'] as List?)?.length ?? 0;
    final openRisks = data['openRisks'] ?? 0;
    final teamCount = 12; // Static for demo or fetch from teamProvider

    final cards = [
      _Kpi('MY TASKS', myTasksCount.toString(), 'active', _green),
      _Kpi('RISKS', openRisks.toString(), 'on radar', _red),
      _Kpi('PROJECTS', projectsCount.toString(), 'tracked', _blue),
      _Kpi('TEAM', teamCount.toString(), 'online', _gold),
      _Kpi('PENDING', (data['pendingMilestones'] ?? 0).toString(), 'milestones', _yellow),
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth < 700 ? 2 : 5;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards
            .map((k) => SizedBox(
                  width: (c.maxWidth - (cols - 1) * 14) / cols,
                  child: k,
                ))
            .toList(),
      );
    });
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final Color color;

  const _Kpi(this.label, this.value, this.status, this.color);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'MY TASKS') Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
        if (label == 'TEAM') Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamScreen()));
      },
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: _mono(size: 9, sp: 1.6, c: _dim)),
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: _orbitron(size: 28, c: color, w: FontWeight.w700, sp: 0.5)),
            const SizedBox(height: 6),
            Text(status, style: _rajdhani(size: 11, c: _dim, w: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MainGrid extends StatelessWidget {
  const _MainGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth < 700) {
        return Column(
          children: const [
            _PinnedItems(),
            SizedBox(height: 14),
            _TodayPriorities(),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(child: _PinnedItems()),
          SizedBox(width: 14),
          Expanded(child: _TodayPriorities()),
        ],
      );
    });
  }
}

class _PinnedItems extends StatelessWidget {
  const _PinnedItems();

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final activity = dashboardProvider.data['activity'] as List? ?? [];

    return _SectionCard(
      title: 'SYSTEM ACTIVITY',
      trailing: Text('${activity.length}', style: _mono(size: 10, c: _gold)),
      child: Column(
        children: activity.map((a) {
          return _PinnedTile(
            Icons.history, 
            a['action'].toString().replaceAll('_', ' ').toUpperCase(), 
            DateFormat('HH:mm').format(DateTime.parse(a['created_at']))
          );
        }).toList(),
      ),
    );
  }
}

class _PinnedTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PinnedTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardAlt,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: Icon(icon, color: _gold, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _rajdhani(size: 13, w: FontWeight.w600, c: _text)),
                const SizedBox(height: 2),
                Text(subtitle, style: _mono(size: 10, c: _dim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPriorities extends StatelessWidget {
  const _TodayPriorities();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final items = taskProvider.tasks.take(4).toList();

    return _SectionCard(
      title: "LIVE TASKS",
      trailing: Text('${items.length} ACTIVE', style: _mono(size: 10, c: _gold)),
      child: Column(
        children: items.map((p) => Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: _cardAlt,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: p.status == TaskStatus.done ? _green : _dim),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.title,
                  style: _rajdhani(
                    size: 13,
                    w: FontWeight.w600,
                    c: p.status == TaskStatus.done ? _dim : _text,
                  ).copyWith(decoration: p.status == TaskStatus.done ? TextDecoration.lineThrough : null),
                ),
              ),
              _Tag(p.priority.name.toUpperCase(), p.priority == TaskPriority.critical ? _red : _gold),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.45), width: 0.7),
      ),
      child: Text(text, style: _mono(size: 9, c: color, sp: 0.8, w: FontWeight.w500)),
    );
  }
}

class _ProjectHealth extends StatelessWidget {
  const _ProjectHealth();

  @override
  Widget build(BuildContext context) {
    final milestoneProvider = context.watch<MilestoneProvider>();
    final projects = milestoneProvider.milestones.take(3).toList();

    return _SectionCard(
      title: 'PROJECT STATUS',
      trailing: Text('${projects.length} ACTIVE', style: _mono(size: 10, c: _gold)),
      child: Column(
        children: projects.map((m) => _ProjectRow(
          m.project, 
          m.status.name.toUpperCase(), 
          m.status == MilestoneStatus.atRisk ? _red : _green, 
          0.7, 10, 7
        )).toList(),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  final double progress;
  final int total;
  final int done;
  const _ProjectRow(this.name, this.status, this.color, this.progress, this.total, this.done);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _cardAlt,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 24, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: _rajdhani(size: 14, w: FontWeight.w700, c: _text)),
                    Text('$done / $total milestones', style: _mono(size: 10, c: _dim)),
                  ],
                ),
              ),
              _Tag(status, color),
            ],
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cardAlt,
        border: Border(left: BorderSide(color: _border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _AiStatus(),
            SizedBox(height: 18),
            _MorningBriefing(),
            SizedBox(height: 18),
            _RemindersCard(),
          ],
        ),
      ),
    );
  }
}

class _AiStatus extends StatelessWidget {
  const _AiStatus();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(glow: true, border: _gold.withOpacity(0.4)),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: _gold, size: 32),
          const SizedBox(height: 12),
          Text('SYSTEM SYNCED', style: _orbitron(size: 13, c: _gold, sp: 2.5)),
          const SizedBox(height: 4),
          Text('Real-time event engine active', style: _mono(size: 10, c: _dim)),
        ],
      ),
    );
  }
}

class _MorningBriefing extends StatelessWidget {
  const _MorningBriefing();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [_gold.withOpacity(0.12), _card],
        ),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _gold.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXECUTIVE SUMMARY', style: _orbitron(size: 11, c: _gold, sp: 1.8)),
          const SizedBox(height: 10),
          Text(
            'System is performing at peak efficiency. Real-time updates enabled across all 8 core modules.',
            style: _rajdhani(size: 12, c: _text, w: FontWeight.w400).copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  const _RemindersCard();
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'LIVE ALERTS',
      trailing: const Icon(Icons.notifications_active, color: _gold, size: 12),
      child: Column(
        children: const [
          _PinnedTile(Icons.info_outline, 'EVENT ENGINE ACTIVE', 'Listening for triggers'),
          _PinnedTile(Icons.sync, 'DATABASE SYNC', 'Connection optimal'),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _orbitron(size: 11, sp: 1.8, c: _gold)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: _gold,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTaskScreen())),
      child: const Icon(Icons.add, color: _bg),
    );
  }
}
