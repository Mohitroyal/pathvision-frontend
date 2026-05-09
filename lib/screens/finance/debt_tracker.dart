// lib/screens/finance/debt_tracker.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/jarvis_colors.dart';
import '../../theme/jarvis_theme.dart';
import '../../widgets/index.dart';
import '../../models/finance_model.dart';
import '../../providers/finance_provider.dart';

class DebtTracker extends StatelessWidget {
  const DebtTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        final debtsOwedToMe = provider.debts.where((d) => d.isOwedToMe).toList();
        final debtsIOwe = provider.debts.where((d) => !d.isOwedToMe).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debt Tracker',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDebtSection(context, 'OWED TO YOU', debtsOwedToMe, true)),
                  const SizedBox(width: Spacing.lg),
                  Expanded(child: _buildDebtSection(context, 'YOU OWE', debtsIOwe, false)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtSection(BuildContext context, String title, List<Debt> debts, bool isIncome) {
    final color = isIncome ? incomeLight : const Color(0xFF9B59B6); // purple for owe
    final bgColor = isIncome ? incomeDim : const Color(0x1A9B59B6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: Spacing.md),
        if (debts.isEmpty)
          const Text('No active debts in this category.', style: TextStyle(color: textDim))
        else
          ...debts.map((debt) {
            final isOverdue = debt.dueDate.isBefore(DateTime.now());
            return Container(
              margin: const EdgeInsets.only(bottom: Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: color.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(BorderValues.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.personName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '₹${debt.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 10, color: isOverdue ? dangerColor : textDim),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy').format(debt.dueDate)}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 9,
                          color: isOverdue ? dangerColor : textDim,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        const JarvisChip(label: 'OVERDUE', type: ChipType.danger),
                      ]
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
