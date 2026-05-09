import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const JarvisTopbar(
        title: 'WEEKLY INTELLIGENCE',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHero(context),
            const SizedBox(height: Spacing.xl),
            SectionTitle(title: 'PRODUCTIVITY METRICS'),
            const SizedBox(height: Spacing.md),
            _buildMetricRow(context, 'Tasks Completed', '24', '+12% vs last week'),
            _buildMetricRow(context, 'Focus Hours', '38.5', '-2% vs last week'),
            _buildMetricRow(context, 'Risk Alerts', '3', 'Action required'),
            const SizedBox(height: Spacing.xl),
            SectionTitle(title: 'AI INSIGHTS'),
            const SizedBox(height: Spacing.md),
            JarvisCard(
              padding: const EdgeInsets.all(Spacing.md),
              child: const Text(
                "Overall project velocity is stable. IMAS milestone 3 is at risk due to firmware delays. Suggest allocating Ravi K. to support Arjun M. for the next 48 hours.",
                style: TextStyle(color: textPrimary, fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(BorderValues.md),
        border: Border.all(color: goldLine),
      ),
      child: Column(
        children: [
          const Text('WEEK 16 REPORT', style: TextStyle(color: gold, letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: Spacing.md),
          const Text('APR 12 - APR 19', style: TextStyle(color: textDim, fontSize: 11)),
          const SizedBox(height: Spacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBigStat('82%', 'EFFICIENCY'),
              _buildBigStat('14', 'MILESTONES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontFamily: 'Orbitron', fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: textDim, fontSize: 9, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String val, String trend) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(val, style: const TextStyle(fontFamily: 'Orbitron', fontSize: 16, fontWeight: FontWeight.bold, color: gold)),
              Text(trend, style: const TextStyle(color: textDim, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
