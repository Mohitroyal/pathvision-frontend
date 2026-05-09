// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/index.dart';
import 'screens/index.dart';
import 'screens/auth_screen.dart';
import 'screens/company_intel_screen.dart';
import 'screens/milestones_screen.dart';
import 'screens/translation_vault_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/knowledge_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/weekly_report_screen.dart';
import 'screens/decision_log_screen.dart';
import 'widgets/index.dart';
import 'providers/task_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/team_provider.dart';
import 'providers/planner_provider.dart';
import 'providers/brain_dump_provider.dart';
import 'providers/risk_provider.dart';
import 'providers/milestone_provider.dart';
import 'providers/jarvis_provider.dart';
import 'providers/project_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/pinned_provider.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/translation_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/decision_log_provider.dart';

import 'models/task_model.dart';
import 'models/brain_dump_model.dart';
import 'models/finance_model.dart';
import 'models/goal_model.dart';
import 'models/decision_log_model.dart';
import 'models/risk_model.dart';
import 'models/milestone_model.dart' hide GoalModel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase Cloud Link
  await Supabase.initialize(
    url: 'https://bykivmvznqbgnjlokxd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5a2l2bXZ6bnFiZ25uamxva3hkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMDY1MTksImV4cCI6MjA5Mzg4MjUxOX0.LUarkyRAHVQHCa68d9iFC4CorXxsdzCIn_xfF_tla2c',
  );
  
  // Initialize Notification Service
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => BrainDumpProvider()),
        ChangeNotifierProvider(create: (_) => RiskProvider()),
        ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => PinnedProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DecisionLogProvider()),
        ChangeNotifierProvider(
          create: (context) => JarvisProvider(
            taskProvider: context.read<TaskProvider>(),
            milestoneProvider: context.read<MilestoneProvider>(),
            riskProvider: context.read<RiskProvider>(),
            plannerProvider: context.read<PlannerProvider>(),
            reminderProvider: context.read<ReminderProvider>(),
          ),
        ),
      ],
      child: const JarvisOsApp(),
    ),
  );
}

class JarvisOsApp extends StatefulWidget {
  const JarvisOsApp({Key? key}) : super(key: key);

  @override
  State<JarvisOsApp> createState() => _JarvisOsAppState();
}

class _JarvisOsAppState extends State<JarvisOsApp> {
  @override
  void initState() {
    super.initState();
    // Real-time synchronization is now handled natively within each Provider via Supabase streams
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'JARVIS OS',
      theme: JarvisTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: authProvider.isAuthenticated 
          ? const JarvisNavigationShell() 
          : const AuthScreen(),
    );
  }
}

class JarvisNavigationShell extends StatefulWidget {
  const JarvisNavigationShell({Key? key}) : super(key: key);

  @override
  State<JarvisNavigationShell> createState() => _JarvisNavigationShellState();
}

