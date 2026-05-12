import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: gold));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuarterlyProgress(context),
              const SizedBox(height: Spacing.xl),
              SectionTitle(title: 'ACTIVE GOALS'),
              const SizedBox(height: Spacing.md),
              if (provider.goals.isEmpty)
                const Center(child: Text('No active goals logged.', style: TextStyle(color: textDim)))
              else
                ...provider.goals.map((goal) => _buildGoalCard(
                  context, 
                  goal.title, 
                  goal.description, 
                  goal.progress, 
                  goal.category == 'STRATEGIC' ? gold : Colors.blue
                )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuarterlyProgress(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Q2 2026 PROGRESS', style: TextStyle(color: textDim, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: Spacing.sm),
          const Text('73%', style: TextStyle(fontFamily: 'Orbitron', fontSize: 32, fontWeight: FontWeight.bold, color: gold)),
          const SizedBox(height: Spacing.md),
          const LinearProgressIndicator(value: 0.73, backgroundColor: bgTertiary, valueColor: AlwaysStoppedAnimation(gold)),
          const SizedBox(height: Spacing.sm),
          const Text('On track to hit all primary targets', style: TextStyle(color: textDim, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, String subtitle, double progress, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: JarvisCard(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${(progress * 100).toInt()}%', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: textDim, fontSize: 11)),
            const SizedBox(height: Spacing.md),
            LinearProgressIndicator(value: progress, backgroundColor: bgTertiary, valueColor: AlwaysStoppedAnimation(accent)),
          ],
        ),
      ),
    );
  }
}
