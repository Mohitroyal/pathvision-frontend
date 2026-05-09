// lib/screens/finance/expense_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/jarvis_colors.dart';
import '../../theme/jarvis_theme.dart';
import '../../widgets/index.dart';
import '../../models/finance_model.dart';
import '../../providers/finance_provider.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  String _selectedTag = 'ALL';

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        final expenses = provider.transactions.where((t) => t.type == TransactionType.expense).toList();
        
        final filteredExpenses = _selectedTag == 'ALL' 
            ? expenses 
            : expenses.where((t) => t.tags.contains(_selectedTag)).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Log',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.md),
              _buildFilterTags(),
              const SizedBox(height: Spacing.lg),
              _buildExpenseList(filteredExpenses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTags() {
    final tags = ['ALL', 'rent', 'food', 'transport', 'bills', 'misc'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          final isSelected = _selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: ChoiceChip(
              label: Text(tag.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedTag = tag);
                }
              },
              backgroundColor: bgTertiary,
              selectedColor: expenseDim,
              labelStyle: TextStyle(
                color: isSelected ? expenseLight : textDim,
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BorderValues.sm),
                side: BorderSide(
                  color: isSelected ? expenseLine : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseList(List<Transaction> expenses) {
    if (expenses.isEmpty) {
      return const JarvisCard(
        padding: EdgeInsets.all(Spacing.lg),
        child: Center(child: Text('No expenses found for this filter.')),
      );
    }

    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: expenses.map((txn) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.title, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('MMM d, yyyy').format(txn.date)} · ${txn.tags.join(', ')}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                  Text(
                    '-₹${txn.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: expenseLight,
                    ),
                  ),
                ],
              ),
              if (txn != expenses.last) ...[
                const SizedBox(height: Spacing.md),
                GradieDivider(),
                const SizedBox(height: Spacing.md),
              ]
            ],
          );
        }).toList(),
      ),
    );
  }
}
