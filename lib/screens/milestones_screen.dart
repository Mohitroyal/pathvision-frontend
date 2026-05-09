// lib/screens/milestones_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/milestone_model.dart';
import '../providers/milestone_provider.dart';
import '../providers/project_provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  String? _selectedMilestoneId;

  // Gantt sizing constants
  static const double _rowLabelWidth = 180;
  static const double _rowHeight = 40;
  static const double _projectHeaderHeight = 32;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1500)));
  }

  Future<void> _openAddMilestoneDialog() async {
    final provider = context.read<MilestoneProvider>();
    final result = await showDialog<_MilestoneFormResult>(
      context: context,
      builder: (_) => _MilestoneFormDialog(projects: provider.projects),
    );
    if (result == null) return;
    provider.addMilestone(
      title: result.title,
      project: result.project,
      start: result.start,
      end: result.end,
      status: result.status,
    );
    if (mounted) _toast('Milestone added.');
  }

  Future<void> _openAddCohortDialog() async {
    final provider = context.read<MilestoneProvider>();
    final result = await showDialog<_CohortFormResult>(
      context: context,
      builder: (_) => const _CohortFormDialog(),
    );
    if (result == null) return;
    provider.addCohort(
      name: result.name,
      start: result.start,
      end: result.end,
      status: result.status,
      memberInitials: result.members,
    );
    if (mounted) _toast('Cohort added.');
  }

  Future<void> _openMilestoneDetails(MilestoneModel m) async {
    final next = await showDialog<MilestoneStatus?>(
      context: context,
      builder: (ctx) => _MilestoneDetailsDialog(milestone: m),
    );
    if (next == null) return;
    context.read<MilestoneProvider>().updateMilestoneStatus(m.id, next);
    if (mounted) _toast('Status updated to ${next.label}.');
  }

  void _adjustGoal(GoalModel g, double delta) {
    context.read<MilestoneProvider>().updateGoalProgress(g.id, g.progress + delta);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;
    final provider = context.watch<MilestoneProvider>();

    return Scaffold(
      appBar: JarvisTopbar(
        title: 'MILESTONE TIMELINE — GANTT VIEW',
        actions: [
          if (provider.imasAtRisk) const _AtRiskBadge(label: 'IMAS AT RISK'),
          _PrimaryActionButton(
            icon: Icons.add,
            label: '+ MILESTONE',
            onTap: _openAddMilestoneDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? Spacing.xl : Spacing.lg),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: _LeftPanel(
                      goals: provider.goals,
                      cohorts: provider.cohorts,
                      onAddCohort: _openAddCohortDialog,
                      onAdjustGoal: _adjustGoal,
                    ),
                  ),
                  const SizedBox(width: Spacing.xl),
                  Expanded(
                    child: _GanttPanel(
                      provider: provider,
                      selectedId: _selectedMilestoneId,
                      onSelect: (id) => setState(() => _selectedMilestoneId = id),
                      onMilestoneTap: _openMilestoneDetails,
                      rowLabelWidth: _rowLabelWidth,
                      rowHeight: _rowHeight,
                      projectHeaderHeight: _projectHeaderHeight,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GanttPanel(
                    provider: provider,
                    selectedId: _selectedMilestoneId,
                    onSelect: (id) => setState(() => _selectedMilestoneId = id),
                    onMilestoneTap: _openMilestoneDetails,
                    rowLabelWidth: 140,
                    rowHeight: _rowHeight,
                    projectHeaderHeight: _projectHeaderHeight,
                  ),
                  const SizedBox(height: Spacing.xl),
                  _LeftPanel(
                    goals: provider.goals,
                    cohorts: provider.cohorts,
                    onAddCohort: _openAddCohortDialog,
                    onAdjustGoal: _adjustGoal,
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEFT PANEL — Goals + Cohorts
// ---------------------------------------------------------------------------

class _LeftPanel extends StatelessWidget {
  final List<GoalModel> goals;
  final List<CohortModel> cohorts;
  final VoidCallback onAddCohort;
  final void Function(GoalModel goal, double delta) onAdjustGoal;

  const _LeftPanel({
    required this.goals,
    required this.cohorts,
    required this.onAddCohort,
    required this.onAdjustGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(text: 'Q2 GOALS'),
        const SizedBox(height: Spacing.sm),
        for (int i = 0; i < goals.length; i++) ...[
          _GoalCard(
            goal: goals[i],
            onIncrement: () => onAdjustGoal(goals[i], 0.05),
            onDecrement: () => onAdjustGoal(goals[i], -0.05),
          ),
          if (i != goals.length - 1) const SizedBox(height: Spacing.sm),
        ],
        const SizedBox(height: Spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(text: 'COHORTS'),
            _MiniButton(label: '+ COHORT', onTap: onAddCohort),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        for (int i = 0; i < cohorts.length; i++) ...[
          _CohortCard(cohort: cohorts[i]),
          if (i != cohorts.length - 1) const SizedBox(height: Spacing.sm),
        ],
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        color: textDim,
        letterSpacing: 2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _GoalCard({required this.goal, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    final color = _goalStatusColor(goal.status);
    final pct = (goal.progress * 100).round();

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
              Expanded(
                child: Text(
                  goal.title,
                  style: GoogleFonts.rajdhani(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(label: goal.status.label, color: color),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(BorderValues.xs),
            child: Stack(
              children: [
                Container(height: 8, color: bgQuaternary),
                FractionallySizedBox(
                  widthFactor: goal.progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color],
                      ),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _MiniIcon(icon: Icons.remove, onTap: onDecrement),
              const SizedBox(width: 4),
              _MiniIcon(icon: Icons.add, onTap: onIncrement),
            ],
          ),
          if (goal.note != null) ...[
            const SizedBox(height: 6),
            Text(
              goal.note!,
              style: GoogleFonts.rajdhani(color: textDim, fontSize: 11, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

class _CohortCard extends StatelessWidget {
  final CohortModel cohort;
  const _CohortCard({required this.cohort});

  @override
  Widget build(BuildContext context) {
    final color = _cohortStatusColor(cohort.status);
    final dim = cohort.status == CohortStatus.archived;

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
              Expanded(
                child: Text(
                  cohort.name,
                  style: GoogleFonts.rajdhani(
                    color: dim ? textDim : textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(label: cohort.status.label, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_monthAbbrev(cohort.start.month)} – ${_monthAbbrev(cohort.end.month)} ${cohort.end.year}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: textDim,
              letterSpacing: 1.2,
            ),
          ),
          if (cohort.memberInitials.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            SizedBox(
              height: 24,
              child: Stack(
                children: [
                  for (int i = 0; i < cohort.memberInitials.length && i < 6; i++)
                    Positioned(
                      left: i * 18.0,
                      child: _Avatar(
                        initials: cohort.memberInitials[i],
                        dim: dim,
                      ),
                    ),
                  if (cohort.memberInitials.length > 6)
                    Positioned(
                      left: 6 * 18.0,
                      child: _Avatar(
                        initials: '+${cohort.memberInitials.length - 6}',
                        dim: dim,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final bool dim;
  const _Avatar({required this.initials, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dim ? bgQuint : bgQuaternary,
        border: Border.all(color: dim ? textDim.withOpacity(0.4) : gold.withOpacity(0.6)),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            color: dim ? textDim : goldLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GANTT PANEL
// ---------------------------------------------------------------------------

class _GanttPanel extends StatelessWidget {
  final MilestoneProvider provider;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final ValueChanged<MilestoneModel> onMilestoneTap;
  final double rowLabelWidth;
  final double rowHeight;
  final double projectHeaderHeight;

  const _GanttPanel({
    required this.provider,
    required this.selectedId,
    required this.onSelect,
    required this.onMilestoneTap,
    required this.rowLabelWidth,
    required this.rowHeight,
    required this.projectHeaderHeight,
  });

  @override
  Widget build(BuildContext context) {
    final start = provider.timelineStart;
    final end = provider.timelineEnd;
    final months = _monthsBetween(start, end);
    final totalDays = end.difference(start).inDays + 1;

    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Reserve a minimum width per month so the chart looks like a Gantt.
          const minPerMonth = 110.0;
          final innerWidth = constraints.maxWidth - rowLabelWidth - 2;
          final monthWidth = (innerWidth / months.length).clamp(minPerMonth, double.infinity);
          final ganttWidth = monthWidth * months.length;
          final needsHScroll = ganttWidth > innerWidth;

          final header = _GanttHeader(
            months: months,
            monthWidth: monthWidth,
            rowLabelWidth: rowLabelWidth,
          );

          final projectProvider = context.watch<ProjectProvider>();
          final allProjectNames = projectProvider.projects.map((p) => p.name).toList();
          
          // Also include project names from milestones that might not be in ProjectProvider (fallback)
          for (final pName in provider.projects) {
            if (!allProjectNames.contains(pName)) allProjectNames.add(pName);
          }

          final rows = <Widget>[];
          for (final project in allProjectNames) {
            rows.add(_ProjectHeaderRow(
              name: project,
              height: projectHeaderHeight,
              labelWidth: rowLabelWidth,
              ganttWidth: ganttWidth,
              monthWidth: monthWidth,
              monthsCount: months.length,
            ));
            for (final m in provider.milestonesForProject(project)) {
              rows.add(_GanttRow(
                milestone: m,
                isSelected: selectedId == m.id,
                onSelect: () => onSelect(m.id),
                onTap: () => onMilestoneTap(m),
                rowLabelWidth: rowLabelWidth,
                rowHeight: rowHeight,
                monthWidth: monthWidth,
                monthsCount: months.length,
                timelineStart: start,
                totalDays: totalDays,
              ));
            }
          }
          // Cohorts as a sub-section
          rows.add(_ProjectHeaderRow(
            name: 'INTERN COHORTS',
            height: projectHeaderHeight,
            labelWidth: rowLabelWidth,
            ganttWidth: ganttWidth,
            monthWidth: monthWidth,
            monthsCount: months.length,
          ));
          for (final c in provider.cohorts.where((c) => c.status != CohortStatus.archived)) {
            rows.add(_CohortGanttRow(
              cohort: c,
              rowLabelWidth: rowLabelWidth,
              rowHeight: rowHeight,
              monthWidth: monthWidth,
              monthsCount: months.length,
              timelineStart: start,
              totalDays: totalDays,
            ));
          }

          final body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const Divider(color: goldLine, height: 1),
              ...rows,
            ],
          );

          if (needsHScroll) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: rowLabelWidth + ganttWidth + 2,
                child: body,
              ),
            );
          }
          return body;
        },
      ),
    );
  }
}

class _GanttHeader extends StatelessWidget {
  final List<DateTime> months;
  final double monthWidth;
  final double rowLabelWidth;

  const _GanttHeader({
    required this.months,
    required this.monthWidth,
    required this.rowLabelWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: rowLabelWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: Spacing.md),
              child: Text(
                'PROJECT / MILESTONE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: textDim,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          for (final m in months)
            SizedBox(
              width: monthWidth,
              child: Center(
                child: Text(
                  _monthAbbrev(m.month).toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: gold,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectHeaderRow extends StatelessWidget {
  final String name;
  final double height;
  final double labelWidth;
  final double ganttWidth;
  final double monthWidth;
  final int monthsCount;

  const _ProjectHeaderRow({
    required this.name,
    required this.height,
    required this.labelWidth,
    required this.ganttWidth,
    required this.monthWidth,
    required this.monthsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgQuaternary,
        border: const Border(bottom: BorderSide(color: goldLine, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: gold, size: 12),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: gold,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: ganttWidth,
            child: CustomPaint(
              painter: _GridPainter(
                cols: monthsCount,
                colWidth: monthWidth,
                color: goldLine.withOpacity(0.4),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttRow extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onTap;
  final double rowLabelWidth;
  final double rowHeight;
  final double monthWidth;
  final int monthsCount;
  final DateTime timelineStart;
  final int totalDays;

  const _GanttRow({
    required this.milestone,
    required this.isSelected,
    required this.onSelect,
    required this.onTap,
    required this.rowLabelWidth,
    required this.rowHeight,
    required this.monthWidth,
    required this.monthsCount,
    required this.timelineStart,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final color = milestoneColor(milestone.status);
    final ganttWidth = monthWidth * monthsCount;
    final startOffset = milestone.start.difference(timelineStart).inDays.clamp(0, totalDays);
    final endOffset = milestone.end.difference(timelineStart).inDays.clamp(0, totalDays);
    final durationDays = (endOffset - startOffset).clamp(1, totalDays);

    final left = startOffset / totalDays * ganttWidth;
    final width = (durationDays / totalDays * ganttWidth).clamp(8.0, ganttWidth);

    final isPoint = milestone.end.difference(milestone.start).inDays <= 1;

    return Container(
      height: rowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: goldLine, width: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: rowLabelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  Container(width: 4, height: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestone.title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: ganttWidth,
            child: Stack(
              children: [
                CustomPaint(
                  painter: _GridPainter(
                    cols: monthsCount,
                    colWidth: monthWidth,
                    color: goldLine.withOpacity(0.25),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: left,
                  top: 6,
                  bottom: 6,
                  width: width,
                  child: Tooltip(
                    message:
                        '${milestone.title}\n${_fmtDate(milestone.start)} → ${_fmtDate(milestone.end)}\n${milestone.status.label}',
                    waitDuration: const Duration(milliseconds: 250),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          onSelect();
                          onTap();
                        },
                        child: isPoint
                            ? _MilestoneDiamond(color: color)
                            : _MilestoneBar(
                                color: color,
                                title: milestone.title,
                                isSelected: isSelected,
                                statusLabel: milestone.status.label,
                              ),
                      ),
                    ),
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

class _CohortGanttRow extends StatelessWidget {
  final CohortModel cohort;
  final double rowLabelWidth;
  final double rowHeight;
  final double monthWidth;
  final int monthsCount;
  final DateTime timelineStart;
  final int totalDays;

  const _CohortGanttRow({
    required this.cohort,
    required this.rowLabelWidth,
    required this.rowHeight,
    required this.monthWidth,
    required this.monthsCount,
    required this.timelineStart,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final color = _cohortStatusColor(cohort.status);
    final ganttWidth = monthWidth * monthsCount;

    final clampedStart = cohort.start.isBefore(timelineStart) ? timelineStart : cohort.start;
    final timelineEnd = timelineStart.add(Duration(days: totalDays - 1));
    final clampedEnd = cohort.end.isAfter(timelineEnd) ? timelineEnd : cohort.end;

    if (clampedEnd.isBefore(clampedStart)) {
      return SizedBox(height: rowHeight);
    }

    final startOffset = clampedStart.difference(timelineStart).inDays.clamp(0, totalDays);
    final endOffset = clampedEnd.difference(timelineStart).inDays.clamp(0, totalDays);
    final durationDays = (endOffset - startOffset).clamp(1, totalDays);
    final left = startOffset / totalDays * ganttWidth;
    final width = (durationDays / totalDays * ganttWidth).clamp(8.0, ganttWidth);

    return Container(
      height: rowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: goldLine, width: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: rowLabelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  Container(width: 4, height: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cohort.name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: ganttWidth,
            child: Stack(
              children: [
                CustomPaint(
                  painter: _GridPainter(
                    cols: monthsCount,
                    colWidth: monthWidth,
                    color: goldLine.withOpacity(0.25),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: left,
                  top: 8,
                  bottom: 8,
                  width: width,
                  child: Tooltip(
                    message:
                        '${cohort.name}\n${_fmtDate(cohort.start)} → ${_fmtDate(cohort.end)}\n${cohort.status.label}',
                    waitDuration: const Duration(milliseconds: 250),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        border: Border.all(color: color.withOpacity(0.7), style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(BorderValues.sm),
                      ),
                      child: Center(
                        child: Text(
                          cohort.status.label,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            color: color,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
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

class _MilestoneBar extends StatelessWidget {
  final Color color;
  final String title;
  final bool isSelected;
  final String statusLabel;

  const _MilestoneBar({
    required this.color,
    required this.title,
    required this.isSelected,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color],
        ),
        borderRadius: BorderRadius.circular(BorderValues.sm),
        border: Border.all(color: isSelected ? Colors.white : color.withOpacity(0.8), width: isSelected ? 1.4 : 0.8),
        boxShadow: [
          BoxShadow(color: color.withOpacity(isSelected ? 0.6 : 0.35), blurRadius: isSelected ? 10 : 5),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: Colors.black.withOpacity(0.85),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneDiamond extends StatelessWidget {
  final Color color;
  const _MilestoneDiamond({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: 0.785398, // 45 deg
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int cols;
  final double colWidth;
  final Color color;

  _GridPainter({required this.cols, required this.colWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.6;
    for (int i = 1; i < cols; i++) {
      final x = i * colWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.cols != cols || oldDelegate.colWidth != colWidth || oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Topbar — At Risk badge + primary action
// ---------------------------------------------------------------------------

class _AtRiskBadge extends StatelessWidget {
  final String label;
  const _AtRiskBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(0.15),
        border: Border.all(color: dangerColor),
        borderRadius: BorderRadius.circular(BorderValues.sm),
        boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.4), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: dangerColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: dangerColor,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionButton({required this.icon, required this.label, required this.onTap});

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? const [Color(0xFF2A2008), Color(0xFF3A2D0C)]
                  : const [Color(0xFF1A1405), Color(0xFF2A2008)],
            ),
            border: Border.all(color: gold),
            borderRadius: BorderRadius.circular(BorderValues.sm),
            boxShadow: [
              BoxShadow(color: goldGlow.withOpacity(_hover ? 0.6 : 0.4), blurRadius: _hover ? 10 : 6),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: goldLight,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: gold),
            borderRadius: BorderRadius.circular(BorderValues.sm),
            color: gold.withOpacity(0.08),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: goldLight,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: gold.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(BorderValues.xs),
            color: gold.withOpacity(0.1),
          ),
          child: Icon(icon, color: gold, size: 12),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(BorderValues.xs),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          color: color,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Milestone dialog
// ---------------------------------------------------------------------------

class _MilestoneFormResult {
  final String title;
  final String project;
  final DateTime start;
  final DateTime end;
  final MilestoneStatus status;
  _MilestoneFormResult({
    required this.title,
    required this.project,
    required this.start,
    required this.end,
    required this.status,
  });
}

class _MilestoneFormDialog extends StatefulWidget {
  final List<String> projects;
  const _MilestoneFormDialog({required this.projects});

  @override
  State<_MilestoneFormDialog> createState() => _MilestoneFormDialogState();
}

class _MilestoneFormDialogState extends State<_MilestoneFormDialog> {
  final _title = TextEditingController();
  late String _project;

  @override
  void initState() {
    super.initState();
    _project = widget.projects.isNotEmpty ? widget.projects.first : 'General';
  }
  DateTime _start = DateTime(2026, 4, 1);
  DateTime _end = DateTime(2026, 4, 14);
  MilestoneStatus _status = MilestoneStatus.planned;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: gold,
              onPrimary: bgPrimary,
              surface: bgTertiary,
              onSurface: textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 7));
      } else {
        _end = picked;
      }
    });
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    if (_end.isBefore(_start)) {
      setState(() => _error = 'End date must be after start.');
      return;
    }
    Navigator.pop(
      context,
      _MilestoneFormResult(
        title: title,
        project: _project,
        start: _start,
        end: _end,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BorderValues.md),
        side: const BorderSide(color: goldLine),
      ),
      title: Row(
        children: [
          const Icon(Icons.flag_outlined, color: gold, size: 16),
          const SizedBox(width: Spacing.xs),
          Text(
            'ADD MILESTONE',
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
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('TITLE'),
              TextField(
                controller: _title,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g. Beta Testing'),
              ),
              const SizedBox(height: Spacing.md),
              _label('PROJECT'),
              DropdownButtonFormField<String>(
                value: _project,
                dropdownColor: bgQuaternary,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                items: [
                  if (widget.projects.isEmpty)
                    const DropdownMenuItem(value: 'General', child: Text('General'))
                  else
                    for (final p in widget.projects)
                      DropdownMenuItem(value: p, child: Text(p)),
                ],
                onChanged: (v) => setState(() => _project = v ?? _project),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(child: _DatePickField(label: 'START', date: _start, onTap: () => _pickDate(true))),
                  const SizedBox(width: Spacing.sm),
                  Expanded(child: _DatePickField(label: 'END', date: _end, onTap: () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: Spacing.md),
              _label('STATUS'),
              const SizedBox(height: 4),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  for (final s in MilestoneStatus.values)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _status == s ? milestoneColor(s).withOpacity(0.18) : bgQuaternary,
                            border: Border.all(color: _status == s ? milestoneColor(s) : goldLine),
                            borderRadius: BorderRadius.circular(BorderValues.sm),
                          ),
                          child: Text(
                            s.label,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: _status == s ? milestoneColor(s) : textDim,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
          child: const Text('ADD MILESTONE', style: TextStyle(color: gold)),
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

class _DatePickField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 8),
          decoration: BoxDecoration(
            color: bgQuaternary,
            border: Border.all(color: goldLine),
            borderRadius: BorderRadius.circular(BorderValues.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  color: textDim,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: gold, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _fmtDate(date),
                    style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
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

// ---------------------------------------------------------------------------
// Milestone details dialog (status change)
// ---------------------------------------------------------------------------

class _MilestoneDetailsDialog extends StatefulWidget {
  final MilestoneModel milestone;
  const _MilestoneDetailsDialog({required this.milestone});

  @override
  State<_MilestoneDetailsDialog> createState() => _MilestoneDetailsDialogState();
}

class _MilestoneDetailsDialogState extends State<_MilestoneDetailsDialog> {
  late MilestoneStatus _status = widget.milestone.status;

  @override
  Widget build(BuildContext context) {
    final m = widget.milestone;
    final color = milestoneColor(_status);
    return AlertDialog(
      backgroundColor: bgTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BorderValues.md),
        side: const BorderSide(color: goldLine),
      ),
      title: Row(
        children: [
          Container(width: 4, height: 18, color: color),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              m.title.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: gold,
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('PROJECT', m.project),
            const SizedBox(height: 6),
            _detailRow('START', _fmtDate(m.start)),
            const SizedBox(height: 6),
            _detailRow('END', _fmtDate(m.end)),
            const SizedBox(height: Spacing.md),
            Text(
              'CHANGE STATUS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: textDim,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final s in MilestoneStatus.values)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _status = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _status == s ? milestoneColor(s).withOpacity(0.18) : bgQuaternary,
                          border: Border.all(color: _status == s ? milestoneColor(s) : goldLine),
                          borderRadius: BorderRadius.circular(BorderValues.sm),
                        ),
                        child: Text(
                          s.label,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: _status == s ? milestoneColor(s) : textDim,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('CLOSE', style: TextStyle(color: textDim)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _status),
          child: const Text('SAVE', style: TextStyle(color: gold)),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: textDim,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add Cohort dialog
// ---------------------------------------------------------------------------

class _CohortFormResult {
  final String name;
  final DateTime start;
  final DateTime end;
  final CohortStatus status;
  final List<String> members;
  _CohortFormResult({
    required this.name,
    required this.start,
    required this.end,
    required this.status,
    required this.members,
  });
}

class _CohortFormDialog extends StatefulWidget {
  const _CohortFormDialog();

  @override
  State<_CohortFormDialog> createState() => _CohortFormDialogState();
}

class _CohortFormDialogState extends State<_CohortFormDialog> {
  final _name = TextEditingController();
  final _members = TextEditingController();
  DateTime _start = DateTime(2026, 5, 1);
  DateTime _end = DateTime(2026, 8, 31);
  CohortStatus _status = CohortStatus.planned;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _members.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: gold,
            onPrimary: bgPrimary,
            surface: bgTertiary,
            onSurface: textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 30));
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BorderValues.md),
        side: const BorderSide(color: goldLine),
      ),
      title: Row(
        children: [
          const Icon(Icons.groups_outlined, color: gold, size: 16),
          const SizedBox(width: Spacing.xs),
          Text(
            'ADD COHORT',
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
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('NAME'),
              TextField(
                controller: _name,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g. Cohort 3'),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(child: _DatePickField(label: 'START', date: _start, onTap: () => _pickDate(true))),
                  const SizedBox(width: Spacing.sm),
                  Expanded(child: _DatePickField(label: 'END', date: _end, onTap: () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: Spacing.md),
              _label('STATUS'),
              const SizedBox(height: 4),
              Wrap(
                spacing: Spacing.xs,
                children: [
                  for (final s in CohortStatus.values)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _status == s ? _cohortStatusColor(s).withOpacity(0.18) : bgQuaternary,
                            border: Border.all(color: _status == s ? _cohortStatusColor(s) : goldLine),
                            borderRadius: BorderRadius.circular(BorderValues.sm),
                          ),
                          child: Text(
                            s.label,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: _status == s ? _cohortStatusColor(s) : textDim,
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
              _label('MEMBER INITIALS (COMMA SEPARATED)'),
              TextField(
                controller: _members,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                decoration: const InputDecoration(hintText: 'e.g. AM, RK, PS'),
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
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              setState(() => _error = 'Name is required.');
              return;
            }
            if (_end.isBefore(_start)) {
              setState(() => _error = 'End date must be after start.');
              return;
            }
            final members = _members.text
                .split(',')
                .map((s) => s.trim().toUpperCase())
                .where((s) => s.isNotEmpty)
                .toList();
            Navigator.pop(
              context,
              _CohortFormResult(
                name: name,
                start: _start,
                end: _end,
                status: _status,
                members: members,
              ),
            );
          },
          child: const Text('ADD COHORT', style: TextStyle(color: gold)),
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

Color milestoneColor(MilestoneStatus s) {
  switch (s) {
    case MilestoneStatus.done:
      return incomeLight;
    case MilestoneStatus.inProgress:
      return warnColor;
    case MilestoneStatus.planned:
      return blueColor;
    case MilestoneStatus.planning:
      return purpleColor;
    case MilestoneStatus.atRisk:
      return dangerColor;
  }
}

Color _cohortStatusColor(CohortStatus s) {
  switch (s) {
    case CohortStatus.active:
      return incomeLight;
    case CohortStatus.planned:
      return blueColor;
    case CohortStatus.archived:
      return textDim;
  }
}

Color _goalStatusColor(GoalStatus s) {
  switch (s) {
    case GoalStatus.onTrack:
      return incomeLight;
    case GoalStatus.atRisk:
      return dangerColor;
    case GoalStatus.planNeeded:
      return blueColor;
    case GoalStatus.done:
      return gold;
  }
}

List<DateTime> _monthsBetween(DateTime start, DateTime end) {
  final months = <DateTime>[];
  var cur = DateTime(start.year, start.month, 1);
  final last = DateTime(end.year, end.month, 1);
  while (!cur.isAfter(last)) {
    months.add(cur);
    cur = DateTime(cur.year, cur.month + 1, 1);
  }
  return months;
}

String _monthAbbrev(int month) {
  const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return names[(month - 1) % 12];
}

String _fmtDate(DateTime d) {
  final mm = _monthAbbrev(d.month);
  final dd = d.day.toString().padLeft(2, '0');
  return '$mm $dd, ${d.year}';
}
