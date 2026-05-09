import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/project_provider.dart';
import '../providers/team_provider.dart';
import '../providers/milestone_provider.dart';
import '../models/team_model.dart';
import 'package:intl/intl.dart';
import 'project_management_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _isCreating = false;
  Project? _editingProject;

  bool get _isEditing => _editingProject != null;

  // Form Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _projectType = 'product development';
  String _status = 'planning';
  DateTime? _startDate;
  DateTime? _deadline;
  int _healthTarget = 90;
  
  final List<String> _selectedTech = [];
  final List<String> _milestones = ['', '', ''];
  final List<MemberModel> _assignedInterns = [];

  final List<String> _techStacks = [
    'Flutter', 'FastAPI', 'PostgreSQL', 'React', 'Python', 
    'TensorRT', 'MediaPipe', 'Docker', 'Jetson', 'CAN Bus'
  ];

  double get _formProgress {
    double progress = 0;
    if (_nameController.text.isNotEmpty) progress += 0.25;
    if (_selectedTech.isNotEmpty) progress += 0.25;
    if (_assignedInterns.length >= 2) progress += 0.25;
    if (_milestones.where((m) => m.isNotEmpty).length >= 2) progress += 0.25;
    return progress;
  }

  void _addIntern(MemberModel member) {
    setState(() {
      if (!_assignedInterns.any((m) => m.id == member.id)) {
        _assignedInterns.add(member);
      }
    });
  }

  void _saveProject() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty || _startDate == null || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields: Name, Description, and Dates.')),
      );
      return;
    }
    
    try {
      if (_isEditing) {
        await context.read<ProjectProvider>().updateProject(
          _editingProject!.id,
          _nameController.text,
          _descController.text,
          _status,
          _milestones.where((m) => m.isNotEmpty).toList(),
        );
      } else {
        await context.read<ProjectProvider>().addProject(
          name: _nameController.text,
          description: _descController.text,
          status: _status,
          type: _projectType,
          startDate: _startDate!,
          deadline: _deadline!,
          techStack: _selectedTech,
          milestones: _milestones.where((m) => m.isNotEmpty).toList(),
        );
      }
      
      // Refresh milestones to ensure they show up in the Gantt view
      await context.read<MilestoneProvider>().fetchAll();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project "${_nameController.text}" ${_isEditing ? 'Updated' : 'Created'} Successfully!')),
      );
      setState(() {
        _isCreating = false;
        _editingProject = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreating) return _buildListView();
    
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      appBar: JarvisTopbar(
        title: _isEditing ? 'EDIT PROJECT: ${_editingProject!.name.toUpperCase()}' : 'NEW PROJECT',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: gold),
          onPressed: () => setState(() { _isCreating = false; _editingProject = null; }),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() { _isCreating = false; _editingProject = null; }),
            child: Text('CANCEL', style: TextStyle(color: textDim)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _saveProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(_isEditing ? 'UPDATE PROJECT' : 'CREATE PROJECT'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isDesktop ? _buildTwoColumnLayout() : _buildStackedLayout(),
      ),
    );
  }

  Widget _buildListView() {
    return Scaffold(
      appBar: JarvisTopbar(
        title: 'PROJECTS',
        actions: [
          ElevatedButton.icon(
            onPressed: () => setState(() => _isCreating = true),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('ADD PROJECT'),
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: bgPrimary),
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: gold));
          if (provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: textDim.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('NO PROJECTS FOUND', style: GoogleFonts.orbitron(color: textDim, fontSize: 14)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 160,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return _buildProjectCard(project);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: goldLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(project.name.toUpperCase(), 
                  style: GoogleFonts.orbitron(color: gold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(project.status.toUpperCase(), style: const TextStyle(color: gold, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: gold, size: 14),
                onPressed: () {
                  setState(() {
                    _editingProject = project;
                    _isCreating = true;
                    // Pre-fill controllers
                    _nameController.text = project.name;
                    _descController.text = project.description ?? '';
                    _status = project.status;
                    // In a real app, you'd populate other fields from project metadata
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(project.description ?? 'No description provided.', 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textDim, fontSize: 12),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showProjectDetails(project), 
                child: const Text('DETAILS', style: TextStyle(color: gold, fontSize: 11))
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectManagementScreen(project: project),
                    ),
                  );
                }, 
                child: const Text('MANAGE', style: TextStyle(color: gold, fontSize: 11))
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildLeftPanel()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        _buildLeftPanel(),
        const SizedBox(height: 24),
        _buildRightPanel(),
      ],
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        _buildCard(
          title: 'PROJECT DETAILS',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Project Name', _nameController, hint: 'Enter project title...'),
              const SizedBox(height: 20),
              _buildTextField('Description', _descController, hint: 'Explain project scope...', maxLines: 3),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Project Type', _projectType.toLowerCase(), [
                      'product development', 'research', 'internal'
                    ], (val) => setState(() => _projectType = val!)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildDropdown('Status', _status.toLowerCase(), [
                      'planning', 'active', 'completed'
                    ], (val) => setState(() => _status = val!)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Start Date', _startDate, (d) => setState(() => _startDate = d))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDatePicker('Deadline', _deadline, (d) => setState(() => _deadline = d))),
                ],
              ),
              const SizedBox(height: 24),
              _buildHealthSelector(),
              const SizedBox(height: 24),
              _buildTechStackSelector(),
              const SizedBox(height: 24),
              _buildTextField('NOTES / CONTEXT', _notesController, hint: 'Additional details...', maxLines: 2),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildProgressCard(),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        _buildCard(
          title: 'CORE TEAM (PERMANENT)',
          child: Column(
            children: [
              _buildTeamRow('Chakravarthi', 'CORE', isPermanent: true),
              const SizedBox(height: 16),
              _buildAddButton('Add Permanent Core Member', () {}),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'INTERN ASSIGNMENT',
          subtitle: 'Cohort 1 — Jan-Apr 2026',
          child: Column(
            children: [
              ..._assignedInterns.map((member) => _buildTeamRow(
                member.name, 
                member.role, 
                onRemove: () => setState(() => _assignedInterns.remove(member)),
              )).toList(),
              const SizedBox(height: 16),
              _buildAddInternDropdown(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'INITIAL MILESTONES',
          child: Column(
            children: [
              ..._milestones.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMilestoneField(entry.key),
              )).toList(),
              const SizedBox(height: 4),
              _buildAddButton('Add Milestone', () => setState(() => _milestones.add(''))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: goldLine),
        boxShadow: [
          BoxShadow(color: gold.withOpacity(0.02), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.orbitron(color: gold, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              if (subtitle != null)
                Text(subtitle, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textDim.withOpacity(0.5), fontSize: 12),
            filled: true,
            fillColor: bgTertiary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: bgTertiary,
            icon: const Icon(Icons.arrow_drop_down, color: gold),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(
              e.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '), 
              style: const TextStyle(color: textPrimary, fontSize: 13)
            ))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(primary: gold, onPrimary: bgPrimary, surface: bgSecondary, onSurface: textPrimary),
                ),
                child: child!,
              ),
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(color: date == null ? textDim : textPrimary, fontSize: 13),
                ),
                const Icon(Icons.calendar_today, size: 14, color: gold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HEALTH TARGET', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [90, 80, 70].map((h) {
            final isSelected = _healthTarget == h;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _healthTarget = h),
                child: Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? goldDim : bgTertiary,
                    border: Border.all(color: isSelected ? gold : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('$h%', style: TextStyle(color: isSelected ? gold : textDim, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTechStackSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TECH STACK USED', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _techStacks.map((tech) {
            final isSelected = _selectedTech.contains(tech);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) _selectedTech.remove(tech);
                  else _selectedTech.add(tech);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? goldDim : bgTertiary,
                  border: Border.all(color: isSelected ? gold : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tech, style: TextStyle(color: isSelected ? gold : textDim, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTeamRow(String name, String role, {bool isPermanent = false, VoidCallback? onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: gold.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(role, style: TextStyle(color: isPermanent ? gold : textDim, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (!isPermanent)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: dangerColor),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: goldDim, borderRadius: BorderRadius.circular(4)),
              child: const Text('CORE', style: TextStyle(color: gold, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: goldLine, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 14, color: gold),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.jetBrainsMono(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInternDropdown() {
    final teamProvider = context.watch<TeamProvider>();
    final availableMembers = teamProvider.members.where((m) => !_assignedInterns.any((assigned) => assigned.id == m.id)).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<MemberModel>(
        hint: Text('Assign intern to this project', style: GoogleFonts.jetBrainsMono(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: bgTertiary,
        icon: const Icon(Icons.arrow_drop_down, color: gold),
        items: availableMembers.map((m) => DropdownMenuItem(
          value: m, 
          child: Text('${m.name} (${m.role})', style: const TextStyle(color: textPrimary, fontSize: 12))
        )).toList(),
        onChanged: (val) {
          if (val != null) _addIntern(val);
        },
      ),
    );
  }

  Widget _buildMilestoneField(int index) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('${index + 1}', style: const TextStyle(color: bgPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => _milestones[index] = val),
            style: const TextStyle(color: textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter milestone details...',
              hintStyle: TextStyle(color: textDim.withOpacity(0.5), fontSize: 12),
              filled: true,
              fillColor: bgTertiary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final milestonesCount = _milestones.where((m) => m.isNotEmpty).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(6), border: Border.all(color: goldLine)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FORM PROGRESS', style: GoogleFonts.orbitron(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('${(_formProgress * 100).toInt()}%', style: GoogleFonts.jetBrainsMono(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _formProgress,
              backgroundColor: bgTertiary,
              color: gold,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressIndicator('Details', _nameController.text.isNotEmpty),
              _buildProgressIndicator('Tech Stack', _selectedTech.isNotEmpty),
              _buildProgressIndicator('Team', _assignedInterns.length >= 2, label_val: '${_assignedInterns.length}/4'),
              _buildProgressIndicator('Milestones', milestonesCount >= 1, label_val: '$milestonesCount/3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, bool completed, {String? label_val}) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: textDim, fontSize: 9)),
            const SizedBox(width: 4),
            Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, size: 10, color: completed ? okColor : textDim),
          ],
        ),
        if (label_val != null)
          Text(label_val, style: const TextStyle(color: textPrimary, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: goldLine)),
        title: Text(project.name.toUpperCase(), style: GoogleFonts.orbitron(color: gold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Status', project.status.toUpperCase()),
              _buildDetailItem('Description', project.description ?? 'N/A'),
              const SizedBox(height: 16),
              Text('SYSTEM METRICS', style: GoogleFonts.orbitron(color: gold.withOpacity(0.5), fontSize: 10)),
              const Divider(color: goldLine),
              const SizedBox(height: 8),
              const Text('• Milestones synchronized with central hub.', style: TextStyle(color: textDim, fontSize: 11)),
              const Text('• Team assignments verified.', style: TextStyle(color: textDim, fontSize: 11)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE', style: TextStyle(color: gold))),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}
