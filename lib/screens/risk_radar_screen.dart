// lib/screens/risk_radar_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/risk_model.dart';
import '../models/task_model.dart';
import '../providers/risk_provider.dart';
import '../providers/task_provider.dart';
import '../providers/team_provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

// ---------------------------------------------------------------------------
// Search dataset
// ---------------------------------------------------------------------------

enum SearchKind { task, note, project, person, decision }

extension SearchKindX on SearchKind {
  String get label {
    switch (this) {
      case SearchKind.task:
        return 'TASK';
      case SearchKind.note:
        return 'NOTE';
      case SearchKind.project:
        return 'PROJECT';
      case SearchKind.person:
        return 'PERSON';
      case SearchKind.decision:
        return 'DECISION';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchKind.task:
        return Icons.assignment_outlined;
      case SearchKind.note:
        return Icons.note_alt_outlined;
      case SearchKind.project:
        return Icons.folder_open_outlined;
      case SearchKind.person:
        return Icons.person_outline;
      case SearchKind.decision:
        return Icons.gavel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SearchKind.task:
        return goldLight;
    case SearchKind.note:
      return blueColor;
    case SearchKind.project:
      return goldLighter;
    case SearchKind.person:
      return purpleColor;
    case SearchKind.decision:
      return okColor;
    }
  }
}

class _SearchHit {
  final String title;
  final String meta;
  final SearchKind kind;
  const _SearchHit({required this.title, required this.meta, required this.kind});
}

