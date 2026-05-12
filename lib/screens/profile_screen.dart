// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../providers/auth_provider.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/jarvis_topbar.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final user = authProvider.user;
    final completedTasks = taskProvider.tasks.where((t) => t.status == TaskStatus.done).length;
    final activeProjects = projectProvider.projects.length;

    if (user == null) {
      return Scaffold(
        appBar: const JarvisTopbar(title: 'PROFILE'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NO ACTIVE SESSION', style: GoogleFonts.orbitron(color: gold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => authProvider.logout(),
                child: const Text('GO TO LOGIN'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const JarvisTopbar(title: 'EXECUTIVE PROFILE'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 40),
            _buildStats(completedTasks, activeProjects),
            const SizedBox(height: 40),
            _buildSection(
              title: 'PERSONAL INFORMATION',
              child: Column(
                children: [
                  _buildInfoRow('NAME', user.userMetadata?['full_name']?.toString().toUpperCase() ?? 'N/A'),
                  _buildInfoRow('ROLE', user.userMetadata?['role']?.toString().toUpperCase() ?? 'N/A'),
                  _buildInfoRow('EMAIL', user.email ?? 'N/A'),
                  _buildInfoRow('LOCATION', 'HYDERABAD, INDIA'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'SYSTEM PREFERENCES',
              child: Column(
                children: [
                  _buildPreferenceRow('THEME', 'PATHVISION DARK', Icons.dark_mode),
                  _buildPreferenceRow('NOTIFICATIONS', 'ENABLED', Icons.notifications_active),
                  _buildPreferenceRow('AI MODEL', 'JARVIS-4 QUANTUM', Icons.psychology),
                  _buildPreferenceRow('SYNC STATUS', 'OPTIMAL', Icons.sync),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gold, width: 2),
            boxShadow: [
              BoxShadow(color: gold.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
            ],
            image: const DecorationImage(
              image: NetworkImage('https://ui-avatars.com/api/?name=Aman+Mehta&background=0D0D0D&color=D4AF37'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userMetadata?['full_name']?.toString().toUpperCase() ?? 'USER',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: gold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.userMetadata?['role']?.toString().toUpperCase() ?? 'EXECUTIVE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: textDim,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: incomeLight.withOpacity(0.1),
                  border: Border.all(color: incomeLight.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 12, color: incomeLight),
                    const SizedBox(width: 6),
                    Text(
                      'SYSTEM LEVEL: L9 EXECUTIVE',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        color: incomeLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(int tasks, int projects) {
    return Row(
      children: [
        _buildStatCard('TASKS DONE', tasks.toString(), okColor),
        const SizedBox(width: 16),
        _buildStatCard('PROJECTS', projects.toString(), blueColor),
        const SizedBox(width: 16),
        _buildStatCard('PRODUCTIVITY', '98%', gold),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: goldLine.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: goldLine.withOpacity(0.3)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10)),
          Text(value, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: gold),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10)),
          const Spacer(),
          Text(value, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 14, color: textDim),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          authProvider.logout();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: dangerColor.withOpacity(0.1),
          foregroundColor: dangerColor,
          side: const BorderSide(color: dangerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'TERMINATE SESSION',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
