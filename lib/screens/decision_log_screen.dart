import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

import 'package:provider/provider.dart';
import '../providers/decision_log_provider.dart';

class DecisionLogScreen extends StatelessWidget {
  const DecisionLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DecisionLogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: gold));
        }

        return ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            if (provider.decisions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(Spacing.xl),
                child: Text('No decisions recorded in the neural log.', style: TextStyle(color: textDim)),
              ))
            else
              ...provider.decisions.map((decision) => _buildDecisionItem(
                context, 
                decision.title, 
                decision.reasoning, 
                '${decision.date.day}/${decision.date.month}', 
                decision.category
              )).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDecisionItem(BuildContext context, String title, String reason, String date, String category) {
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
                JarvisChip(label: category, type: ChipType.blue),
                Text(date, style: const TextStyle(color: textDim, fontSize: 10)),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: gold)),
            const SizedBox(height: 4),
            Text(reason, style: const TextStyle(color: textPrimary, fontSize: 12, height: 1.4)),
            const SizedBox(height: Spacing.md),
            Row(
              children: const [
                Icon(Icons.person_outline, size: 12, color: textDim),
                SizedBox(width: 4),
                Text('By: Chakravarthi', style: TextStyle(color: textDim, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