const List<_SearchHit> _seedHits = [
  _SearchHit(title: 'Jetson Firmware Conflict', meta: 'IMAS / Hardware', kind: SearchKind.note),
  _SearchHit(title: 'IMAS Power Budget', meta: 'IMAS / Spec', kind: SearchKind.note),
  _SearchHit(title: 'IMAS Core System', meta: 'Active Project', kind: SearchKind.project),
  _SearchHit(title: 'AgriPulse', meta: 'Active Project · Phase 2', kind: SearchKind.project),
  _SearchHit(title: 'OBD-II Interface', meta: 'Active Project', kind: SearchKind.project),
  _SearchHit(title: 'TensorRT INT8 Entry', meta: 'Decision · 2026-04-12', kind: SearchKind.decision),
  _SearchHit(title: 'Switch to PostgreSQL 16', meta: 'Decision · 2026-04-08', kind: SearchKind.decision),
  _SearchHit(title: 'Cohort 2 Onboarding Plan', meta: 'Decision · 2026-04-15', kind: SearchKind.decision),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RiskRadarScreen extends StatefulWidget {
  const RiskRadarScreen({super.key});

  @override
  State<RiskRadarScreen> createState() => _RiskRadarScreenState();
}

class _RiskRadarScreenState extends State<RiskRadarScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _expandedId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_SearchHit> _runSearch(BuildContext context) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final tasks = context.read<TaskProvider>().tasks.map((t) => _SearchHit(
          title: t.title,
          meta: '${_taskStatusLabel(t.status)} · ${t.project ?? "—"}',
          kind: SearchKind.task,
        ));
    final people = context.read<TeamProvider>().members.map((m) => _SearchHit(
          title: m.name,
          meta: '${m.role} · ${m.dept}',
          kind: SearchKind.person,
        ));

    final all = [...tasks, ...people, ..._seedHits];
    return all
        .where((h) =>
            h.title.toLowerCase().contains(q) ||
            h.meta.toLowerCase().contains(q) ||
            h.kind.label.toLowerCase().contains(q))
        .take(10)
        .toList();
  }

  String _taskStatusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Future<void> _openAddRiskDialog({RiskModel? existing}) async {
    final provider = context.read<RiskProvider>();
    final result = await showDialog<_RiskFormResult>(
      context: context,
      builder: (_) => _RiskFormDialog(initial: existing),
    );
    if (result == null) return;
    if (existing == null) {
      provider.addRisk(
        title: result.title,
        description: result.description,
        severity: result.severity,
        tags: result.tags,
        owner: result.owner,
      );
      if (mounted) _toast('Risk added to radar.');
    } else {
      provider.updateRisk(
        existing.id,
        title: result.title,
        description: result.description,
        severity: result.severity,
        tags: result.tags,
        owner: result.owner,
      );
      if (mounted) _toast('Risk updated.');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _confirmDelete(RiskModel r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderValues.md),
          side: const BorderSide(color: goldLine),
        ),
        title: Text(
          'REMOVE RISK?',
          style: GoogleFonts.orbitron(
            color: dangerColor,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          r.title,
          style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: textDim)),
          ),
          TextButton(
            onPressed: () {
              context.read<RiskProvider>().removeRisk(r.id);
              Navigator.pop(ctx);
              _toast('Risk removed.');
            },
            child: const Text('REMOVE', style: TextStyle(color: dangerColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;
    final risks = context.watch<RiskProvider>().risks;
    final insight = context.watch<RiskProvider>().autoInsight();
    final hits = _runSearch(context);

    final feed = _RiskFeedPanel(
      risks: risks,
      insight: insight,
      expandedId: _expandedId,
      onToggle: (id) => setState(() => _expandedId = _expandedId == id ? null : id),
      onEdit: (r) => _openAddRiskDialog(existing: r),
      onDelete: _confirmDelete,
    );

    final report = _WeeklyReportPanel(
      risks: risks,
      hits: hits,
      query: _query,
      searchController: _searchCtrl,
      onQueryChanged: (q) => setState(() => _query = q),
      onClearSearch: () {
        _searchCtrl.clear();
        setState(() => _query = '');
      },
    );

    return Scaffold(
      appBar: JarvisTopbar(
        title: 'RISK RADAR',
        actions: [
          TopbarIconButton(
            icon: Icons.refresh,
            onTap: () => _toast('Risk radar synced.'),
          ),
          TopbarIconButton(
            icon: Icons.add,
            onTap: () => _openAddRiskDialog(),
          ),
        ],
      ),
      floatingActionButton: _RiskFab(onTap: () => _openAddRiskDialog()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? Spacing.xl : Spacing.lg),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: feed),
                  const SizedBox(width: Spacing.xl),
                  Expanded(flex: 4, child: report),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  feed,
                  const SizedBox(height: Spacing.xl),
                  report,
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Left panel — Risk feed
// ---------------------------------------------------------------------------

class _RiskFeedPanel extends StatelessWidget {
  final List<RiskModel> risks;
  final String insight;
  final String? expandedId;
  final ValueChanged<String> onToggle;
  final ValueChanged<RiskModel> onEdit;
  final ValueChanged<RiskModel> onDelete;

  const _RiskFeedPanel({
    required this.risks,
    required this.insight,
    required this.expandedId,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(eyebrow: 'LIVE FEED', title: 'Risk Radar', count: risks.length),
        const SizedBox(height: Spacing.md),
        _JarvisAlertCard(insight: insight),
        const SizedBox(height: Spacing.lg),
        Text(
          'ACTIVE RISKS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: textDim,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (risks.isEmpty)
          _EmptyBox(label: 'No active risks. Add one with the + button.')
        else
          for (int i = 0; i < risks.length; i++) ...[
            _RiskCard(
              risk: risks[i],
              expanded: expandedId == risks[i].id,
              onToggle: () => onToggle(risks[i].id),
              onEdit: () => onEdit(risks[i]),
              onDelete: () => onDelete(risks[i]),
            ),
            if (i != risks.length - 1) const SizedBox(height: Spacing.md),
          ],
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

class _JarvisAlertCard extends StatelessWidget {
  final String insight;
  const _JarvisAlertCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: gold.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(BorderValues.md),
        boxShadow: [
          BoxShadow(color: goldGlow.withOpacity(0.25), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A1405), Color(0xFF2A2008)]),
              border: Border.all(color: gold),
              borderRadius: BorderRadius.circular(BorderValues.sm),
              boxShadow: [BoxShadow(color: goldGlow.withOpacity(0.5), blurRadius: 8)],
            ),
            child: const Icon(Icons.psychology_outlined, color: gold, size: 18),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'JARVIS ALERT',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: gold,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    _LiveDot(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  insight,
                  style: GoogleFonts.rajdhani(
                    color: textPrimary,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dangerColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.4 + 0.5 * t), blurRadius: 6 + 4 * t)],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: dangerColor,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RiskCard extends StatelessWidget {
  final RiskModel risk;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RiskCard({
    required this.risk,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _color => severityColor(risk.severity);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: bgTertiary,
            border: Border.all(color: expanded ? _color : goldLine),
            borderRadius: BorderRadius.circular(BorderValues.md),
            boxShadow: expanded
                ? [BoxShadow(color: _color.withOpacity(0.25), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 36,
                    margin: const EdgeInsets.only(right: Spacing.md, top: 2),
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 6)],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          risk.title,
                          style: GoogleFonts.rajdhani(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          risk.description,
                          maxLines: expanded ? null : 2,
                          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: GoogleFonts.rajdhani(
                            color: textMid,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: textDim,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _SeverityChip(severity: risk.severity),
                  for (final t in risk.tags) _PillTag(label: t.toUpperCase(), color: gold),
                  if (risk.owner != null)
                    _PillTag(
                      label: risk.owner!.toUpperCase(),
                      color: textMid,
                      icon: Icons.person_outline,
                    ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: Spacing.md),
                const Divider(color: goldLine, height: 1),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    _SmallActionButton(
                      icon: Icons.edit_outlined,
                      label: 'EDIT',
                      onTap: onEdit,
                    ),
                    const SizedBox(width: Spacing.sm),
                    _SmallActionButton(
                      icon: Icons.delete_outline,
                      label: 'REMOVE',
                      color: dangerColor,
                      onTap: onDelete,
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(risk.createdAt),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: textDim,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right panel — Weekly report + search + active risks
// ---------------------------------------------------------------------------

class _WeeklyReportPanel extends StatelessWidget {
  final List<RiskModel> risks;
  final List<_SearchHit> hits;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;

  const _WeeklyReportPanel({
    required this.risks,
    required this.hits,
    required this.query,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportHeader(),
        const SizedBox(height: Spacing.md),
        _KpiGrid(risks: risks),
        const SizedBox(height: Spacing.lg),
        _GlobalSearchCard(
          controller: searchController,
          query: query,
          hits: hits,
          onQueryChanged: onQueryChanged,
          onClear: onClearSearch,
        ),
        const SizedBox(height: Spacing.lg),
        _ActiveRisksSummary(risks: risks),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

class _ReportHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment_outlined, color: gold, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                'WEEKLY REPORT — APR 14–19, 2026',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: gold,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '[ JARVIS AUTO-GENERATED ]',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: textDim,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<RiskModel> risks;
  const _KpiGrid({required this.risks});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 360
            ? 2
            : (constraints.maxWidth < 560 ? 3 : 5);
        final spacing = Spacing.sm;
        final tileWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;

        final items = [
          _Kpi(value: '18', label: 'TASKS CLOSED', color: okColor),
          _Kpi(value: '3', label: 'STILL OPEN', color: warnColor),
          _Kpi(value: '73%', label: 'WEEK SCORE', color: gold),
          _Kpi(value: '${risks.length}', label: 'RISKS RAISED', color: dangerColor),
          _Kpi(value: '4', label: 'DECISIONS', color: blueColor),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(width: tileWidth, child: item),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Kpi({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: textDim,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _GlobalSearchCard extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final List<_SearchHit> hits;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  const _GlobalSearchCard({
    required this.controller,
    required this.query,
    required this.hits,
    required this.onQueryChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final showResults = query.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore_outlined, color: gold, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                'GLOBAL SEARCH',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: gold,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              onChanged: onQueryChanged,
              style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search tasks, notes, people, decisions',
                prefixIcon: const Icon(Icons.search, color: textDim, size: 16),
                suffixIcon: showResults
                    ? IconButton(
                        icon: const Icon(Icons.close, color: textDim, size: 14),
                        onPressed: onClear,
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
          ),
          if (showResults) ...[
            const SizedBox(height: Spacing.sm),
            if (hits.isEmpty)
              _EmptyBox(label: 'No matches for "$query".', dense: true)
            else
              Column(
                children: [
                  for (final h in hits) _SearchResultTile(hit: h),
                ],
              ),
          ] else ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'Try "IMAS", "AgriPulse", "Arjun"…',
              style: GoogleFonts.rajdhani(color: textDim, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final _SearchHit hit;
  const _SearchResultTile({required this.hit});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('${hit.kind.label}: ${hit.title}'),
              duration: const Duration(milliseconds: 1500),
            ));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: bgQuaternary,
            border: Border.all(color: goldLine),
            borderRadius: BorderRadius.circular(BorderValues.sm),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: hit.kind.color.withOpacity(0.15),
                  border: Border.all(color: hit.kind.color.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(BorderValues.xs),
                ),
                child: Icon(hit.kind.icon, color: hit.kind.color, size: 14),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.title,
                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      hit.meta,
                      style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hit.kind.color.withOpacity(0.12),
                  border: Border.all(color: hit.kind.color.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(BorderValues.xs),
                ),
                child: Text(
                  hit.kind.label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: hit.kind.color,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveRisksSummary extends StatelessWidget {
  final List<RiskModel> risks;
  const _ActiveRisksSummary({required this.risks});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_outlined, color: gold, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                'RISK RADAR — ACTIVE RISKS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: gold,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          if (risks.isEmpty)
            _EmptyBox(label: 'No active risks.', dense: true)
          else
            for (final r in risks)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: severityColor(r.severity),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: severityColor(r.severity).withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: GoogleFonts.rajdhani(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            r.severity.label,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              color: severityColor(r.severity),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Misc widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final int count;
  const _SectionHeader({required this.eyebrow, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: textDim,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 22,
                color: goldLight,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: bgQuaternary,
            border: Border.all(color: goldLine),
            borderRadius: BorderRadius.circular(BorderValues.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  color: textDim,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$count',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final RiskSeverity severity;
  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final c = severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        border: Border.all(color: c),
        borderRadius: BorderRadius.circular(BorderValues.xs),
      ),
      child: Text(
        severity.label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          color: c,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _PillTag({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(BorderValues.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: color,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _SmallActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? gold;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: c.withOpacity(_hover ? 0.18 : 0.08),
            border: Border.all(color: c.withOpacity(_hover ? 1.0 : 0.6)),
            borderRadius: BorderRadius.circular(BorderValues.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: c, size: 12),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: c,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskFab extends StatefulWidget {
  final VoidCallback onTap;
  const _RiskFab({required this.onTap});

  @override
  State<_RiskFab> createState() => _RiskFabState();
}

class _RiskFabState extends State<_RiskFab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF1A1405), Color(0xFF2A2008)]),
            border: Border.all(color: gold, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: goldGlow.withOpacity(_hover ? 0.7 : 0.45),
                blurRadius: _hover ? 18 : 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: gold, size: 28),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String label;
  final bool dense;
  const _EmptyBox({required this.label, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: dense ? Spacing.md : Spacing.xxl),
      decoration: BoxDecoration(
        color: bgQuaternary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.sm),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.rajdhani(color: textDim, fontSize: 12),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit Risk dialog
// ---------------------------------------------------------------------------

class _RiskFormResult {
  final String title;
  final String description;
  final RiskSeverity severity;
  final List<String> tags;
  final String? owner;
  _RiskFormResult({
    required this.title,
    required this.description,
    required this.severity,
    required this.tags,
    this.owner,
  });
}

class _RiskFormDialog extends StatefulWidget {
  final RiskModel? initial;
  const _RiskFormDialog({this.initial});

  @override
  State<_RiskFormDialog> createState() => _RiskFormDialogState();
}

class _RiskFormDialogState extends State<_RiskFormDialog> {
  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.initial?.description ?? '');
  late final TextEditingController _tags =
      TextEditingController(text: widget.initial?.tags.join(', ') ?? '');
  late final TextEditingController _owner =
      TextEditingController(text: widget.initial?.owner ?? '');
  late RiskSeverity _severity = widget.initial?.severity ?? RiskSeverity.monitor;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _tags.dispose();
    _owner.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    Navigator.pop(
      context,
      _RiskFormResult(
        title: title,
        description: _desc.text.trim(),
        severity: _severity,
        tags: _tags.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        owner: _owner.text.trim().isEmpty ? null : _owner.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return AlertDialog(
      backgroundColor: bgTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BorderValues.md),
        side: const BorderSide(color: goldLine),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: gold, size: 16),
          const SizedBox(width: Spacing.xs),
          Text(
            isEdit ? 'EDIT RISK' : 'ADD RISK',
            style: GoogleFonts.orbitron(
              color: gold,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('TITLE'),
              TextField(
                controller: _title,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Short, specific risk title'),
              ),
              const SizedBox(height: Spacing.md),
              _label('DESCRIPTION'),
              TextField(
                controller: _desc,
                minLines: 2,
                maxLines: 5,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                decoration: const InputDecoration(hintText: 'What is at risk and why?'),
              ),
              const SizedBox(height: Spacing.md),
              _label('SEVERITY'),
              const SizedBox(height: 4),
              Wrap(
                spacing: Spacing.xs,
                children: [
                  for (final s in RiskSeverity.values)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _severity = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _severity == s
                                ? severityColor(s).withOpacity(0.18)
                                : bgQuaternary,
                            border: Border.all(
                              color: _severity == s ? severityColor(s) : goldLine,
                            ),
                            borderRadius: BorderRadius.circular(BorderValues.sm),
                          ),
                          child: Text(
                            s.label,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: _severity == s ? severityColor(s) : textDim,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              _label('TAGS (COMMA SEPARATED)'),
              TextField(
                controller: _tags,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                decoration: const InputDecoration(hintText: 'e.g. IMAS, infra, milestone'),
              ),
              const SizedBox(height: Spacing.md),
              _label('OWNER (OPTIONAL)'),
              TextField(
                controller: _owner,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                decoration: const InputDecoration(hintText: 'e.g. Arjun Mehta'),
              ),
              if (_error != null) ...[
                const SizedBox(height: Spacing.sm),
                Text(_error!, style: TextStyle(color: dangerColor, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: textDim)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            isEdit ? 'SAVE' : 'ADD TO RADAR',
            style: const TextStyle(color: gold),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: textDim,
            letterSpacing: 1.5,
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color severityColor(RiskSeverity s) {
  switch (s) {
    case RiskSeverity.critical:
      return dangerColor;
    case RiskSeverity.overdue:
      return warnColor;
    case RiskSeverity.monitor:
      return gold;
    case RiskSeverity.plan:
      return blueColor;
  }
}

String _formatTime(DateTime t) {
  final now = DateTime.now();
  final diff = now.difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final mm = t.month.toString().padLeft(2, '0');
  final dd = t.day.toString().padLeft(2, '0');
  return '${t.year}-$mm-$dd';
}