class _JarvisNavigationShellState extends State<JarvisNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),                
    const ProfileScreen(),
    const TasksScreen(),                    
    const TranslationVaultScreen(),                    
    const NotificationsScreen(),            
    const PinnedScreen(), 
    const BrainDumpScreen(),                
    const ProjectsScreen(),                 
    const TeamScreen(),                     
    const RiskRadarScreen(),                
    const AiScreen(),                       
    const DailyPlannerScreen(),             
    const MilestonesScreen(),               
    const CompanyIntelScreen(),
    const FinanceScreen(),
    const KnowledgeScreen(),
    const GoalsScreen(),
    const WeeklyReportScreen(),
    const DecisionLogScreen(),
  ];

  final List<SidebarItem> sidebarItems = [
    SidebarItem(label: 'Dashboard', icon: Icons.home_outlined, section: 'Personal'),
    SidebarItem(label: 'Profile', icon: Icons.person_outline, section: 'Personal'),
    SidebarItem(label: 'My Tasks', icon: Icons.assignment_outlined, section: 'Personal', badge: '3'),
    SidebarItem(label: 'Translation Vault', icon: Icons.translate, section: 'Personal'),
    SidebarItem(label: 'Reminders', icon: Icons.notifications_none_outlined, section: 'Personal'),
    SidebarItem(label: 'Pinned', icon: Icons.push_pin_outlined, section: 'Personal'),
    SidebarItem(label: 'Brain Dump', icon: Icons.bolt_outlined, section: 'Personal'),
    SidebarItem(label: 'Projects', icon: Icons.folder_open_outlined, section: 'Company'),
    SidebarItem(label: 'Team & Depts', icon: Icons.people_outline, section: 'Company'),
    SidebarItem(label: 'Risk Radar', icon: Icons.warning_amber_outlined, section: 'Intelligence'),
    SidebarItem(label: 'JARVIS AI', icon: Icons.psychology_outlined, section: 'Intelligence'),
    SidebarItem(label: 'Daily Planner', icon: Icons.calendar_view_day_outlined, section: 'Intelligence'),
    SidebarItem(label: 'Milestones', icon: Icons.timeline_outlined, section: 'Intelligence'),
    SidebarItem(label: 'Company Intel', icon: Icons.business_outlined, section: 'Company'),
    SidebarItem(label: 'Finance', icon: Icons.account_balance_wallet_outlined, section: 'Company'),
    SidebarItem(label: 'Knowledge Base', icon: Icons.library_books_outlined, section: 'Company'),
    SidebarItem(label: 'Goals', icon: Icons.track_changes_outlined, section: 'Intelligence'),
    SidebarItem(label: 'Weekly Report', icon: Icons.analytics_outlined, section: 'Intelligence'),
    SidebarItem(label: 'Decision Log', icon: Icons.history_edu_outlined, section: 'Intelligence'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final jarvisProvider = context.watch<JarvisProvider>();
    final selectedIndex = jarvisProvider.navigationIndex;

    return Scaffold(
      drawer: isMobile ? _buildDrawer(context, jarvisProvider, selectedIndex) : null,
      appBar: AppBar(
        backgroundColor: bgPrimary,
        elevation: 0,
        centerTitle: false,
        title: Text(sidebarItems[selectedIndex].label.toUpperCase(), style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14, letterSpacing: 2, color: gold)),
        leading: isMobile ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: gold),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ) : null,
        actions: [
          _buildAddAction(selectedIndex, context),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: textDim),
            onPressed: () => _showSearchDialog(context),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 14, backgroundColor: gold, child: Text('CK', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            JarvisSidebar(
              items: sidebarItems,
              selectedIndex: selectedIndex,
              onItemTap: (index) {
                jarvisProvider.setNavigationIndex(index);
              },
            ),
          Expanded(child: _screens[selectedIndex]),
        ],
      ),
      floatingActionButton: _buildFab(selectedIndex, context),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Container(
          decoration: BoxDecoration(
            color: bgSecondary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: gold.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.search_rounded, color: gold, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(fontFamily: 'Orbitron', color: textPrimary, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'COMMAND SEARCH...',
                        hintStyle: TextStyle(color: textDim, letterSpacing: 2),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Searching JARVIS Index for: "$val"'), backgroundColor: gold));
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: textDim), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: goldLine, height: 32),
              const Text('RECENT QUERIES', style: TextStyle(color: gold, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSearchShortcut('IMAS ARCHITECTURE'),
              _buildSearchShortcut('Q2 FINANCE SUMMARY'),
              _buildSearchShortcut('TEAM AVAILABILITY'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchShortcut(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: textDim, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: textDim, fontSize: 13)),
          const Spacer(),
          const Icon(Icons.north_west_rounded, color: textDim, size: 14),
        ],
      ),
    );
  }

  Widget _buildAddAction(int index, BuildContext context) {
    // Only show for screens that have an "Add" action
    final supported = [2, 6, 7, 9, 12, 13, 14, 15, 16, 18];
    if (!supported.contains(index)) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.add_circle_outline_rounded, color: gold),
      onPressed: () => _triggerAddAction(index, context),
    );
  }

  void _triggerAddAction(int index, BuildContext context) {
    switch (index) {
      case 2: // Tasks
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()));
        break;
      case 6: // Brain Dump
        _showAddDialog(context, 'BRAIN DUMP', 'What\'s on your mind?', onSave: (val) {
          context.read<BrainDumpProvider>().addEntry(val);
        });
        break;
      case 7: // Projects
        _showAddDialog(context, 'PROJECT', 'Enter project title', onSave: (val) {
          context.read<ProjectProvider>().addProject(
            name: val,
            description: 'Added via Quick Capture',
            status: 'active',
            type: 'internal',
            startDate: DateTime.now(),
            deadline: DateTime.now().add(const Duration(days: 90)),
            techStack: [],
            milestones: [],
          );
        });
        break;
      case 9: // Risk Radar
        _showAddDialog(context, 'RISK', 'Describe the risk', onSave: (val) {
          context.read<RiskProvider>().addRisk(
            title: val,
            description: 'Captured via JARVIS',
            severity: RiskSeverity.monitor,
          );
        });
        break;
      case 12: // Milestones
        _showAddDialog(context, 'MILESTONE', 'Enter milestone goal', onSave: (val) {
          context.read<MilestoneProvider>().addMilestone(
            title: val,
            project: 'General',
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 30)),
          );
        });
        break;
      case 13: // Company Intel
        _showAddDialog(context, 'INTEL', 'Enter company news or insight');
        break;
      case 14: // Finance
        _showAddDialog(context, 'FINANCE', 'Enter expense/income (e.g., Rent 15000)', onSave: (val) {
          final parts = val.split(' ');
          final amount = parts.length > 1 ? double.tryParse(parts.last) ?? 0.0 : 0.0;
          final title = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : val;
          context.read<FinanceProvider>().addTransaction(Transaction(
            id: '', title: title, amount: amount, date: DateTime.now(), type: TransactionType.expense, tags: ['misc']
          ));
        });
        break;
      case 16: // Goals
        _showAddDialog(context, 'GOAL', 'Enter goal title', onSave: (val) {
          context.read<GoalProvider>().addGoal(GoalModel(
            id: '', title: val, description: 'Added via Quick Capture', progress: 0.0, category: 'GENERAL'
          ));
        });
        break;
      case 18: // Decision Log
        _showAddDialog(context, 'DECISION', 'Describe the decision', onSave: (val) {
          context.read<DecisionLogProvider>().addDecision(DecisionModel(
            id: '', title: val, reasoning: 'Captured via JARVIS', category: 'STRATEGIC', date: DateTime.now(), author: 'MOHITH'
          ));
        });
        break;
    }
  }

  Widget? _buildFab(int index, BuildContext context) {
    IconData icon = Icons.add;
    String label = 'ADD';
    
    switch (index) {
      case 2: icon = Icons.add_task_rounded; label = 'NEW TASK'; break;
      case 6: icon = Icons.bolt_rounded; label = 'CAPTURE'; break;
      case 7: icon = Icons.create_new_folder_rounded; label = 'NEW PROJECT'; break;
      case 9: icon = Icons.warning_rounded; label = 'LOG RISK'; break;
      case 12: icon = Icons.flag_rounded; label = 'NEW MILESTONE'; break;
      case 13: icon = Icons.business_rounded; label = 'NEW INTEL'; break;
      case 14: icon = Icons.account_balance_wallet_rounded; label = 'NEW TRANSACTION'; break;
      case 15: icon = Icons.library_books_rounded; label = 'NEW KNOWLEDGE'; break;
      case 16: icon = Icons.track_changes_rounded; label = 'NEW GOAL'; break;
      case 18: icon = Icons.history_edu_rounded; label = 'LOG DECISION'; break;
      default: return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => _triggerAddAction(index, context),
      backgroundColor: gold,
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
    );
  }

  void _showAddDialog(BuildContext context, String type, String hint, {Function(String)? onSave}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: goldLine)),
        title: Text('ADD $type', style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: gold, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: textDim, fontSize: 12),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: goldLine)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: gold)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: textDim))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
            onPressed: () {
              if (onSave != null) onSave(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to JARVIS $type: ${controller.text}'), backgroundColor: gold, duration: const Duration(seconds: 2)));
              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget? _buildDrawer(BuildContext context, JarvisProvider provider, int selectedIndex) {
    return Drawer(
      backgroundColor: bgPrimary,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: goldLine, width: 0.5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('JARVIS', style: TextStyle(fontFamily: 'Orbitron', fontSize: 28, fontWeight: FontWeight.w900, color: gold, letterSpacing: 6)),
                Text('PATHVISION OS v2', style: TextStyle(color: textDim, fontSize: 10, letterSpacing: 2)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final item = sidebarItems[index];
                final bool isSelected = selectedIndex == index;
                
                // Add Section Labels
                bool showSection = index == 0 || sidebarItems[index-1].section != item.section;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSection) Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(item.section?.toUpperCase() ?? '', style: const TextStyle(color: gold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                    ListTile(
                      leading: Icon(item.icon, color: isSelected ? gold : textDim, size: 20),
                      title: Text(item.label, style: TextStyle(color: isSelected ? textPrimary : textDim, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      onTap: () {
                        provider.setNavigationIndex(index);
                        Navigator.pop(context);
                      },
                      dense: true,
                      selected: isSelected,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getBottomNavIndex(int selectedIndex) {
    if (selectedIndex == 0) return 0;
    if (selectedIndex == 2) return 1;
    if (selectedIndex == 13) return 2;
    if (selectedIndex == 17) return 3;
    if (selectedIndex == 14) return 4;
    return 0;
  }
}
