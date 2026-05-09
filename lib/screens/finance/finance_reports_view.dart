import 'package:flutter/material.dart';
import '../../theme/jarvis_colors.dart';
import '../../theme/jarvis_theme.dart';
import '../../widgets/index.dart';

class FinanceReportsView extends StatelessWidget {
  const FinanceReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: Spacing.xl),
          SectionTitle(title: 'EXPENSE DISTRIBUTION'),
          const SizedBox(height: Spacing.md),
          _buildDistributionRow(context, 'Rent', 0.40, Colors.red),
          _buildDistributionRow(context, 'Food', 0.25, Colors.orange),
          _buildDistributionRow(context, 'Transport', 0.15, Colors.blue),
          _buildDistributionRow(context, 'Others', 0.20, Colors.grey),
          const SizedBox(height: Spacing.xl),
          SectionTitle(title: 'SAVINGS TREND'),
          const SizedBox(height: Spacing.md),
          _buildTrendChart(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('₹1.2L', 'ANNUAL INCOME'),
          _buildStat('₹45K', 'ANNUAL SPENT'),
          _buildStat('62%', 'SAVINGS RATE'),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.bold, color: gold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: textDim, fontSize: 8)),
      ],
    );
  }

  Widget _buildDistributionRow(BuildContext context, String label, double pct, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: pct, backgroundColor: bgTertiary, valueColor: AlwaysStoppedAnimation(color)),
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgTertiary,
        borderRadius: BorderRadius.circular(BorderValues.sm),
        border: Border.all(color: goldLine),
      ),
      child: const Center(
        child: Text('Savings Trend Visualizer\n(Historical Data)', textAlign: TextAlign.center, style: TextStyle(color: textDim, fontSize: 11)),
      ),
    );
  }
}
