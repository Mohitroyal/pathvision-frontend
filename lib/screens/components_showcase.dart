// lib/screens/components_showcase.dart
// This file demonstrates all JARVIS OS components
// Uncomment and use in main.dart to view the showcase

import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class ComponentsShowcase extends StatelessWidget {
  const ComponentsShowcase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: JarvisTopbar(
          title: 'COMPONENTS',
          actions: [
            TopbarIconButton(
              icon: Icons.info,
              onTap: () {},
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildCardsShowcase(context),
            _buildChipsShowcase(context),
            _buildKpisShowcase(context),
            _buildOthersShowcase(context),
            _buildColorsShowcase(context),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: goldLine)),
          ),
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.layers), text: 'Cards'),
              Tab(icon: Icon(Icons.local_offer), text: 'Chips'),
              Tab(icon: Icon(Icons.assessment), text: 'KPIs'),
              Tab(icon: Icon(Icons.widgets), text: 'Others'),
              Tab(icon: Icon(Icons.palette), text: 'Colors'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsShowcase(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Variants', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Spacing.lg),
          
          // Basic Card
          _sectionHeader('Basic Card'),
          JarvisCard(
            child: Text('Standard JarvisCard with gold border',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: Spacing.lg),

          // Card with Accent
          _sectionHeader('Card with Left Accent'),
          JarvisCardAccent(
            accentColor: gold,
            child: Text('Left accent bar with gradient',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: Spacing.lg),

          // Income Card
          _sectionHeader('Income Card'),
          IncomeCard(
            child: Text('Green-themed income card',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: Spacing.lg),

          // Expense Card
          _sectionHeader('Expense Card'),
          ExpenseCard(
            child: Text('Red-themed expense card',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsShowcase(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chip Types', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Status Chips'),
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: [
              JarvisChip(label: 'On Track', type: ChipType.ok),
              JarvisChip(label: 'Warning', type: ChipType.warn),
              JarvisChip(label: 'Critical', type: ChipType.danger),
              JarvisChip(label: 'Info', type: ChipType.blue),
              JarvisChip(label: 'Gold', type: ChipType.gold),
              JarvisChip(label: 'Income', type: ChipType.income),
              JarvisChip(label: 'Expense', type: ChipType.expense),
              JarvisChip(label: 'Priority', type: ChipType.purple),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Chips without Dot'),
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: [
              JarvisChip(
                label: 'No Dot',
                type: ChipType.ok,
                showDot: false,
              ),
              JarvisChip(
                label: 'Info Only',
                type: ChipType.blue,
                showDot: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpisShowcase(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KPI Components', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('KPI Cards'),
          Row(
            children: [
              Expanded(
                child: JarvisKpi(
                  value: '₹4,821',
                  label: 'Income',
                  valueColor: incomeLight,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: JarvisKpi(
                  value: '₹2,104',
                  label: 'Expense',
                  valueColor: expenseLight,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('KPI with Progress'),
          JarvisKpiWithProgress(
            value: '68%',
            label: 'Budget Used',
            progress: 0.68,
            progressColor: gold,
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('KPI Row - Multiple Metrics'),
          const KpiRow(
            items: [
              KpiData(
                value: '12',
                label: 'Active',
                valueColor: okColor,
              ),
              KpiData(
                value: '3',
                label: 'Pending',
                valueColor: warnColor,
              ),
              KpiData(
                value: '8',
                label: 'Completed',
                valueColor: gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOthersShowcase(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Other Components', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('AI Orb Variants'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AiOrb(size: 60, animate: true),
              AiOrbSmall(size: 40),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Task Items'),
          TaskItem(
            label: 'Review budget',
            isCompleted: false,
            meta: 'Priority: High',
          ),
          TaskItem(
            label: 'Update reports',
            isCompleted: true,
            meta: 'Completed today',
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Divider'),
          GradieDivider(),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Section Header'),
          SectionHeader(
            sectionNumber: 1,
            title: 'Personal Dashboard',
            description: 'Full system overview',
          ),
          const SizedBox(height: Spacing.lg),

          _sectionHeader('Section Title'),
          SectionTitle(
            title: 'Recent Activities',
            link: 'VIEW ALL',
          ),
        ],
      ),
    );
  }

  Widget _buildColorsShowcase(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Palette', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Spacing.lg),

          _buildColorGroup('Primary', [
            ('BG Primary', bgPrimary),
            ('BG Secondary', bgSecondary),
            ('BG Tertiary', bgTertiary),
            ('BG Quaternary', bgQuaternary),
          ]),
          const SizedBox(height: Spacing.lg),

          _buildColorGroup('Gold Accent', [
            ('Gold', gold),
            ('Gold Light', goldLight),
            ('Gold Lighter', goldLighter),
          ]),
          const SizedBox(height: Spacing.lg),

          _buildColorGroup('Text', [
            ('Primary', textPrimary),
            ('Mid', textMid),
            ('Dim', textDim),
          ]),
          const SizedBox(height: Spacing.lg),

          _buildColorGroup('Status', [
            ('Ok', okColor),
            ('Warning', warnColor),
            ('Danger', dangerColor),
            ('Blue', blueColor),
          ]),
          const SizedBox(height: Spacing.lg),

          _buildColorGroup('Finance', [
            ('Income', incomeLight),
            ('Expense', expenseLight),
          ]),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: gold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: Spacing.md),
      ],
    );
  }

  Widget _buildColorGroup(String title, List<(String, Color)> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        for (final (name, color) in colors) ...[
          Row(
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: goldLine, width: 0.8),
                  borderRadius: BorderRadius.circular(BorderValues.md),
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2).toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        color: textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ],
    );
  }
}
