// lib/screens/pinned_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/pinned_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/milestone_provider.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';

class PinnedScreen extends StatelessWidget {
  const PinnedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JarvisTopbar(
        title: 'COMMAND CENTER — PINNED ITEMS',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: gold),
            onPressed: () => context.read<PinnedProvider>().fetchPinnedItems(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<PinnedProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          if (provider.totalPinnedCount == 0) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.pinnedTasks.isNotEmpty) ...[
                  _buildSectionHeader('PINNED TASKS', provider.pinnedTasks.length, dangerColor),
                  const SizedBox(height: 16),
                  _buildTasksGrid(context, provider.pinnedTasks),
                  const SizedBox(height: 32),
                ],
                if (provider.pinnedProjects.isNotEmpty) ...[
                  _buildSectionHeader('PINNED PROJECTS', provider.pinnedProjects.length, blueColor),
                  const SizedBox(height: 16),
                  _buildProjectsGrid(context, provider.pinnedProjects),
                  const SizedBox(height: 32),
                ],
                if (provider.pinnedMilestones.isNotEmpty) ...[
                  _buildSectionHeader('PINNED MILESTONES', provider.pinnedMilestones.length, gold),
                  const SizedBox(height: 16),
                  _buildMilestonesGrid(context, provider.pinnedMilestones),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksGrid(BuildContext context, List<TaskModel> tasks) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 80,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: goldLine),
          ),
          child: Row(
            children: [
              Container(
                width: 2,
                height: double.infinity,
                color: _getPriorityColor(t.priority),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.title,
                      style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.project ?? 'GENERAL',
                      style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.push_pin, color: gold, size: 14),
                onPressed: () {
                  context.read<TaskProvider>().togglePin(t.id);
                  context.read<PinnedProvider>().fetchPinnedItems();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectsGrid(BuildContext context, List<Project> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisExtent: 60,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: blueColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_open, color: blueColor, size: 18),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.push_pin, color: gold, size: 14),
                onPressed: () {
                  context.read<ProjectProvider>().togglePin(p.id);
                  context.read<PinnedProvider>().fetchPinnedItems();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestonesGrid(BuildContext context, List<MilestoneModel> milestones) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisExtent: 60,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final m = milestones[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: gold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: gold, size: 18),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.title,
                      style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      m.project,
                      style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.push_pin, color: gold, size: 14),
                onPressed: () {
                  context.read<MilestoneProvider>().togglePin(m.id);
                  context.read<PinnedProvider>().fetchPinnedItems();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.push_pin_outlined, color: gold.withOpacity(0.1), size: 64),
          const SizedBox(height: 24),
          Text(
            'NO PINNED ITEMS',
            style: GoogleFonts.orbitron(
              color: gold.withOpacity(0.3),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pin important tasks or projects to see them here.',
            style: TextStyle(color: textDim.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical: return dangerColor;
      case TaskPriority.high: return warnColor;
      case TaskPriority.low: return okColor;
      default: return blueColor;
    }
  }
}
