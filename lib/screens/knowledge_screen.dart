// lib/screens/knowledge_screen.dart

import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Intel Docs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: Spacing.lg),
          JarvisCard(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              children: [
                _buildIntelDoc(context, 'Engineering Guidelines Q3', 'Last updated: 2 days ago'),
                const SizedBox(height: Spacing.sm),
                GradieDivider(),
                const SizedBox(height: Spacing.sm),
                _buildIntelDoc(context, 'Onboarding Checklist', 'Last updated: 1 week ago'),
                const SizedBox(height: Spacing.sm),
                GradieDivider(),
                const SizedBox(height: Spacing.sm),
                _buildIntelDoc(context, 'Product Roadmap 2026', 'Last updated: 1 month ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelDoc(BuildContext context, String title, String subtitle) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening document: $title...'),
            backgroundColor: bgTertiary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(BorderValues.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        child: Row(
          children: [
            const Icon(Icons.description, color: gold, size: 24),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textDim),
          ],
        ),
      ),
    );
  }
}
