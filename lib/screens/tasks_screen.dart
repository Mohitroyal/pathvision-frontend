// lib/screens/tasks_screen.dart
// Kanban Task Engine — single-file implementation

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/pinned_provider.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Filters
  String projectFilter = 'ALL';
  String deptFilter = 'ALL';

  // Simple user list for avatars
  final List<Map<String, String>> users = [
    {'name': 'Aman Mehta', 'initials': 'AM'},
    {'name': 'Nikhil Kumar', 'initials': 'NK'},
    {'name': 'Priya Singh', 'initials': 'PS'},
  ];

  // Local mapping for avatar colors
  final Map<String, Color> avatarColors = {
    'AM': purpleColor,
    'NK': blueColor,
    'PS': gold,
  };

  // Column identifiers
  final List<String> columns = ['BACKLOG', 'IN PROGRESS', 'REVIEW', 'DONE'];

  @override
  void initState() {
    super.initState();
    // Data is now fetched automatically by TaskProvider
  }

  // Map task to column key
  String _columnForTask(TaskModel t) {
    if (t.status == TaskStatus.done) return 'DONE';
    if (t.tags.contains('review')) return 'REVIEW';
    if (t.status == TaskStatus.inProgress) return 'IN PROGRESS';
    return 'BACKLOG';
  }

  // On drop, update provider/task tags/status
  void _onDrop(TaskModel task, String targetColumn) {
    final provider = context.read<TaskProvider>();
    if (targetColumn == 'DONE') {
      provider.updateTaskStatus(task.id, TaskStatus.done);
      // remove review tag
      task.tags.remove('review');
    } else if (targetColumn == 'REVIEW') {
      // keep status as inProgress but mark review
      task.tags.removeWhere((t) => t == 'overdue');
      if (!task.tags.contains('review')) task.tags.add('review');
      provider.updateTaskStatus(task.id, TaskStatus.inProgress);
    } else if (targetColumn == 'IN PROGRESS') {
      task.tags.remove('review');
      provider.updateTaskStatus(task.id, TaskStatus.inProgress);
    } else if (targetColumn == 'BACKLOG') {
      task.tags.remove('review');
      provider.updateTaskStatus(task.id, TaskStatus.backlog);
    }
  }

  // Add Task navigation
  void _showAddTaskDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
  }

  // Filter helpers
  bool _passesFilters(TaskModel t) {
    if (projectFilter != 'ALL' && (t.project ?? '') != projectFilter) return false;
    if (deptFilter != 'ALL' && !t.tags.contains(deptFilter)) return false;
    return true;
  }

  // Build column container
  Widget _buildColumn(String key, List<TaskModel> tasks, Color accent) {
    IconData icon;
    switch (key) {
      case 'BACKLOG': icon = Icons.inventory_2_outlined; break;
      case 'IN PROGRESS': icon = Icons.pending_outlined; break;
      case 'REVIEW': icon = Icons.analytics_outlined; break;
      case 'DONE': icon = Icons.task_alt; break;
      default: icon = Icons.folder_outlined;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 14),
                const SizedBox(width: 8),
                Text(
                  key, 
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    border: Border.all(color: accent.withOpacity(0.2), width: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${tasks.length}', 
                    style: GoogleFonts.jetBrainsMono(
                      color: accent, 
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DragTarget<TaskModel>(
              onWillAccept: (t) => true,
              onAccept: (t) => _onDrop(t, key),
              builder: (context, candidateData, rejectedData) {
                if (tasks.isEmpty) {
                  return _buildEmptyPlaceholder(key, accent);
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String key, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.05),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined, 
            color: color.withOpacity(0.1), 
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            'EMPTY',
            style: GoogleFonts.orbitron(
              color: color.withOpacity(0.2),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel t) {
    final initials = t.tags.isNotEmpty ? t.tags.last : 'AM';
    final avatarColor = avatarColors[initials] ?? blueColor;
    final isDone = t.status == TaskStatus.done;

    return LongPressDraggable<TaskModel>(
      data: t,
      axis: Axis.vertical,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.95,
          child: _taskCardContent(t, initials, avatarColor, true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _taskCardContent(t, initials, avatarColor, false)),
      child: InkWell(
        onTap: () => _showTaskDetailDialog(t),
        borderRadius: BorderRadius.circular(8),
        child: _taskCardContent(t, initials, avatarColor, false),
      ),
    );
  }

  void _showTaskDetailDialog(TaskModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgSecondary,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: goldLine),
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                t.title.toUpperCase(),
                style: GoogleFonts.orbitron(color: gold, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _getPriorityColor(t.priority).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(t.priority.name.toUpperCase(), style: TextStyle(color: _getPriorityColor(t.priority), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection('DESCRIPTION', t.description != null && t.description!.isNotEmpty ? t.description! : 'No description provided.'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDetailSection('PROJECT', t.project ?? 'N/A', isGold: true)),
                  Expanded(child: _buildDetailSection('MILESTONE', t.milestone ?? 'N/A')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDetailSection('STATUS', t.status.name.toUpperCase())),
                  Expanded(child: _buildDetailSection('SIZE', t.size.name.toUpperCase())),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailSection(
                      'DUE DATE', 
                      t.dueDate != null ? DateFormat('MMM dd, yyyy').format(t.dueDate!) : 'No deadline',
                      color: t.tags.contains('overdue') ? dangerColor : textPrimary,
                    ),
                  ),
                  Expanded(child: _buildDetailSection('DEPARTMENT', t.department ?? 'N/A')),
                ],
              ),
              if (t.assignedMembers.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('ASSIGNED TO', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: t.assignedMembers.map((m) => Chip(
                    avatar: CircleAvatar(radius: 10, backgroundColor: gold.withOpacity(0.1), child: Text(m[0], style: const TextStyle(color: gold, fontSize: 8))),
                    label: Text(m, style: const TextStyle(color: textPrimary, fontSize: 11)),
                    backgroundColor: bgTertiary,
                    side: BorderSide(color: goldLine.withOpacity(0.2)),
                  )).toList(),
                ),
              ],
              if (t.checklist.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('CHECKLIST', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...t.checklist.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(item.isDone ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: item.isDone ? okColor : textDim),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.title, style: TextStyle(color: item.isDone ? textDim : textPrimary, fontSize: 13, decoration: item.isDone ? TextDecoration.lineThrough : null))),
                    ],
                  ),
                )).toList(),
              ],
              if (t.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('TAGS', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: t.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4), border: Border.all(color: goldLine.withOpacity(0.2))),
                    child: Text(tag, style: const TextStyle(color: textDim, fontSize: 10)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Could navigate to full edit screen here
            },
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: bgPrimary),
            child: const Text('EDIT TASK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, {bool isGold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? (isGold ? gold : textPrimary), fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _taskCardContent(TaskModel t, String initials, Color avatarColor, bool asPreview) {
    final isDone = t.status == TaskStatus.done;
    final showDate = t.tags.contains('overdue') ? '!' : '';
    
    final priorityColor = _getPriorityColor(t.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgTertiary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: asPreview ? gold.withOpacity(0.4) : bgQuint.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Priority Indicator Bar
            Container(
              width: 2.5,
              color: priorityColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.title, 
                            style: TextStyle(
                              color: isDone ? textMid : textPrimary, 
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showDate.isNotEmpty)
                          Text(
                            showDate, 
                            style: const TextStyle(color: dangerColor, fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            context.read<TaskProvider>().togglePin(t.id);
                            // Refresh pinned items
                            context.read<PinnedProvider>().fetchPinnedItems();
                          },
                          child: Icon(
                            t.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 16,
                            color: t.isPinned ? gold : textDim.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          t.project?.toUpperCase() ?? 'GEN', 
                          style: GoogleFonts.jetBrainsMono(
                            color: textDim, 
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: avatarColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials, 
                            style: TextStyle(
                              color: avatarColor, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 7.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical: return dangerColor;
      case TaskPriority.high: return warnColor;
      case TaskPriority.medium: return blueColor;
      case TaskPriority.low: return okColor;
      default: return gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, child) {
      // Build column lists based on provider data and filters
      final all = provider.tasks.where(_passesFilters).toList();
      final backlog = all.where((t) => _columnForTask(t) == 'BACKLOG').toList();
      final inprog = all.where((t) => _columnForTask(t) == 'IN PROGRESS').toList();
      final review = all.where((t) => _columnForTask(t) == 'REVIEW').toList();
      final done = all.where((t) => _columnForTask(t) == 'DONE').toList();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // board header
            Row(
              children: [
                Text('KANBAN BOARD', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                // Filter Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgTertiary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: goldLine.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, size: 14, color: gold),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: projectFilter,
                        underline: const SizedBox(),
                        dropdownColor: bgSecondary,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: textDim),
                        onChanged: (String? newValue) {
                          setState(() {
                            projectFilter = newValue ?? 'ALL';
                          });
                        },
                        items: ['ALL', 'IMAS', 'AGRI']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 16, color: goldLine.withOpacity(0.2)),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: deptFilter,
                        underline: const SizedBox(),
                        dropdownColor: bgSecondary,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: textDim),
                        onChanged: (String? newValue) {
                          setState(() {
                            deptFilter = newValue ?? 'ALL';
                          });
                        },
                        items: ['ALL', 'AI/ML', 'EMBEDDED', 'FULLSTACK']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Board
            Expanded(
              child: LayoutBuilder(builder: (ctx, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        _buildColumn('BACKLOG', backlog, textPrimary),
                        _buildColumn('IN PROGRESS', inprog, blueColor),
                        _buildColumn('REVIEW', review, warnColor),
                        _buildColumn('DONE', done, okColor),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
