import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/reminder_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final reminderProvider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: JarvisTopbar(
        title: isDesktop ? 'NOTIFICATION & REMINDER ENGINE' : 'ALERTS',
        actions: [
          TopbarIconButton(
            icon: Icons.add_alarm,
            onTap: () => _showAddReminderDialog(context),
          ),
          if (!isDesktop)
            const SizedBox(width: 8),
          if (!isDesktop)
            TopbarIconButton(
              icon: Icons.checklist,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All alerts marked as read.')),
                );
              },
            ),
        ],
      ),
      body: reminderProvider.isLoading 
          ? const Center(child: CircularProgressIndicator(color: gold))
          : isDesktop ? _buildDesktopLayout(context, reminderProvider) : _buildMobileLayout(context, reminderProvider),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ReminderProvider provider) {
    final reminders = provider.reminders;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NOTIFICATION CENTER', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: gold, letterSpacing: 2)),
              Row(
                children: [
                  _buildTab('ALL (${reminders.length})', gold, true),
                  const SizedBox(width: Spacing.sm),
                  // Realtime streams handle updates automatically
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          _buildSummaryBox(context, reminders.length),
          const SizedBox(height: Spacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('LIVE REMINDERS', gold),
                    const SizedBox(height: Spacing.md),
                    if (reminders.isEmpty)
                      const Center(child: Text('No active reminders', style: TextStyle(color: textDim)))
                    else
                      ...reminders.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.md),
                        child: _buildAlertCard(context, Icons.alarm, gold, r.message, 'Automated Task Reminder', DateFormat('MMM dd, HH:mm').format(r.remindAt)),
                      )).toList(),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('SYSTEM ALERTS', const Color(0xFF00BFFF)),
                    const SizedBox(height: Spacing.md),
                    _buildAlertCard(context, Icons.flash_on, gold, 'Backend Synchronized', 'Real-time database connection established.', 'Just now'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ReminderProvider provider) {
    final reminders = provider.reminders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBox(context, reminders.length, isMobile: true),
          const SizedBox(height: Spacing.lg),
          _buildSectionHeader('ACTIVE ALERTS', gold),
          const SizedBox(height: Spacing.md),
          if (reminders.isEmpty)
            const Center(child: Text('No active reminders', style: TextStyle(color: textDim)))
          else
            ...reminders.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildAlertCard(context, Icons.alarm, gold, r.message, 'Task Reminder', DateFormat('HH:mm').format(r.remindAt)),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildTab(String text, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(color: isSelected ? color : textDim.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryBox(BuildContext context, int count, {bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: goldLight, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(isMobile ? 'LIVE ALERTS' : 'ACTIVE NOTIFICATIONS', style: const TextStyle(color: textDim, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(isMobile ? '$count Notifications' : 'System Alert Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: goldLight)),
          const SizedBox(height: 4),
          Text(
            isMobile ? '$count active reminders from your tasks.' : 'You have $count active notifications. Private notes from tasks are automatically interlinked here.',
            style: const TextStyle(color: textDim, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: Spacing.sm),
        Text(title, style: TextStyle(color: textDim, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, IconData icon, Color iconColor, String title, String description, String time) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: textDim, fontSize: 11)),
                const SizedBox(height: Spacing.sm),
                Text(time, style: const TextStyle(color: textDim, fontSize: 10, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showAddReminderDialog(BuildContext context) {
    final messageController = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(minutes: 5));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: bgSecondary,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: goldLine),
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('SCHEDULE REMINDER', style: TextStyle(color: gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                style: const TextStyle(color: textPrimary),
                decoration: const InputDecoration(
                  labelText: 'REMINDER MESSAGE',
                  labelStyle: TextStyle(color: textDim),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: goldLine)),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('TIME', style: TextStyle(color: textDim, fontSize: 12)),
                subtitle: Text(
                  DateFormat('MMM dd, HH:mm').format(selectedTime),
                  style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.access_time, color: gold),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedTime),
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedTime = DateTime(
                        selectedTime.year,
                        selectedTime.month,
                        selectedTime.day,
                        picked.hour,
                        picked.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: textDim)),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  context.read<ReminderProvider>().addReminder(
                    messageController.text,
                    selectedTime,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder Scheduled.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: bgPrimary),
              child: const Text('SCHEDULE'),
            ),
          ],
        ),
      ),
    );
  }
}
