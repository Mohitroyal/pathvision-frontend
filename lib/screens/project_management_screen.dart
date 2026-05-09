import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/project_provider.dart';
import '../providers/milestone_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';
import 'package:intl/intl.dart';

class ProjectManagementScreen extends StatefulWidget {
  final Project project;
  const ProjectManagementScreen({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final _taskController = TextEditingController();

  void _addTask(String title) {
    if (title.isEmpty) return;
    final newTask = TaskModel(
      id: '',
      title: title,
      project: widget.project.name,
      status: TaskStatus.todo,
    );
    context.read<TaskProvider>().addTask(newTask);
    _taskController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "$title" added to ${widget.project.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestoneProvider = context.watch<MilestoneProvider>();
    final taskProvider = context.watch<TaskProvider>();
    
    final projectMilestones = milestoneProvider.milestones.where((m) => m.project == widget.project.name).toList();
    final projectTasks = taskProvider.tasks.where((t) => t.project == widget.project.name).toList();

    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: JarvisTopbar(
        title: 'MANAGE: ${widget.project.name.toUpperCase()}',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Sidebar Info
          Container(
            width: 300,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: goldLine)),
              color: bgSecondary,
            ),
            child: _buildProjectSidebar(),
          ),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('PROJECT MILESTONES', Icons.flag_rounded),
                  const SizedBox(height: 16),
                  if (projectMilestones.isEmpty)
                    _buildEmptyState('No milestones defined for this project.')
                  else
                    ...projectMilestones.map((m) => _buildMilestoneTile(m)).toList(),
                  
                  const SizedBox(height: 40),
                  _buildSectionHeader('PROJECT TASKS', Icons.task_alt_rounded),
                  const SizedBox(height: 16),
                  _buildTaskInput(),
                  const SizedBox(height: 16),
                  if (projectTasks.isEmpty)
                    _buildEmptyState('No tasks assigned to this project.')
                  else
                    ...projectTasks.map((t) => _buildTaskTile(t)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSidebar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(widget.project.status.toUpperCase(), style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Text('DESCRIPTION', style: GoogleFonts.orbitron(color: gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(widget.project.description ?? 'No description.', style: const TextStyle(color: textDim, fontSize: 13, height: 1.5)),
          const Spacer(),
          _buildSidebarStat('HEALTH', '95%', okColor),
          const SizedBox(height: 16),
          _buildSidebarStat('DEADLINE', 'OCT 2026', gold),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor.withOpacity(0.1),
              foregroundColor: dangerColor,
              minimumSize: const Size(double.infinity, 45),
              side: const BorderSide(color: dangerColor, width: 0.5),
            ),
            child: const Text('ARCHIVE PROJECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 20),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.orbitron(color: gold, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const Expanded(child: Divider(indent: 20, color: goldLine)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: goldLine.withOpacity(0.5), style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: textDim, fontSize: 13, fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildMilestoneTile(MilestoneModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: goldLine),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: m.status == MilestoneStatus.done ? okColor : textDim),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Scheduled: ${DateFormat('MMM dd').format(m.start)} - ${DateFormat('MMM dd').format(m.end)}', 
                  style: const TextStyle(color: textDim, fontSize: 11)),
              ],
            ),
          ),
          _buildMilestoneStatusChip(m.status),
        ],
      ),
    );
  }

  Widget _buildMilestoneStatusChip(MilestoneStatus status) {
    Color color = gold;
    if (status == MilestoneStatus.done) color = okColor;
    if (status == MilestoneStatus.atRisk) color = dangerColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTaskTile(TaskModel t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgTertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Checkbox(
            value: t.status == TaskStatus.done,
            onChanged: (val) {
              context.read<TaskProvider>().updateTaskStatus(t.id, val! ? TaskStatus.done : TaskStatus.todo);
            },
            activeColor: gold,
            checkColor: bgPrimary,
            side: const BorderSide(color: goldLine),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(t.title, style: TextStyle(color: t.status == TaskStatus.done ? textDim : textPrimary, decoration: t.status == TaskStatus.done ? TextDecoration.lineThrough : null)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: dangerColor, size: 18),
            onPressed: () => context.read<TaskProvider>().removeTask(t.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInput() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: goldLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              style: const TextStyle(color: textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Add a new task for this project...',
                hintStyle: TextStyle(color: textDim, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: _addTask,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: gold),
            onPressed: () => _addTask(_taskController.text),
          ),
        ],
      ),
    );
  }
}
