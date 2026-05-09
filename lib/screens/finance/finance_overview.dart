// lib/screens/finance/finance_overview.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/jarvis_colors.dart';
import '../../theme/jarvis_theme.dart';
import '../../widgets/index.dart';
import '../../models/finance_model.dart';
import '../../providers/finance_provider.dart';

class FinanceOverview extends StatelessWidget {
  const FinanceOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.lg),
              _buildFinanceKpis(context, provider),
              const SizedBox(height: Spacing.lg),
              _buildTransactions(context, provider),
              const SizedBox(height: Spacing.lg),
              _buildMonthlyBreakdown(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinanceKpis(BuildContext context, FinanceProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFinanceKpi(
            context,
            '₹${provider.totalIncome.toStringAsFixed(0)}',
            'Total Income',
            Icons.trending_up,
            incomeLight,
          ),
          const SizedBox(width: Spacing.lg),
          _buildFinanceKpi(
            context,
            '₹${provider.totalExpense.toStringAsFixed(0)}',
            'Total Expense',
            Icons.trending_down,
            expenseLight,
          ),
          const SizedBox(width: Spacing.lg),
          _buildFinanceKpi(
            context,
            '₹${provider.netBalance.toStringAsFixed(0)}',
            'Net Balance',
            Icons.account_balance_wallet,
            gold,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceKpi(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 160,
      child: JarvisCard(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color.withOpacity(0.5), size: 16),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(BuildContext context, FinanceProvider provider) {
    final recentTxns = provider.transactions.take(5).toList();

    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Recent Transactions'),
          const SizedBox(height: Spacing.md),
          if (recentTxns.isEmpty)
            const Text('No recent transactions.')
          else
            ...recentTxns.map((txn) {
              final isIncome = txn.type == TransactionType.income;
              final color = isIncome ? incomeLight : expenseLight;
              final prefix = isIncome ? '+' : '-';
              return Column(
                children: [
                  _buildTransactionItem(
                    context, 
                    txn.title, 
                    '$prefix₹${txn.amount.toStringAsFixed(0)}', 
                    color
                  ),
                  if (txn != recentTxns.last) ...[
                    const SizedBox(height: Spacing.md),
                    GradieDivider(),
                    const SizedBox(height: Spacing.md),
                  ],
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown(BuildContext context, FinanceProvider provider) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Monthly Breakdown'),
          const SizedBox(height: Spacing.md),
          _buildBreakdownItem(context, 'Food & Dining', '₹3,420', 0.42),
          const SizedBox(height: Spacing.md),
          _buildBreakdownItem(context, 'Transport', '₹2,100', 0.28),
          const SizedBox(height: Spacing.md),
          _buildBreakdownItem(context, 'Entertainment', '₹1,820', 0.22),
          const SizedBox(height: Spacing.md),
          _buildBreakdownItem(context, 'Utilities', '₹1,200', 0.18),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, String label, String amount, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(amount, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(BorderValues.xs),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 2,
            backgroundColor: bgQuaternary,
            valueColor: AlwaysStoppedAnimation(expenseLight.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}
