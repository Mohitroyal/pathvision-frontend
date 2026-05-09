// lib/screens/finance_screen.dart

import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import 'finance/finance_overview.dart';
import 'finance/expense_list.dart';
import 'finance/debt_tracker.dart';

import 'finance/finance_reports_view.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: bgPrimary,
            child: TabBar(
              indicatorColor: gold,
              labelColor: gold,
              unselectedLabelColor: textDim,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              tabs: const [
                Tab(text: 'OVERVIEW'),
                Tab(text: 'EXPENSES'),
                Tab(text: 'DEBTS'),
                Tab(text: 'REPORTS'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                FinanceOverview(),
                ExpenseList(),
                DebtTracker(),
                FinanceReportsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

